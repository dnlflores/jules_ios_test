import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel
    let pokemonName: String // Used to pass to the view model

    init(pokemonName: String) {
        self.pokemonName = pokemonName
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonName: pokemonName))
    }
    
    // Alternative init if passing PokemonListItem
    // init(pokemonItem: PokemonListItem) {
    //     self.pokemonName = pokemonItem.name // Keep for title or other uses if needed
    //     _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonName: pokemonItem.name))
    // }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading && viewModel.pokemonDetail == nil { // Show loading only if no detail yet
                    ProgressView { // Custom label for ProgressView
                        Text("Loading details...")
                            .font(Font.custom("Onest", size: 17)) // Apply custom font
                            .foregroundColor(Color("PokemonBlack"))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(Font.custom("Onest", size: 17)) // Apply custom font
                        .foregroundColor(Color("PokemonRed")) // Error text color
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if let detail = viewModel.pokemonDetail {
                    // Pokemon Name (already in navigation title, but can be good here too)
                     Text(detail.name.capitalized)
                        .font(Font.custom("Onest", size: 34)) // Apply custom font
                        .foregroundColor(Color("PokemonBlack")) // Text color
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Sprites Section
                    if let sprites = viewModel.pokemonDetail?.sprites {
                        Text("Sprites")
                            .font(Font.custom("Onest", size: 22)) // Apply custom font
                            .foregroundColor(Color("PokemonBlack")) // Section title color
                        HStack {
                            Spacer() // To center the sprites
                            if let frontDefaultURLString = sprites.front_default, let url = URL(string: frontDefaultURLString) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                            }
                            if let frontShinyURLString = sprites.front_shiny, let url = URL(string: frontShinyURLString) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                            }
                            Spacer() // To center the sprites
                        }
                        .padding(.vertical)
                    }

                    // Pokedex Entry Section
                    Text("Pokedex Entry")
                        .font(Font.custom("Onest", size: 22)) // Apply custom font
                        .foregroundColor(Color("PokemonBlack")) // Section title color
                        .padding(.top)
                    
                    Text(viewModel.englishPokedexEntry ?? (viewModel.isLoading ? "Loading entry..." : "No Pokedex entry available."))
                        .font(Font.custom("Onest", size: 17)) // Apply custom font
                        .foregroundColor(Color("PokemonBlack")) // Text color
                        .padding(.bottom)

                    // Types Section
                    if let types = viewModel.pokemonDetail?.types, !types.isEmpty {
                        Text("Types")
                            .font(Font.custom("Onest", size: 22)) // Apply custom font
                            .foregroundColor(Color("PokemonBlack")) // Section title color
                        HStack(spacing: 10) {
                            ForEach(types, id: \.slot) { typeEntry in
                                TypeBadgeView(typeName: typeEntry.type.name)
                            }
                        }
                        .padding(.vertical)
                    }

                    // Effective Against Section
                    if !viewModel.effectiveAgainstTypes.isEmpty {
                        Text("Effective Against")
                            .font(Font.custom("Onest", size: 22)) // Apply custom font
                            .foregroundColor(Color("PokemonBlack")) // Section title color
                        FlexibleFlowLayout(data: viewModel.effectiveAgainstTypes, spacing: 8, alignment: .leading) { typeName in
                            TypeBadgeView(typeName: typeName)
                        }
                        .padding(.vertical)
                    }

                    // Weak Against Section
                    if !viewModel.weakAgainstTypes.isEmpty {
                        Text("Weak Against")
                            .font(Font.custom("Onest", size: 22)) // Apply custom font
                            .foregroundColor(Color("PokemonBlack")) // Section title color
                        FlexibleFlowLayout(data: viewModel.weakAgainstTypes, spacing: 8, alignment: .leading) { typeName in
                            TypeBadgeView(typeName: typeName)
                        }
                        .padding(.vertical)
                    }

                    // Moves Section (Placeholder)
                    Text("Moves")
                        .font(Font.custom("Onest", size: 22)) // Apply custom font
                        .foregroundColor(Color("PokemonBlack")) // Section title color
                    Text("Moves will go here") // This placeholder remains
                        .font(Font.custom("Onest", size: 17)) // Apply custom font
                        .foregroundColor(Color("PokemonBlack")) // Text color
                        .padding(.bottom)

                    // Effectiveness Section (Placeholder) - This was part of the original code, if it's different from "Effective/Weak Against", it should remain or be clarified.
                    // For now, assuming "Effective Against" and "Weak Against" cover this. If not, this placeholder might need to be re-evaluated.
                    // Text("Effectiveness") 
                    //     .font(.title2)
                    // Text("Effectiveness will go here")
                    //     .padding(.bottom)

                } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                     // Case where not loading, no error, but also no detail (e.g. initial state before task runs, though less likely with current VM setup)
                    Text("No details available for \(pokemonName.capitalized).")
                        .font(Font.custom("Onest", size: 17)) // Apply custom font
                        .foregroundColor(Color("PokemonBlack")) // Text color
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
            .background(Color("PokemonWhite")) // Set background for the VStack content
        }
        .background(Color("PokemonWhite")) // Set background for the ScrollView
        .navigationTitle(viewModel.pokemonDetail?.name.capitalized ?? pokemonName.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        // .task { // ViewModel now fetches in its init
        //     if viewModel.pokemonDetail == nil { // Optional: prevent re-fetching if already loaded by a previous view
        //         await viewModel.fetchAllData()
        //     }
        // }
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PokemonDetailView(pokemonName: "pikachu") // A common Pokemon for preview
        }
    }
}
