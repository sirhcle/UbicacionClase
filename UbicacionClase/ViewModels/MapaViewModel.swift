import SwiftUI
import MapKit

/// Estado de la pantalla "Mapa con marcadores" (ejemplo del día 9).
///
/// Capa MVVM: **ViewModel**. Guarda los lugares a mostrar, hacia dónde mira la cámara,
/// el lugar seleccionado y el estilo del mapa. Para el permiso de ubicación usa `UbicacionManager`.
@MainActor
@Observable
final class MapaViewModel {

    // MARK: - Estado

    /// Los lugares que se dibujan como marcadores.
    let lugares = Lugar.ciudadDeMexico

    /// Hacia dónde mira la cámara del mapa. `.automatic` deja que el mapa decida.
    /// La vista lo conecta al `Map` con `@Bindable`, por eso no es `private(set)`.
    var posicion: MapCameraPosition = .automatic

    /// El `id` del lugar tocado en el mapa; nil si no hay ninguno.
    var seleccion: Lugar.ID?

    /// El estilo de mapa elegido (estándar, satélite o híbrido).
    var estilo: EstiloMapa = .estandar

    // MARK: - Propiedades calculadas

    /// El lugar que corresponde a `seleccion`. `first(where:)` devuelve el primero
    /// que cumple la condición, o nil si ninguno la cumple.
    var lugarSeleccionado: Lugar? {
        lugares.first { $0.id == seleccion }
    }

    // MARK: - Acciones

    /// Pide el permiso para poder dibujar el punto azul de "estás aquí".
    func pedirPermiso() async {
        _ = await UbicacionManager.shared.pedirPermiso()
    }

    /// Mueve la cámara a un lugar, con un acercamiento de unos 2 km de ancho.
    func irA(_ lugar: Lugar) {
        seleccion = lugar.id
        posicion = .region(
            MKCoordinateRegion(
                center: lugar.coordenada,
                latitudinalMeters: 2000,
                longitudinalMeters: 2000
            )
        )
    }
}
