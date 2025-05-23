import SwiftUI

struct PokemonRowView: View {
    let pokemon: PokemonListItem

    var body: some View {
        HStack {
            Text(pokemon.name.capitalized)
                .font(.playpenSans(size: 17)) // Apply custom font
                .foregroundColor(Color("PokemonBlack")) // Set text color
            Spacer() // Aligns text to the leading edge
        }
        .padding(.vertical, 4) // Add some vertical padding for better spacing in a list
        .background(Color("PokemonWhite")) // Set background color
    }
}

struct PokemonRowView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonRowView(pokemon: PokemonListItem(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"))
            .previewLayout(.fixed(width: 300, height: 70))
            .padding() // Add padding to the preview itself for better visibility
        
        PokemonRowView(pokemon: PokemonListItem(name: "charmander", url: "https://pokeapi.co/api/v2/pokemon/4/"))
            .previewLayout(.sizeThatFits) // Another way to preview
            .padding()
    }
}
