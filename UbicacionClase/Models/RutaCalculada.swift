import MapKit

// MARK: - MedioDeTransporte

/// Cómo se va a recorrer la ruta.
///
/// Capa MVVM: **Model**. Cada caso traduce su nombre en pantalla al tipo de transporte de MapKit.
enum MedioDeTransporte: String, CaseIterable, Identifiable, Hashable {
    case auto = "En auto"
    case caminando = "Caminando"
    
    var id: String { rawValue }
    
    /// El tipo de transporte que entiende `MKDirections`.
    var tipo: MKDirectionsTransportType {
        switch self {
        case .auto: .automobile
        case .caminando: .walking
        }
    }
}

// MARK: - RutaCalculada

/// El resultado de calcular una ruta: el trazo para dibujar en el mapa y sus datos.
///
/// Capa MVVM: **Model**. `MKRoute` es el objeto de Apple con el trazo, la distancia
/// y el tiempo estimado; aquí le agregamos textos listos para mostrar.
struct RutaCalculada {
    let ruta: MKRoute
    
    /// Distancia en kilómetros con un decimal, por ejemplo "5.3 km".
    /// `ruta.distance` viene en metros. `%.1f` significa "un decimal".
    var distanciaTexto: String {
        String(format: "%.1f km", ruta.distance/1000)
    }
    
    /// Tiempo estimado en minutos, por ejemplo "18 min".
    /// `expectedTravelTime` viene en segundos.
    var tiempoTexto: String {
        "\(Int((ruta.expectedTravelTime / 60).rounded())) min"
    }
}
