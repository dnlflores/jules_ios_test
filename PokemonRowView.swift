import SwiftUI

struct PokemonRowView: View {
    let pokemon: PokemonListItem

    var body: some View {
        HStack {
            Text(pokemon.name.capitalized)
                .font(Theme.boldFont(size: 18))
                .foregroundColor(Theme.pokemonDarkGray)
            Spacer()
        }
        .padding() // Padding inside the white box
        .background(Theme.pokemonWhite)
        .cornerRadius(10) // Rounded corners for the row's white box
        .padding(.horizontal) // Padding to keep row from touching screen edges
        .padding(.vertical, 5)   // Spacing between rows
    }
}

struct PokemonRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PokemonRowView(pokemon: PokemonListItem(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"))
            PokemonRowView(pokemon: PokemonListItem(name: "charmander", url: "https://pokeapi.co/api/v2/pokemon/4/"))
            PokemonRowView(pokemon: PokemonListItem(name: "PikachuWithVeryLongNameForTesting", url: "https://pokeapi.co/api/v2/pokemon/25/"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Theme.pokemonLightGray) // Preview background to see row separation
    }
}
