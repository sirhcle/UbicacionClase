import SwiftUI
import MapKit

/// Pantalla del ejemplo "Buscar lugares cercanos" (día 9).
///
/// Capa MVVM: **View**. Tiene una barra de búsqueda, un mapa con los resultados como
/// marcadores y una lista con los mismos resultados. La búsqueda la hace `BuscarViewModel`.
struct BuscarView: View {
    // MARK: - Estado

    @State private var viewModel = BuscarViewModel()

    // MARK: - Cuerpo

    var body: some View {
        // Necesario para poder escribir `$viewModel.texto` y `$viewModel.posicion`.
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            Map(position: $viewModel.posicion, selection: $viewModel.seleccion) {
                UserAnnotation()

                ForEach(viewModel.resultados) { lugar in
                    Marker(lugar.nombre, coordinate: lugar.coordenada)
                        .tag(lugar.id)
                }
            }
            .frame(height: 300)

            resultados
        }
        .navigationTitle("Buscar lugares")
        .navigationBarTitleDisplayMode(.inline)
        // `searchable` agrega la barra de búsqueda; `onSubmit` se ejecuta al tocar "Buscar" en el teclado.
        .searchable(text: $viewModel.texto, prompt: "Café, farmacia, parque...")
        .onSubmit(of: .search) {
            Task { await viewModel.buscar() }
        }
        .task {
            await viewModel.prepararse()
        }
    }

    // MARK: - Partes de la pantalla

    /// La lista de resultados, o un aviso si todavía no hay nada que mostrar.
    private var resultados: some View {
        List {
            if viewModel.buscando {
                ProgressView("Buscando…")
                    .frame(maxWidth: .infinity)
            }

            if !viewModel.origenDeBusqueda.isEmpty {
                Text(viewModel.origenDeBusqueda)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let mensaje = viewModel.mensaje {
                Text(mensaje)
                    .foregroundStyle(.red)
            }

            ForEach(viewModel.resultados) { lugar in
                Button(lugar.nombre) {
                    viewModel.irA(lugar)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { BuscarView() }
}
