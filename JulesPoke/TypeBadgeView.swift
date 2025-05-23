import SwiftUI

struct TypeBadgeView: View {
    let typeName: String

    private func backgroundColorForType(_ typeName: String) -> Color {
        switch typeName.lowercased() {
            case "fire": return Color("PokemonRed")
            case "water": return Color("PokemonBlue")
            case "electric": return Color("PokemonYellow")
            case "normal": return Color("PokemonBlack")
            case "grass", "bug": return Color("PokemonYellow")
            case "ice", "flying", "fairy", "steel": return Color("PokemonBlue")
            case "fighting", "poison", "ground", "psychic", "rock", "ghost", "dragon", "dark": return Color("PokemonBlack")
            default: return Color("PokemonBlack").opacity(0.7)
        }
    }
    
    // Determine appropriate foreground color based on background brightness
    private func foregroundColorForType(_ typeName: String) -> Color {
        let bgColor = backgroundColorForType(typeName)
        // Updated heuristic for new Pokemon color palette
        if bgColor == Color("PokemonRed") || bgColor == Color("PokemonBlue") || bgColor == Color("PokemonBlack") || bgColor == Color("PokemonBlack").opacity(0.7) {
            return Color("PokemonWhite")
        } else if bgColor == Color("PokemonYellow") || bgColor == Color("PokemonWhite") {
            return Color("PokemonBlack")
        }
        // Default fallback, though the above should cover all main cases
        return Color("PokemonBlack")
    }

    var body: some View {
        Text(typeName.capitalized)
            .font(Font.playpenSans(size: 12).weight(.bold)) // Apply custom font
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
