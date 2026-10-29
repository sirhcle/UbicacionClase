import SwiftUI

/// Estado de la navegación del menú principal (día 9).
///
/// Capa MVVM: **ViewModel**. Guarda la ruta de pantallas abiertas para que
/// `NavigationStack(path:)` la use.
///
/// - `@MainActor` indica que todo lo de esta clase corre en el hilo principal,
///   el que dibuja la pantalla. Así evitamos errores de concurrencia.
/// - `@Observable` hace que SwiftUI redibuje las vistas cuando cambia una propiedad.
/// - `final` significa que nadie puede heredar de esta clase.
@MainActor
@Observable
final class MenuViewModel {

    // MARK: - Estado

    /// Pantallas abiertas, en orden. Es la ruta del NavigationStack: si agregas un
    /// ejemplo aquí, la app navega hacia él; si la vacías, regresa al menú.
    var ruta: [Ejemplo] = []
}
