import SwiftUI

/// Displays a Pokémon type with its corresponding icon from the asset catalog.
struct TypeView: View {
    let typeName: String

    /// Returns the image asset name for a given type.
    private func iconName(for type: String) -> String {
        "\(type.lowercased())_type_symbol"
    }

    /// Background color used for the badge, matching TypeBadgeView's logic.
    private func backgroundColorForType(_ typeName: String) -> Color {
        switch typeName.lowercased() {
            case "normal": return Color.gray
            case "fire": return Color.red
            case "water": return Color.blue
            case "electric": return Color.yellow
            case "grass": return Color.green
            case "ice": return Color.cyan
            case "fighting": return Color.orange
            case "poison": return Color.purple
            case "ground": return Color.brown
            case "flying": return Color(red: 0.67, green: 0.56, blue: 0.93) // Light purple/blue
            case "psychic": return Color.pink
            case "bug": return Color(red: 0.56, green: 0.78, blue: 0.22) // Lime green
            case "rock": return Color(red: 0.71, green: 0.63, blue: 0.35) // Sandy brown
            case "ghost": return Color(red: 0.45, green: 0.35, blue: 0.56) // Darker purple
            case "dragon": return Color(red: 0.44, green: 0.22, blue: 0.88) // Deep indigo
            case "dark": return Color(red: 0.44, green: 0.33, blue: 0.26) // Dark brown/gray
            case "steel": return Color(red: 0.72, green: 0.72, blue: 0.82) // Light steel gray
            case "fairy": return Color(red: 0.93, green: 0.60, blue: 0.68) // Light pink/magenta
            default: return Color.gray.opacity(0.5) // Default for unknown types
        }
    }

    /// Determines an appropriate foreground color based on the background.
    private func foregroundColorForType(_ typeName: String) ->  Color {
        let bgColor = backgroundColorForType(typeName)
        // Simple heuristic: if background is yellow or cyan (common light colors), use black text
        if bgColor == Color.yellow || bgColor == Color.cyan || bgColor == Color(red: 0.72, green: 0.72, blue: 0.82) /* steel */ || bgColor == Color(red: 0.93, green: 0.60, blue: 0.68) /* fairy */ {
            return Color.black
        }
        return Color.white
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(iconName(for: typeName))
                .resizable()
                .frame(width: 16, height: 16)
                .clipShape(Circle())                     // makes it round
                .overlay(                               // optional: a circular border
                    Circle().stroke(Color.white, lineWidth: 1)
                )
                .shadow(radius: 1)                      // optional: a little shadow
            Text(typeName.capitalized)
                .font(Font.custom("Playpen Sans", size: 12).weight(.bold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(backgroundColorForType(typeName))
        .foregroundColor(foregroundColorForType(typeName))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.5), radius: 2, x: 1, y: 1)
    }
}

struct TypeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            TypeView(typeName: "fire")
            TypeView(typeName: "water")
            TypeView(typeName: "grass")
            TypeView(typeName: "electric")
        }
        .padding()
        .background(Color.white)
    }
}
