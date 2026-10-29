import SwiftUI

/// Pantalla del ejemplo "Mi ubicación" (día 9).
///
/// Capa MVVM: **View**. Muestra el estado del permiso, botones para pedirlo y para leer la
/// ubicación, y las coordenadas obtenidas. Toda la lógica está en `UbicacionViewModel`.
struct UbicacionView: View {
    // MARK: - Estado

    @State private var viewModel = UbicacionViewModel()

    // MARK: - Cuerpo

    var body: some View {
        Form {
            Section("Permiso") {
                Text(viewModel.permiso.texto)

                // Solo se dibuja mientras la persona no haya decidido.
                if viewModel.permiso == .noDeterminado {
                    Button("Pedir permiso") {
                        Task { await viewModel.pedirPermiso() }
                    }
                }

                // Si ya dijo que no, el aviso no vuelve a salir: hay que mandarla a Ajustes.
                if viewModel.necesitaAjustes, let url = viewModel.urlAjustes {
                    Link("Abrir Ajustes", destination: url)
                }

                Button("Revisar de nuevo") {
                    viewModel.revisarPermiso()
                }
            }

            Section("Ubicación") {
                Button {
                    Task { await viewModel.obtenerUbicacion() }
                } label: {
                    if viewModel.cargando {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Obtener mi ubicación")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.puedeObtenerUbicacion || viewModel.cargando)

                // `if let` abre los opcionales: estas filas solo aparecen si ya hay una ubicación.
                if let latitud = viewModel.latitudTexto,
                   let longitud = viewModel.longitudTexto,
                   let precision = viewModel.precisionTexto {
                    LabeledContent("Latitud", value: latitud)
                    LabeledContent("Longitud", value: longitud)
                    LabeledContent("Precisión", value: precision)
                }

                if let mensaje = viewModel.mensaje {
                    Text(mensaje)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Text("En el simulador: menú Features → Location y elige una ubicación (por ejemplo Apple o Custom Location). Con \"None\" no hay ubicación y la lectura falla.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Mi ubicación")
    }
}

#Preview {
    NavigationStack { UbicacionView() }
}
