import SwiftUI

enum Theme {

    // MARK: - Color Palette
    static let pokemonRed = Color("PokemonRed") // Will be defined in Assets
    static let pokemonBlue = Color("PokemonBlue")
    static let pokemonYellow = Color("PokemonYellow")
    
    // Standard colors that don't need asset catalog definitions unless customized further
    static let pokemonBlack = Color.black
    static let pokemonWhite = Color.white
    
    // Accent Grays - consider defining in Assets if specific shades are needed
    static let pokemonLightGray = Color(red: 0.85, green: 0.85, blue: 0.85) // A light gray
    static let pokemonDarkGray = Color(red: 0.3, green: 0.3, blue: 0.3)     // A dark gray for text or accents

    // MARK: - Custom Fonts
    // Replace "PokemonFont-Regular" and "PokemonFont-Bold" with the actual PostScript names
    // of the fonts added to the project.

    static func regularFont(size: CGFloat) -> Font {
        return Font.custom("PokemonFont-Regular", size: size)
    }

    static func boldFont(size: CGFloat) -> Font {
        return Font.custom("PokemonFont-Bold", size: size)
    }
    
    // Example of how to define specific text styles
    enum TextStyle {
        case navigationTitle
        case sectionHeader
        case body
        case caption
        case button

        var font: Font {
            switch self {
            case .navigationTitle:
                return Theme.boldFont(size: 22)
            case .sectionHeader:
                return Theme.boldFont(size: 18)
            case .body:
                return Theme.regularFont(size: 16)
            case .caption:
                return Theme.regularFont(size: 14)
            case .button:
                return Theme.boldFont(size: 16)
            }
        }

        var color: Color {
            switch self {
            case .navigationTitle:
                return Theme.pokemonBlack // Or pokemonWhite if on a dark background
            case .sectionHeader:
                return Theme.pokemonBlack
            case .body, .caption:
                return Theme.pokemonDarkGray
            case .button:
                return Theme.pokemonWhite
            }
        }
    }
}

// Helper extension for applying text styles (optional but convenient)
extension Text {
    func textStyle(_ style: Theme.TextStyle) -> some View {
        self.font(style.font)
            .foregroundColor(style.color)
    }
}

// MARK: - Instructions for Color Assets (for the user)
/*
It's recommended to define `PokemonRed`, `PokemonBlue`, and `PokemonYellow` in your Xcode Asset Catalog (`Assets.xcassets`) for easier management and potential dark mode variations.

To do this:
1. Open `Assets.xcassets` in Xcode.
2. Click the "+" button at the bottom and choose "Color Set".
3. Name the color set exactly as used in `Theme.swift` (e.g., "PokemonRed").
4. Select the new color set. In the Attributes Inspector (right panel):
    - Set "Appearances" to "None" if you only want a single universal color. Or, configure for "Any, Dark" if you plan Dark Mode variations.
    - Click on the color swatch for "Universal" (or "Any Appearance").
    - Set the desired color values (e.g., using RGB, hex).

Example RGB values for the Pokemon theme (adjust to your preference):
- PokemonRed: R:230 G:0 B:0 (Hex: #E60000)
- PokemonBlue: R:51 G:153 B:255 (Hex: #3399FF)
- PokemonYellow: R:255 G:222 B:0 (Hex: #FFDE00)

If you choose not to use the Asset Catalog for these, you can define them directly in `Theme.swift` like `pokemonLightGray`:
static let pokemonRed = Color(red: 230/255, green: 0/255, blue: 0/255)
*/
