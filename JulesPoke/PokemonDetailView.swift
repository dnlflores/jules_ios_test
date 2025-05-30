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
                            .foregroundColor(Color("PokemonBlack"))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(Color("PokemonRed")) // Error text color
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if let detail = viewModel.pokemonDetail {
                    // Pokemon Name (already in navigation title, but can be good here too)
                     Text(detail.name.capitalized)
                        .foregroundColor(Color("PokemonBlack")) // Text color
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Sprites Section
                    if let sprites = viewModel.pokemonDetail?.sprites, !sprites.all.isEmpty {
                        Text("Sprites").font(.title2)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(sprites.all.sorted(), id: \.self) { urlString in
                                    if let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 120)
                        .padding(.vertical)
                    }

                    // Evolution Chain Section
                    if viewModel.evolutionChainNames.count > 1 {
                        Text("Evolution Chain")
                            .font(.title2)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .center, spacing: 4) {
                                ForEach(viewModel.evolutionChainNames.indices, id: \.self) { index in
                                    Text(viewModel.evolutionChainNames[index].capitalized)
                                        .padding(4)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                    if index < viewModel.evolutionChainNames.count - 1 {
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }

                    // Pokedex Entry Section
                    Text("Pokedex Entry")
                        .foregroundColor(Color("PokemonBlack")) // Section title color
                        .padding(.top)
                    
                    Text(viewModel.englishPokedexEntry ?? (viewModel.isLoading ? "Loading entry..." : "No Pokedex entry available."))
                        .foregroundColor(Color("PokemonBlack")) // Text color
                        .padding(.bottom)

                    // Types Section
                    if let types = viewModel.pokemonDetail?.types, !types.isEmpty {
                        Text("Types")
                            .foregroundColor(Color("PokemonBlack")) // Section title color
                        HStack(spacing: 10) {
                            ForEach(types, id: \.slot) { typeEntry in
                                TypeView(typeName: typeEntry.type.name)
                            }
                        }
                        .padding(.vertical)
                    }

                    // Effective Against Section
                    if !viewModel.effectiveAgainstTypes.isEmpty {
                        Text("Effective Against")
                            .foregroundColor(Color("PokemonBlack")) // Section title color
                        FlexibleFlowLayout(data: viewModel.effectiveAgainstTypes, spacing: 8, alignment: .leading) { typeName in
                            TypeView(typeName: typeName)
                        }
                        .padding(.vertical)
                    }

                    // Weak Against Section
                    if !viewModel.weakAgainstTypes.isEmpty {
                        Text("Weak Against")
                            .foregroundColor(Color("PokemonBlack")) // Section title color
                        FlexibleFlowLayout(data: viewModel.weakAgainstTypes, spacing: 8, alignment: .leading) { typeName in
                            TypeView(typeName: typeName)
                        }
                        .padding(.vertical)
                    }

                    // Moves Section (Placeholder)
                    Text("Moves")
                        .font(.title2)
                    Text("Moves will go here") // This placeholder remains
                        .padding(.bottom)
                    }

                    // Effectiveness Section (Placeholder) - This was part of the original code, if it's different from "Effective/Weak Against", it should remain or be clarified.
                    // For now, assuming "Effective Against" and "Weak Against" cover this. If not, this placeholder might need to be re-evaluated.
                    // Text("Effectiveness") 
                    //     .font(.title2)
                    // Text("Effectiveness will go here")
                    //     .padding(.bottom)

                } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                     // Case where not loading, no error, but also no detail (e.g. initial state before task runs, though less likely with current VM setup)
                    Text("No details available for \(pokemonName.capitalized).")
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
