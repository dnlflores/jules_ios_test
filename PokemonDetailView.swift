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
            VStack(alignment: .leading, spacing: 15) { // Adjusted spacing
                if viewModel.isLoading && viewModel.pokemonDetail == nil {
                    ProgressView { Text("Loading details...").textStyle(.body) }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .textStyle(.body)
                        .foregroundColor(Theme.pokemonRed)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.pokemonWhite.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal) // Ensure padding from screen edges for the error box
                }

                if let detail = viewModel.pokemonDetail {
                    Text(detail.name.capitalized)
                        .textStyle(.navigationTitle) // Applied text style
                        .foregroundColor(Theme.pokemonRed) // Color for contrast
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)


                    // Sprites Section
                    if let sprites = viewModel.pokemonDetail?.sprites {
                        Text("Sprites").textStyle(.sectionHeader).foregroundColor(Theme.pokemonBlack)
                        HStack {
                            Spacer()
                            if let frontDefaultURLString = sprites.front_default, let url = URL(string: frontDefaultURLString) {
                                AsyncImage(url: url) { image in image.resizable() }
                                placeholder: { ProgressView().tint(Theme.pokemonRed) }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                            }
                            if let frontShinyURLString = sprites.front_shiny, let url = URL(string: frontShinyURLString) {
                                AsyncImage(url: url) { image in image.resizable() }
                                placeholder: { ProgressView().tint(Theme.pokemonRed) }
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Theme.pokemonWhite.opacity(0.7)) // Slight transparency for white
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                    }

                    // Pokedex Entry Section
                    Text("Pokedex Entry").textStyle(.sectionHeader).foregroundColor(Theme.pokemonBlack)
                    Text(viewModel.englishPokedexEntry ?? (viewModel.isLoading ? "Loading entry..." : "No Pokedex entry available."))
                        .textStyle(.body)
                        .padding(.bottom, 5)

                    // Types Section
                    if let types = viewModel.pokemonDetail?.types, !types.isEmpty {
                        Text("Types").textStyle(.sectionHeader).foregroundColor(Theme.pokemonBlack)
                        HStack(spacing: 10) {
                            ForEach(types, id: \.slot) { typeEntry in
                                TypeBadgeView(typeName: typeEntry.type.name)
                            }
                        }
                        .padding(.vertical, 5)
                    }

                    // Effective Against Section
                    if !viewModel.effectiveAgainstTypes.isEmpty {
                        Text("Effective Against").textStyle(.sectionHeader).foregroundColor(Theme.pokemonBlack)
                        FlexibleFlowLayout(data: viewModel.effectiveAgainstTypes, spacing: 8, alignment: .leading) { typeName in
                            TypeBadgeView(typeName: typeName)
                        }
                        .padding(.vertical, 5)
                    }

                    // Weak Against Section
                    if !viewModel.weakAgainstTypes.isEmpty {
                        Text("Weak Against").textStyle(.sectionHeader).foregroundColor(Theme.pokemonBlack)
                        FlexibleFlowLayout(data: viewModel.weakAgainstTypes, spacing: 8, alignment: .leading) { typeName in
                            TypeBadgeView(typeName: typeName)
                        }
                        .padding(.vertical, 5)
                    }

                    // Moves Section
                    if let moves = viewModel.pokemonDetail?.moves, !moves.isEmpty {
                        Text("Moves") // Section Title
                            .textStyle(.sectionHeader)
                            .foregroundColor(Theme.pokemonBlack) // Match other section headers

                        FlexibleFlowLayout(data: moves, spacing: 8, alignment: .leading) { moveEntry in
                            Text(moveEntry.move.name.capitalized.replacingOccurrences(of: "-", with: " "))
                                .font(Theme.regularFont(size: 14)) // Or Theme.TextStyle.caption.font
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Theme.pokemonBlue.opacity(0.7)) // Example background - could be pokemonDarkGray or another theme color
                                .foregroundColor(Theme.pokemonWhite) // Ensure contrast with the background
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 5) // Match padding of other sections like Types/Effectiveness
                    } else if viewModel.isLoading {
                        // Optionally show a placeholder or nothing while loading,
                        // or rely on the main ProgressView
                    } else {
                        Text("No moves data available.")
                            .textStyle(.caption)
                            .padding(.vertical, 5)
                    }
                
                } else if !viewModel.isLoading && viewModel.errorMessage == nil {
                    Text("No details available for \(pokemonName.capitalized).")
                        .textStyle(.body)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding(.horizontal) // Overall horizontal padding for the content
            .padding(.vertical) // Add some vertical padding too
        }
        .background(Theme.pokemonLightGray.ignoresSafeArea()) // Main background for the ScrollView
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
