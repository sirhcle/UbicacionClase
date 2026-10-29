import MapKit

/// Busca lugares por texto cerca de un punto (ejemplo "Buscar lugares cercanos", día 9).
///
/// Capa MVVM: **Service** (un "Manager"). Usa `MKLocalSearch`, el buscador de lugares de
/// Apple Maps. Recibe un texto ("café", "farmacia") y una zona, y devuelve `Lugar`s.
/// Necesita internet.
struct LugaresManager {
    // MARK: - Instancia compartida

    static let shared = LugaresManager()
    private init() {}

    // MARK: - Acciones

    /// Busca `texto` cerca de `centro`, dentro de un radio en metros.
    ///
    /// - `cerca centro:` el primer nombre (`cerca`) es la etiqueta al llamar la función
    ///   y el segundo (`centro`) es el nombre que se usa dentro de ella.
    /// - El radio tiene un valor por defecto (`= 3000`), así que al llamarla se puede omitir.
    func buscar(_ texto: String, cerca centro: CLLocationCoordinate2D, radioMetros: Double = 3000) async throws -> [Lugar] {
        let peticion = MKLocalSearch.Request()
        peticion.naturalLanguageQuery = texto
        // La región es el área donde queremos que busque. Es un cuadrado de lado `radio × 2`.
        peticion.region = MKCoordinateRegion(
            center: centro,
            latitudinalMeters: radioMetros * 2,
            longitudinalMeters: radioMetros * 2
        )

        let respuesta = try await MKLocalSearch(request: peticion).start()

        // `compactMap` transforma cada resultado y descarta los que devuelvan nil.
        // Aquí descartamos los que no traigan nombre.
        return respuesta.mapItems.compactMap { elemento in
            guard let nombre = elemento.name else { return nil }
            let coordenada = elemento.placemark.coordinate
            return Lugar(nombre: nombre, latitud: coordenada.latitude, longitud: coordenada.longitude)
        }
    }
}
