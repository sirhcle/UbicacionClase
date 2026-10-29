import SwiftUI
import MapKit

/// Pantalla del ejemplo "Mapa con marcadores" (día 9).
///
/// Capa MVVM: **View**. Dibuja un mapa con un marcador por cada lugar y el punto azul de la
/// persona, y debajo un selector de estilo y botones para ir a cada lugar.
/// La cámara, la selección y el estilo viven en `MapaViewModel`.
struct MapaView: View {
    // MARK: - Estado

    @State private var viewModel = MapaViewModel()

    // MARK: - Cuerpo

    var body: some View {
        // Necesario para poder escribir `$viewModel.posicion` (un binding) más abajo.
        @Bindable var viewModel = viewModel

        // `Map` recibe dos bindings: hacia dónde mira la cámara y qué lugar está seleccionado.
        // Dentro van los elementos del mapa, igual que las filas dentro de un `List`.
        Map(position: $viewModel.posicion, selection: $viewModel.seleccion) {
            // El punto azul de "tú estás aquí". Solo se ve si hay permiso de ubicación.
            UserAnnotation()

            ForEach(viewModel.lugares) { lugar in
                Marker(lugar.nombre, systemImage: "mappin", coordinate: lugar.coordenada)
                    // `tag` conecta el marcador con `seleccion`: al tocarlo, `seleccion` toma este id.
                    .tag(lugar.id)
            }
        }
        .mapStyle(viewModel.estilo.estilo)
        // Botones y adornos que el mapa dibuja por nosotros.
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .navigationTitle("Mapa")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            panelInferior
        }
        // Al aparecer la pantalla, pedimos el permiso para poder dibujar el punto azul.
        .task {
            await viewModel.pedirPermiso()
        }
    }

    // MARK: - Partes de la pantalla

    /// El panel de abajo: estilo del mapa, lugar seleccionado y botones para visitar cada lugar.
    @ViewBuilder
    private var panelInferior: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 12) {
            Picker("Estilo", selection: $viewModel.estilo) {
                ForEach(EstiloMapa.allCases) { estilo in
                    Text(estilo.rawValue).tag(estilo)
                }
            }
            .pickerStyle(.segmented)

            if let lugar = viewModel.lugarSeleccionado {
                Text("Seleccionaste: \(lugar.nombre)")
                    .font(.footnote)
            }

            // Una fila horizontal con scroll de botones, uno por lugar.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.lugares) { lugar in
                        Button(lugar.nombre) {
                            viewModel.irA(lugar)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
        // `.bar` es el fondo translúcido que usa iOS en sus barras.
        .background(.bar)
    }
}

#Preview {
    NavigationStack { MapaView() }
}
