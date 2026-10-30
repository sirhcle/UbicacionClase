import SwiftUI
import MapKit

/// Estado de la pantalla "Ruta entre dos puntos" (ejemplo extra del día 9).
///
/// Capa MVVM: **ViewModel**. Guarda el origen y el destino elegidos, el medio de transporte
/// y la ruta calculada. Para calcularla usa `RutaManager`.
@MainActor
@Observable
final class RutaViewModel {
    //MARK: - Estado
    
    /// Los lugares entre los que se puede elegir.
    let lugares = Lugar.ciudadDeMexico
    
    /// Hacia dónde mira la cámara del mapa.
    var posicion: MapCameraPosition = .automatic
    
    /// Los `id` del origen y del destino elegidos en los menús.
    /// Empiezan con los dos primeros lugares de la lista.
    var origenID: Lugar.ID
    var destinoID: Lugar.ID

    /// Cómo se recorrerá la ruta.
    var medio: MedioDeTransporte = .auto
    
    /// La ruta calculada; nil mientras no se haya calculado ninguna.
    private(set) var ruta: RutaCalculada?

    /// `true` mientras esperamos la respuesta del servicio de rutas.
    private(set) var calculando = false

    /// Mensaje sobre el último intento; nil si no hay.
    private(set) var mensaje: String?

    // MARK: - Ciclo de vida

    init() {
        origenID = Lugar.ciudadDeMexico[0].id
        destinoID = Lugar.ciudadDeMexico[1].id
    }
    
    // MARK: - Propiedades calculadas

    /// El lugar de origen y el de destino, buscados por su `id`.
    var origen: Lugar? { lugares.first { $0.id == origenID } }
    var destino: Lugar? { lugares.first { $0.id == destinoID } }

    // MARK: - Acciones
    
    /// Calcula la ruta y acerca la cámara para que se vea completa.
    func calcular() async {
        // `guard let` abre los opcionales; si alguno es nil, salimos.
        guard let origen, let destino, !calculando else { return }
        
        guard origen.id != destino.id else {
            mensaje = "Elige un origen y un destino distintos."
            return
        }
        
        calculando = true
        mensaje = nil
        
        do {
            let calculada = try await RutaManager.shared.calcular(desde: origen, hasta: destino, medio: medio)
            ruta = calculada
            posicion = .rect(calculada.ruta.polyline.boundingMapRect)
            
        } catch {
            ruta = nil
            mensaje = error.localizedDescription
        }
        calculando = false
    }
}
