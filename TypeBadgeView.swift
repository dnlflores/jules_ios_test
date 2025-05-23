import SwiftUI

struct TypeBadgeView: View {
    let typeName: String

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
    
    // Determine appropriate foreground color based on background brightness
    private func foregroundColorForType(_ typeName: String) -> Color {
        let bgColor = backgroundColorForType(typeName)
        // Simple heuristic: if background is yellow or cyan (common light colors), use black text
        if bgColor == Color.yellow || bgColor == Color.cyan || bgColor == Color(red: 0.72, green: 0.72, blue: 0.82) /* steel */ || bgColor == Color(red: 0.93, green: 0.60, blue: 0.68) /* fairy */ {
            return Color.black
        }
        return Color.white
    }

    var body: some View {
        Text(typeName.capitalized)
            .font(Theme.boldFont(size: 12)) // Using theme's custom bold font
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColorForType(typeName))
            .foregroundColor(foregroundColorForType(typeName)) // Dynamic foreground color
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.5), radius: 2, x: 1, y: 1) // More defined shadow
    }
}

struct TypeBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            TypeBadgeView(typeName: "fire")
            TypeBadgeView(typeName: "water")
            TypeBadgeView(typeName: "Grass") // Test capitalization
            TypeBadgeView(typeName: "electric") // Test light background
            TypeBadgeView(typeName: "steel")
            TypeBadgeView(typeName: "fairy")
            TypeBadgeView(typeName: "unknownType")
        }
        .padding()
        .background(Color.white) // Add a background to the preview VStack for better contrast
    }
}
