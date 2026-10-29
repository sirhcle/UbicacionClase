import SwiftUI

/// Menú principal: lista los ejemplos por sección y navega a cada uno.
///
/// Capa MVVM: **View**. Dibuja la lista y deja que `MenuViewModel` controle la ruta.
struct MenuView: View {
    // MARK: - Estado

    @State private var viewModel = MenuViewModel()

    // MARK: - Cuerpo

    var body: some View {
        // `@Bindable` crea los "bindings" ($) hacia las propiedades de un ViewModel @Observable.
        // Lo declaramos dentro del body porque el ViewModel vive en @State.
        @Bindable var viewModel = viewModel

        // NavigationStack(path:) deja que el ViewModel controle la navegación.
        NavigationStack(path: $viewModel.ruta) {
            List {
                ForEach(Seccion.allCases) { seccion in
                    Section(seccion.rawValue) {
                        ForEach(seccion.ejemplos) { ejemplo in
                            // Al tocar, SwiftUI agrega `ejemplo` a la ruta y busca su destino abajo.
                            NavigationLink(value: ejemplo) {
                                Label(ejemplo.titulo, systemImage: ejemplo.icono)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ubicación")
            .navigationDestination(for: Ejemplo.self) { ejemplo in
                destino(para: ejemplo)
            }
        }
    }

    // MARK: - Destinos

    /// Pantalla que corresponde a cada ejemplo.
    /// `@ViewBuilder` permite devolver una vista distinta en cada caso del switch.
    @ViewBuilder
    private func destino(para ejemplo: Ejemplo) -> some View {
        switch ejemplo {
        // Relleno temporal: cada ejemplo lo reemplaza por su pantalla real.
        case .miUbicacion:
            UbicacionView()
        case .mapa:
            MapaView()
        case  .buscarLugares:
            BuscarView()
        case .ruta:
            Text("Por si da tiempo... XD: \(ejemplo.titulo)")
        }
    }
}


#Preview {
    MenuView()
}
