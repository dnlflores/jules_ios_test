import SwiftUI

struct ContentView: View {
    // 2. State Variables
    @State private var pokemonList: [PokemonListItem] = []
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    // 3. Computed Property for Filtered Pokemon
    var filteredPokemon: [PokemonListItem] {
        if searchText.isEmpty {
            return pokemonList
        } else {
            return pokemonList.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    // 4. Body View
    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Set spacing to 0 if we want list to seamlessly connect to search bar background
                // Search Bar
                TextField("Search Pokemon", text: $searchText)
                    .font(Theme.regularFont(size: 16))
                    .foregroundColor(Theme.pokemonBlack)
                    .padding()
                    .background(Theme.pokemonWhite)
                    .cornerRadius(10)
                    .padding() // Padding around the search bar itself
                    .background(Theme.pokemonRed.ignoresSafeArea(edges: .top)) // Background for the search bar area

                // Loading View / Error View
                if isLoading {
                    ProgressView { Text("Fetching Pokemon...").textStyle(.body) }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center it
                        .background(Theme.pokemonLightGray.ignoresSafeArea())
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .textStyle(.body)
                        .foregroundColor(Theme.pokemonRed)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Center it
                        .background(Theme.pokemonLightGray.ignoresSafeArea())
                } else {
                    // Pokemon List
                    List(filteredPokemon) { pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemonName: pokemon.name)) {
                            PokemonRowView(pokemon: pokemon)
                        }
                        .listRowBackground(Color.clear) // Allow PokemonRowView to show its own background
                        .listRowSeparator(.hidden) // Hide default separators
                         // .listRowInsets(EdgeInsets()) // Consider if padding from PokemonRowView is enough
                    }
                    .listStyle(PlainListStyle()) // Use PlainListStyle for more control over background
                    .background(Theme.pokemonLightGray.ignoresSafeArea()) // Main background for the list area
                    // 6. .task Modifier
                    .task {
                        await fetchInitialPokemon()
                    }
                }
            }
            .navigationTitle("Pokedex") // Font for this will be set globally later
        }
        // Apply global font for navigation title - this is a more involved step (UINavigationBarAppearance)
        // For now, .navigationTitle("Pokedex") uses default system font.
        // If we want to force it here (might not be ideal for all navigation styles):
        // .navigationBarTitleDisplayMode(.inline) // Or .large
        // .toolbar {
        //     ToolbarItem(placement: .principal) { // Or .navigationBarLeading / .navigationBarTrailing for other styles
        //         Text("Pokedex").font(Theme.boldFont(size: 22)).foregroundColor(Theme.pokemonWhite) // Example
        //     }
        // }
        // .navigationViewStyle(StackNavigationViewStyle()) // Useful on iPad
    }

    // 5. Fetch Pokemon Function
    func fetchInitialPokemon() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }

        do {
            let response = try await NetworkManager.shared.fetchPokemonList()
            await MainActor.run {
                self.pokemonList = response.results
            }
        } catch {
            await MainActor.run {
                 if let networkError = error as? NetworkError {
                    switch networkError {
                    case .invalidURL:
                        self.errorMessage = "Invalid URL encountered. Please contact support."
                    case .requestFailed(let underlyingError):
                        self.errorMessage = "Request failed: \(underlyingError.localizedDescription). Please check your connection."
                    case .decodingError(let underlyingError):
                        self.errorMessage = "Failed to decode Pokemon data: \(underlyingError.localizedDescription). Please try again."
                    case .unknown:
                        self.errorMessage = "An unknown error occurred. Please try again."
                    }
                } else {
                    self.errorMessage = "Failed to load Pokemon. Error: \(error.localizedDescription). Please try again."
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
