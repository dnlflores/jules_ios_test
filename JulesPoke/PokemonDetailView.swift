import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel
    let pokemonName: String

    init(pokemonName: String) {
        self.pokemonName = pokemonName
        _viewModel = StateObject(
            wrappedValue: PokemonDetailViewModel(pokemonName: pokemonName)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Loading & Error States
                if viewModel.isLoading && viewModel.pokemonDetail == nil {
                    ProgressView("Loading details...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }

                // Main Content
                if let detail = viewModel.pokemonDetail {
                    // Name
                    Text(detail.name.capitalized)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .center)

                    // Sprites Section
                    if let sprites = detail.sprites {
                        let urls = sprites.allSpriteURLs
                        if !urls.isEmpty {
                            Text("Sprites").font(.title2)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(urls, id: \.self) { urlString in
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
                                .padding(.vertical)
                            }
                        }
                    }

                    // Pokedex Entry
                    Text("Pokedex Entry")
                        .font(.title2)
                        .padding(.top)
                    Text(
                        viewModel.englishPokedexEntry
                        ?? (viewModel.isLoading
                            ? "Loading entry..."
                            : "No Pokedex entry available.")
                    )
                    .padding(.bottom)

                    // Types
                    if let types = detail.types, !types.isEmpty {
                        Text("Types").font(.title2)
                        HStack(spacing: 10) {
                            ForEach(types, id: \.slot) { entry in
                                TypeBadgeView(typeName: entry.type.name)
                            }
                        }
                        .padding(.vertical)
                    }

                    // Effective Against
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

                    // Weak Against
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

                    // Evolution Chain
                    if viewModel.evolutionNames.count > 1 {
                        Text("Evolution Chain").font(.title2)
                        HStack(spacing: 4) {
                            ForEach(viewModel.evolutionNames.indices, id: \.self) { idx in
                                Text(viewModel.evolutionNames[idx].capitalized)
                                if idx < viewModel.evolutionNames.count - 1 {
                                    Image(systemName: "arrow.right")
                                }
                            }
                        }
                        .padding(.vertical)
                    }

                    // Moves
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

                } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                    Text("No details available for \(pokemonName.capitalized).")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(
            viewModel.pokemonDetail?.name.capitalized
            ?? pokemonName.capi
