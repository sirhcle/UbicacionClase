import MapKit

// MARK: - Errores

/// Los motivos por los que no se pudo calcular una ruta.
enum ErrorRuta: LocalizedError {
    case sinRuta

    var errorDescription: String? {
        switch self {
        case .sinRuta: "No se encontró una ruta entre esos dos puntos."
        }
    }
}

// MARK: - RutaManager

/// Calcula la ruta entre dos lugares (ejemplo extra "Ruta entre dos puntos", día 9).
///
/// Capa MVVM: **Service** (un "Manager"). Usa `MKDirections`, el servicio de rutas de
/// Apple Maps. Recibe un origen, un destino y el medio de transporte, y devuelve una
/// `RutaCalculada`. Necesita internet.
struct RutaManager {
    // MARK: - Instancia compartida

    static let shared = RutaManager()
    
    private init() {}
    
    // MARK: - Acciones

    /// Calcula la mejor ruta de `origen` a `destino`.
    func calcular(desde origen: Lugar, hasta destino: Lugar, medio: MedioDeTransporte) async throws -> RutaCalculada {
        
        let peticion = MKDirections.Request()
        
        // Un `MKMapItem` es "un punto del mapa" para MapKit; se arma a partir de una coordenada.
        peticion.source = MKMapItem(placemark: MKPlacemark(coordinate: origen.coordenada))
        peticion.destination = MKMapItem(placemark: MKPlacemark(coordinate: destino.coordenada))
        peticion.transportType = medio.tipo
        
        let respuesta = try await MKDirections(request: peticion).calculate()
        
        // `routes` puede venir vacío; `first` toma la primera, que es la mejor.
        guard let mejor = respuesta.routes.first else { throw ErrorRuta.sinRuta }
        
        return RutaCalculada(ruta: mejor)
    }
    
    
    

}
