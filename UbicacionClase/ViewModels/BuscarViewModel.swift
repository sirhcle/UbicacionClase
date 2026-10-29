import SwiftUI
import MapKit

/// Estado de la pantalla "Buscar lugares cercanos" (ejemplo del día 9).
///
/// Capa MVVM: **ViewModel**. Guarda el texto buscado, los resultados, la cámara del mapa
/// y los mensajes. Usa `UbicacionManager` para saber dónde está la persona y
/// `LugaresManager` para buscar.
@MainActor
@Observable
final class BuscarViewModel {

    // MARK: - Estado

    /// Texto que escribe el usuario en la barra de búsqueda.
    var texto = ""

    /// Hacia dónde mira la cámara del mapa.
    var posicion: MapCameraPosition = .automatic

    /// El `id` del lugar tocado; nil si no hay ninguno.
    var seleccion: Lugar.ID?

    /// Los lugares encontrados en la última búsqueda.
    private(set) var resultados: [Lugar] = []

    /// `true` mientras esperamos la respuesta del buscador.
    private(set) var buscando = false

    /// Mensaje sobre la última búsqueda; nil si no hay.
    private(set) var mensaje: String?

    /// De dónde se tomó el centro de la búsqueda, para decírselo al usuario.
    private(set) var origenDeBusqueda = ""

    // MARK: - Acciones

    /// Pide el permiso de ubicación para poder buscar cerca de la persona.
    func prepararse() async {
        _ = await UbicacionManager.shared.pedirPermiso()
    }

    /// Busca lo que escribió el usuario y acerca el mapa a la zona.
    func buscar() async {
        let consulta = texto.trimmingCharacters(in: .whitespaces)
        // `guard` sale si no hay texto o si ya hay una búsqueda en curso.
        guard !consulta.isEmpty, !buscando else { return }

        buscando = true
        mensaje = nil

        let centro = await centroDeBusqueda()

        do {
            resultados = try await LugaresManager.shared.buscar(consulta, cerca: centro)
            if resultados.isEmpty {
                mensaje = "No encontramos resultados para \"\(consulta)\"."
            } else {
                posicion = .region(
                    MKCoordinateRegion(center: centro, latitudinalMeters: 5000, longitudinalMeters: 5000)
                )
            }
        } catch {
            resultados = []
            mensaje = error.localizedDescription
        }

        buscando = false
    }

    /// Mueve la cámara a un resultado.
    func irA(_ lugar: Lugar) {
        seleccion = lugar.id
        posicion = .region(
            MKCoordinateRegion(center: lugar.coordenada, latitudinalMeters: 1000, longitudinalMeters: 1000)
        )
    }

    // MARK: - Apoyo

    /// Decide dónde buscar: cerca de la persona si se pudo leer su ubicación,
    /// y si no, cerca del Zócalo. Así la búsqueda funciona aunque no haya permiso.
    private func centroDeBusqueda() async -> CLLocationCoordinate2D {
        // `try?` intenta la lectura y, si falla, da nil en lugar de lanzar el error.
        if let ubicacion = try? await UbicacionManager.shared.ubicacionActual() {
            origenDeBusqueda = "Buscando cerca de tu ubicación."
            return ubicacion.coordinate
        }
        origenDeBusqueda = "No tenemos tu ubicación: buscando cerca del Zócalo."
        return Lugar.zocalo.coordenada
    }
}
