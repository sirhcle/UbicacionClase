// MARK: - Seccion

/// Agrupa los ejemplos del menú por día de clase.
///
/// Capa MVVM: **Model** del menú. Son datos simples que `MenuView` usa
/// para dibujar los encabezados de la lista.
///
/// - `enum` es una lista cerrada de opciones: una sección solo puede ser uno de estos casos.
/// - `: String` le da a cada caso un texto asociado, llamado `rawValue`.
///   Aquí ese texto es justo el encabezado que ve el usuario.
/// - `CaseIterable` te regala `Seccion.allCases`, un arreglo con todos los casos,
///   para recorrerlos con `ForEach` sin escribirlos a mano.
/// - `Identifiable` pide una propiedad `id` única. `ForEach` la usa
///   para distinguir una sección de otra.
enum Seccion: String, CaseIterable, Identifiable {
    case dia9 = "Día 9 · Ubicación y mapas"

    /// Identificador de cada caso: su texto, que ya es único.
    /// Es una propiedad calculada (computed property): no guarda nada,
    /// calcula su valor cada vez que alguien la lee.
    var id: String { rawValue }

    /// Los ejemplos que pertenecen a esta sección.
    ///
    /// `filter` recorre todos los ejemplos y se queda solo con los que cumplen
    /// la condición. `$0` es el nombre corto del elemento que se está revisando,
    /// y `self` es la sección actual. Así no repites la lista de ejemplos aquí:
    /// cada ejemplo ya dice a qué sección pertenece (ver `seccion` más abajo).
    var ejemplos: [Ejemplo] {
        Ejemplo.allCases.filter { $0.seccion == self }
    }
}

// MARK: - Ejemplo

/// Un caso por cada pantalla de ejemplo del proyecto.
///
/// Capa MVVM: **Model** del menú. Describe qué ejemplos existen, con su título,
/// su ícono y su día. `MenuView` lo usa para dibujar las filas y para navegar.
///
/// Para agregar un ejemplo nuevo: un caso aquí (con su `titulo`, `icono` y `seccion`)
/// y una línea en el `switch` de `MenuView.destino(para:)`.
///
/// - Aquí los casos no tienen texto escrito, así que el `rawValue` es el propio
///   nombre del caso (`"miUbicacion"`, `"mapa"`...).
/// - `Hashable` permite usar un `Ejemplo` como valor de navegación:
///   `NavigationLink(value:)`, `.navigationDestination(for:)` y la ruta de
///   `MenuViewModel` lo necesitan para comparar y guardar valores en la pila de pantallas.
enum Ejemplo: String, CaseIterable, Identifiable, Hashable {
    // MARK: Casos

    // Día 9
    case miUbicacion
    case mapa
    case buscarLugares
    case ruta

    // MARK: Datos para el menú

    /// Identificador único: el nombre del caso.
    var id: String { rawValue }

    /// Texto que se ve en la fila del menú.
    ///
    /// `switch self` revisa en qué caso estás y devuelve un texto distinto para cada uno.
    /// Fíjate que no hace falta escribir `return`: cuando cada rama tiene
    /// una sola expresión, Swift entiende que ese es el valor a devolver.
    var titulo: String {
        switch self {
        case .miUbicacion: "Mi ubicación"
        case .mapa: "Mapa con marcadores"
        case .buscarLugares: "Buscar lugares cercanos"
        case .ruta: "Ruta entre dos puntos (extra)"
        }
    }

    /// Nombre del ícono SF Symbol de cada fila.
    /// Los SF Symbols son íconos que ya vienen en iOS; puedes buscarlos
    /// con la app gratuita "SF Symbols" de Apple.
    var icono: String {
        switch self {
        case .miUbicacion: "location.fill"
        case .mapa: "map"
        case .buscarLugares: "magnifyingglass"
        case .ruta: "arrow.triangle.turn.up.right.diamond"
        }
    }

    /// Día de clase al que pertenece el ejemplo.
    /// Puedes juntar varios casos en una misma rama separándolos con comas.
    var seccion: Seccion {
        switch self {
        case .miUbicacion, .mapa, .buscarLugares, .ruta: .dia9
        }
    }
}
