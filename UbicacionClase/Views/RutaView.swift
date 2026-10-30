import SwiftUI
import MapKit

/// Pantalla del ejemplo extra "Ruta entre dos puntos" (día 9).
///
/// Capa MVVM: **View**. Dibuja un mapa con el origen, el destino y el trazo de la ruta,
/// y debajo los menús para elegirlos. El cálculo lo hace `RutaViewModel`.
struct RutaView: View {
    // MARK: - Estado

    @State private var viewModel = RutaViewModel()

    // MARK: - Cuerpo

    var body: some View {
        // Necesario para poder escribir `$viewModel.posicion` (un binding) más abajo.
        @Bindable var viewModel = viewModel

        Map(position: $viewModel.posicion) {
            // `if let` también funciona dentro del mapa: el marcador solo existe si hay un origen.
            if let origen = viewModel.origen {
                Marker(origen.nombre, systemImage: "flag.fill", coordinate: origen.coordenada)
                    .tint(.green)
            }

            if let destino = viewModel.destino {
                Marker(destino.nombre, systemImage: "mappin", coordinate: destino.coordenada)
                    .tint(.red)
            }

            // El trazo de la ruta: una línea azul de 5 puntos de grosor.
            if let calculada = viewModel.ruta {
                MapPolyline(calculada.ruta)
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .navigationTitle("Ruta")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            panelInferior
        }
    }

    // MARK: - Partes de la pantalla

    /// El panel de abajo: menús de origen y destino, medio de transporte y resultado.
    @ViewBuilder
    private var panelInferior: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 12) {
            // Cada Picker guarda el `id` del lugar elegido, no el lugar completo.
            Picker("Origen", selection: $viewModel.origenID) {
                ForEach(viewModel.lugares) { lugar in
                    Text(lugar.nombre).tag(lugar.id)
                }
            }

            Picker("Destino", selection: $viewModel.destinoID) {
                ForEach(viewModel.lugares) { lugar in
                    Text(lugar.nombre).tag(lugar.id)
                }
            }

            Picker("Medio", selection: $viewModel.medio) {
                ForEach(MedioDeTransporte.allCases) { medio in
                    Text(medio.rawValue).tag(medio)
                }
            }
            .pickerStyle(.segmented)

            Button {
                Task { await viewModel.calcular() }
            } label: {
                if viewModel.calculando {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Calcular ruta")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.calculando)

            if let calculada = viewModel.ruta {
                Text("\(calculada.distanciaTexto) · \(calculada.tiempoTexto)")
                    .font(.headline)
            }

            if let mensaje = viewModel.mensaje {
                Text(mensaje)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(.bar)
    }
}

#Preview {
    NavigationStack { RutaView() }
}
