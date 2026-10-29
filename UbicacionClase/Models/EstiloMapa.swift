import _MapKit_SwiftUI

/// Los estilos de mapa que puede elegir el usuario.
///
/// Capa MVVM: **Model**. Cada caso sabe su nombre en pantalla y el estilo de Apple que le corresponde.
///
/// - `String` da a cada caso un texto (`rawValue`), que usamos como nombre visible.
/// - `CaseIterable` permite recorrer todos los casos con `EstiloMapa.allCases`.
/// - `Identifiable` y `Hashable` hacen que el `Picker` pueda usarlo como opción.
enum EstiloMapa: String, CaseIterable, Identifiable, Hashable {
    case estandar = "Estándar"
    case satelite = "Satélite"
    case hibrido = "Híbrido"

    var id: String { rawValue }

    /// El `MapStyle` de MapKit que corresponde a cada caso.
    var estilo: MapStyle {
        switch self {
        case .estandar: .standard
        case .satelite: .imagery
        case .hibrido: .hybrid
        }
    }
}
