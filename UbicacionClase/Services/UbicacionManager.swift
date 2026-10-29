import CoreLocation

// MARK: - EstadoPermiso

/// El estado del permiso de ubicación, simplificado a cuatro casos.
///
/// Capa MVVM: **Model** (vive junto al Manager porque solo él lo produce).
/// iOS tiene más casos (`authorizedAlways`, `authorizedWhenInUse`...); aquí los juntamos
/// porque a la pantalla solo le importa si puede pedir la ubicación o no.
enum EstadoPermiso {
    case noDeterminado
    case restringido
    case denegado
    case permitido

    /// Texto para mostrar en pantalla.
    var texto: String {
        switch self {
        case .noDeterminado: "Todavía no se ha pedido el permiso."
        case .restringido: "Restringido: este dispositivo no permite usar la ubicación."
        case .denegado: "Denegado: actívalo en Ajustes."
        case .permitido: "Permitido."
        }
    }
}

// MARK: - Errores

/// Los motivos por los que no se pudo obtener la ubicación.
enum ErrorUbicacion: LocalizedError {
    case sinPermiso
    case ocupado
    case noDisponible(String)

    var errorDescription: String? {
        switch self {
        case .sinPermiso: "No hay permiso para usar la ubicación."
        case .ocupado: "Ya hay una búsqueda de ubicación en curso."
        case .noDisponible(let motivo): "No se pudo obtener la ubicación: \(motivo)"
        }
    }
}

// MARK: - UbicacionManager

/// Pide el permiso de ubicación y lee las coordenadas del dispositivo (ejemplos del día 9).
///
/// Capa MVVM: **Service** (un "Manager"). Envuelve a `CLLocationManager`, el objeto de Apple
/// que habla con el GPS. Ese objeto no responde con un `return`: avisa cuando tiene la
/// respuesta, llamando a un **delegado**. Este Manager es su delegado, y por dentro convierte
/// esos avisos en funciones `async`, que son más fáciles de usar desde un ViewModel.
///
/// Es una `class` y no un `struct` por dos razones: un delegado de Apple debe ser una clase
/// (hereda de `NSObject`), y necesita guardar las respuestas pendientes mientras espera.
final class UbicacionManager: NSObject {
    // MARK: - Instancia compartida

    static let shared = UbicacionManager()

    /// `override` porque `NSObject` ya tiene un `init()`. Lo dejamos `private`
    /// para que solo exista la instancia `shared`.
    private override init() {
        super.init()
        // Le decimos al CLLocationManager: "cuando tengas noticias, avísame a mí".
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Estado interno
    
    /// El objeto de Apple que habla con el GPS.
    private let manager = CLLocationManager()
    
    /// Una "continuación" es un marcador de dónde reanudar una función `async` que está
    /// esperando. Mientras no llegue la respuesta, la función se queda dormida aquí.
    private var esperandoPermiso: CheckedContinuation<EstadoPermiso, Never>?
    private var esperandoUbicacion: CheckedContinuation<CLLocation, Error>?

    // MARK: - Acciones
    /// El estado actual del permiso, sin preguntar nada al usuario.
    var estadoPermiso: EstadoPermiso {
        traducir(manager.authorizationStatus)
    }
    
    /// Muestra el aviso de permiso si todavía no se ha decidido y espera la respuesta.
    /// Si el usuario ya decidió antes, devuelve el estado sin mostrar nada.
    func pedirPermiso() async -> EstadoPermiso {
        // Si ya hay una decisión (o ya estamos esperando una), no volvemos a preguntar.
        guard manager.authorizationStatus == .notDetermined, esperandoPermiso == nil else {
            return estadoPermiso
        }

        return await withCheckedContinuation { continuacion in
            esperandoPermiso = continuacion
            manager.requestWhenInUseAuthorization()
        }
    }
    
    /// Pide una sola lectura de la ubicación actual y espera el resultado.
    /// Es una lectura puntual (no seguimiento continuo), que gasta poca batería.
    func ubicacionActual() async throws -> CLLocation {
        guard estadoPermiso == .permitido else { throw ErrorUbicacion.sinPermiso }
        guard esperandoUbicacion == nil else { throw ErrorUbicacion.ocupado }
        
        return try await withCheckedThrowingContinuation { continuacion in
            esperandoUbicacion = continuacion
            manager.requestLocation()
        }
    }
    
    // MARK: - Apoyo

    /// Convierte el estado de Apple en el nuestro, que tiene menos casos.
    private func traducir(_ estado: CLAuthorizationStatus) -> EstadoPermiso {
        switch estado {
        case .notDetermined: .noDeterminado
        case .restricted: .restringido
        case .denied: .denegado
        case .authorizedWhenInUse, .authorizedAlways: .permitido
        @unknown default: .restringido
        }
    }

}

// MARK: - CLLocationManagerDelegate

/// Aquí están los "avisos" del delegado. Cada función se ejecuta sola cuando el sistema
/// tiene algo que contarnos; nosotros nunca las llamamos.
///
/// `@preconcurrency` le dice a Swift que estos métodos de Apple se llaman en el hilo
/// principal, igual que el resto de esta clase.
extension UbicacionManager: @preconcurrency CLLocationManagerDelegate {
    
    /// El permiso cambió (el usuario respondió el aviso o lo cambió en Ajustes).
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Este aviso también llega al crear el manager, antes de que haya una decisión: lo ignoramos.
        guard manager.authorizationStatus != .notDetermined,
              let continuacion = esperandoPermiso else { return }
        esperandoPermiso = nil
        continuacion.resume(returning: estadoPermiso)

    }
    
    /// Llegó la ubicación pedida con `requestLocation()`.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let ultima = locations.last, let continuacion = esperandoUbicacion else { return }
        esperandoUbicacion = nil
        continuacion.resume(returning: ultima)
    }
    
    /// No se pudo obtener la ubicación (por ejemplo, el simulador está en "None").
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let continuacion = esperandoUbicacion else { return }
        esperandoUbicacion = nil
        continuacion.resume(throwing: ErrorUbicacion.noDisponible(error.localizedDescription))
    }
}


