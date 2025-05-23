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
            case "fire": return Color("PokemonRed")
            case "water": return Color("PokemonBlue")
            case "electric": return Color("PokemonYellow")
            case "normal": return Color("PokemonBlack")
            case "grass", "bug": return Color("PokemonYellow")
            case "ice", "flying", "fairy", "steel": return Color("PokemonBlue")
            case "fighting", "poison", "ground", "psychic", "rock", "ghost", "dragon", "dark":
                return Color("PokemonBlack")
            default: return Color("PokemonBlack").opacity(0.7)
        }
    }

    /// Determines an appropriate foreground color based on the background.
    private func foregroundColorForType(_ typeName: String) -> Color {
        let bgColor = backgroundColorForType(typeName)
        if bgColor == Color("PokemonRed") ||
            bgColor == Color("PokemonBlue") ||
            bgColor == Color("PokemonBlack") ||
            bgColor == Color("PokemonBlack").opacity(0.7) {
            return Color("PokemonWhite")
        } else if bgColor == Color("PokemonYellow") || bgColor == Color("PokemonWhite") {
            return Color("PokemonBlack")
        }
        return Color("PokemonBlack")
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(iconName(for: typeName))
                .resizable()
                .frame(width: 16, height: 16)
            Text(typeName.capitalized)
                .font(Font.custom("Onest", size: 12).weight(.bold))
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
