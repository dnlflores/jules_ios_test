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

    // Custom init for NavigationBar styling
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("PokemonRed")) // Set background color
        
        // Set title font
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color("PokemonWhite")),
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color("PokemonWhite")),
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance // For smaller nav bars
    }

    // 4. Body View
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search Pokemon", text: $searchText)
                    .foregroundColor(Color("PokemonBlack")) // Text color for TextField
                    .padding()
                    .background(Color("PokemonWhite")) // Background for TextField
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("PokemonBlack").opacity(0.2), lineWidth: 1) // Border for TextField
                    )
                    .padding(.horizontal)

                // Loading View / Error View
                if isLoading {
                    ProgressView { // Custom label for ProgressView
                        Text("Fetching Pokemon...")
                            .foregroundColor(Color("PokemonBlack"))
                    }
                    .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(Color("PokemonRed")) // Error text color
                        .padding()
                }

                // Pokemon List
                List(filteredPokemon) { pokemon in
                    NavigationLink(destination: PokemonDetailView(pokemonName: pokemon.name)) {
                        PokemonRowView(pokemon: pokemon)
                    }
                    .listRowBackground(Color("PokemonWhite")) // Ensure list rows also use the white background
                }
                // 6. .task Modifier
                .task {
                    await fetchInitialPokemon()
                }
                .navigationTitle("Pokedex") // Title set here, color handled by UINavigationBarAppearance
            }
            .background(Color("PokemonWhite")) // Background for the VStack
        }
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
