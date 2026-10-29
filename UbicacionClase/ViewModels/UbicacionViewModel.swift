import SwiftUI
import CoreLocation

/// Estado de la pantalla "Mi ubicación" (ejemplo del día 9).
///
/// Capa MVVM: **ViewModel**. Guarda el estado del permiso, la última ubicación leída
/// y los mensajes. Para hablar con el GPS usa `UbicacionManager`.
@MainActor
@Observable
final class UbicacionViewModel {

    // MARK: - Estado

    /// Estado actual del permiso de ubicación.
    /// `private(set)`: la vista puede leerlo, pero solo esta clase puede cambiarlo.
    private(set) var permiso: EstadoPermiso

    /// Última ubicación leída; nil mientras no se haya pedido ninguna.
    private(set) var ubicacion: CLLocation?

    /// `true` mientras esperamos la lectura del GPS.
    private(set) var cargando = false

    /// Mensaje sobre el último intento; nil si no hay.
    private(set) var mensaje: String?

    // MARK: - Ciclo de vida

    /// Al crear el ViewModel leemos el permiso, sin mostrar ningún aviso todavía.
    init() {
        permiso = UbicacionManager.shared.estadoPermiso
    }

    // MARK: - Propiedades calculadas

    /// ¿Se puede pedir la ubicación? Solo con el permiso concedido.
    var puedeObtenerUbicacion: Bool { permiso == .permitido }

    /// ¿Hay que mandar al usuario a Ajustes? Pasa cuando ya dijo que no.
    var necesitaAjustes: Bool { permiso == .denegado }

    /// La dirección de la pantalla de Ajustes de esta app. Es opcional porque
    /// crear una URL a partir de un texto puede fallar.
    var urlAjustes: URL? {
        URL(string: UIApplication.openSettingsURLString)
    }

    /// Los datos de la ubicación como textos listos para mostrar; nil si no hay ubicación.
    /// `String(format:)` con `%.5f` muestra 5 decimales.
    var latitudTexto: String? {
        guard let ubicacion else { return nil }
        return String(format: "%.5f", ubicacion.coordinate.latitude)
    }

    var longitudTexto: String? {
        guard let ubicacion else { return nil }
        return String(format: "%.5f", ubicacion.coordinate.longitude)
    }

    /// Precisión horizontal: el radio de error en metros.
    var precisionTexto: String? {
        guard let ubicacion else { return nil }
        return String(format: "± %.0f m", ubicacion.horizontalAccuracy)
    }

    // MARK: - Acciones

    /// Vuelve a leer el estado del permiso. Útil después de cambiarlo en Ajustes.
    func revisarPermiso() {
        permiso = UbicacionManager.shared.estadoPermiso
    }

    /// Muestra el aviso de permiso (si todavía no se ha decidido).
    func pedirPermiso() async {
        permiso = await UbicacionManager.shared.pedirPermiso()
    }

    /// Lee la ubicación actual y la guarda.
    func obtenerUbicacion() async {
        guard !cargando else { return }
        cargando = true
        mensaje = nil

        do {
            ubicacion = try await UbicacionManager.shared.ubicacionActual()
        } catch {
            mensaje = error.localizedDescription
        }

        cargando = false
    }
}
