import CoreLocation

/// Un lugar con nombre y coordenadas: un pin del mapa o un resultado de búsqueda.
///
/// Capa MVVM: **Model**. Solo guarda datos y ofrece unos lugares de ejemplo.
///
/// - `Identifiable` pide un `id` único para que `ForEach` y el mapa distingan un lugar de otro.
/// - `Hashable` permite comparar lugares y usarlos como valores de selección.
/// - Guardamos latitud y longitud como `Double` y no como `CLLocationCoordinate2D`,
///   porque ese tipo de Apple no es `Hashable`. La propiedad calculada `coordenada`
///   lo arma cuando hace falta.
struct Lugar: Identifiable, Hashable {
    // Al darle un valor inicial a `id`, Swift no lo pide al crear un `Lugar`:
    // cada lugar recibe automáticamente su propio identificador.
    let id = UUID()
    let nombre: String
    let latitud: Double
    let longitud: Double

    /// La coordenada lista para usarse en el mapa.
    var coordenada: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    }

    // MARK: - Lugares de ejemplo

    /// El Zócalo, centro de la Ciudad de México. Es el punto de partida cuando no tenemos
    /// la ubicación de la persona. Las coordenadas son aproximadas.
    static let zocalo = Lugar(nombre: "Zócalo", latitud: 19.4326, longitud: -99.1332)

    /// Cuatro lugares conocidos de la Ciudad de México (coordenadas aproximadas).
    /// `static let` los crea una sola vez y se comparten en toda la app.
    static let ciudadDeMexico: [Lugar] = [
        zocalo,
        Lugar(nombre: "Ángel de la Independencia", latitud: 19.4270, longitud: -99.1677),
        Lugar(nombre: "Castillo de Chapultepec", latitud: 19.4204, longitud: -99.1819),
        Lugar(nombre: "Biblioteca Central UNAM", latitud: 19.3327, longitud: -99.1925)
    ]
}
