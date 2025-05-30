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
                if viewModel.isLoading && viewModel.pokemonDetail == nil {
                    ProgressView("Loading details...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                if let detail = viewModel.pokemonDetail {
                    // Pokemon Name
                    Text(detail.name.capitalized)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Sprites Section
                    if let sprites = detail.sprites {
                        Text("Sprites").font(.title2)
                        HStack {
                            Spacer()
                            if let urlString = sprites.front_default,
                               let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                            }
                            if let urlString = sprites.front_shiny,
                               let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                            }
                            Spacer()
                        }
                        .padding(.vertical)
                    }

                    // Pokedex Entry Section
                    Text("Pokedex Entry")
                        .font(.title2)
                        .padding(.top)
                    Text(viewModel.englishPokedexEntry
                            ?? (viewModel.isLoading
                                ? "Loading entry..."
                                : "No Pokedex entry available."))
                        .padding(.bottom)

                    // Types Section
                    if let types = detail.types, !types.isEmpty {
                        Text("Types").font(.title2)
                        HStack(spacing: 10) {
                            ForEach(types, id: \.slot) { typeEntry in
                                TypeBadgeView(typeName: typeEntry.type.name)
                            }
                        }
                        .padding(.vertical)
                    }

                    // Effective Against Section
                    if !viewModel.effectiveAgainstTypes.isEmpty {
                        Text("Effective Against").font(.title2)
                        FlexibleFlowLayout(
                          data: viewModel.effectiveAgainstTypes,
                          spacing: 8,
                          alignment: .leading
                        ) { typeName in
                            TypeBadgeView(typeName: typeName)
                        }
                        .padding(.vertical)
                    }

                    // Weak Against Section
                    if !viewModel.weakAgainstTypes.isEmpty {
                        Text("Weak Against").font(.title2)
                        FlexibleFlowLayout(
                          data: viewModel.weakAgainstTypes,
                          spacing: 8,
                          alignment: .leading
                        ) { typeName in
                            TypeBadgeView(typeName: typeName)
                        }
                        .padding(.vertical)
                    }

                    // Evolution Chain Section
                    if viewModel.evolutionNames.count > 1 {
                        Text("Evolution Chain").font(.title2)
                        HStack(spacing: 4) {
                            ForEach(viewModel.evolutionNames.indices, id: \.self) { index in
                                Text(viewModel.evolutionNames[index].capitalized)
                                if index < viewModel.evolutionNames.count - 1 {
                                    Image(systemName: "arrow.right")
                                }
                            }
                        }
                        .padding(.vertical)
                    }

                    // Moves Section
                    if !viewModel.moveDetails.isEmpty {
                        Text("Moves").font(.title2)
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.moveDetails) { move in
                                HStack(spacing: 8) {
                                    TypeBadgeView(typeName: move.type.name)
                                    Text(move.name.capitalized)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.bottom)
                    }

                    // (Optional) Additional effectiveness section could go here
                    // Text("Effectiveness").font(.title2)
                    // Text("Effectiveness will go here")
                    //     .padding(.bottom)

                } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                    Text("No details available for \(pokemonName.capitalized).")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.pokemonDetail?.name.capitalized ?? pokemonName.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PokemonDetailView(pokemonName: "pikachu")
        }
    }
}
