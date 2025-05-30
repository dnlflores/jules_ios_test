import SwiftUI
import Foundation // For cleaning flavor text

class PokemonDetailViewModel: ObservableObject {
    @Published var pokemonDetail: PokemonDetail?
    @Published var pokemonSpecies: PokemonSpecies?
    @Published var typeDetails: [TypeData] = []
    @Published var moveDetails: [MoveDetailData] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let pokemonName: String

    init(pokemonName: String) {
        self.pokemonName = pokemonName
        Task {
            await fetchAllData()
        }
    }

    func fetchAllData() async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }

        defer {
            Task { // Ensure defer block also runs on main thread if it updates UI state
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }

        do {
            // Fetch Pokemon detail and species concurrently
            async let detailResult = NetworkManager.shared.fetchPokemonDetail(name: pokemonName)
            async let speciesResult = NetworkManager.shared.fetchPokemonSpecies(name: pokemonName)

            let fetchedDetail = try await detailResult
            let fetchedSpecies = try await speciesResult
            
            await MainActor.run {
                self.pokemonDetail = fetchedDetail
                self.pokemonSpecies = fetchedSpecies
            }

            // If pokemonDetail is successfully fetched and contains types, fetch type data
            if !fetchedDetail.types.isEmpty {
                let loaded = await withTaskGroup(of: TypeData?.self) { group -> [TypeData] in
                    for entry in fetchedDetail.types {
                        group.addTask {
                            // each task runs in parallel
                            return try? await NetworkManager.shared.fetchTypeData(typeName: entry.type.name)
                        }
                    }
                    var results = [TypeData]()
                    for await maybeDetail in group {
                        if let detail = maybeDetail {
                            results.append(detail)
                        }
                    }
                    return results
                }

            await MainActor.run {
                self.typeDetails = loaded
            }
        }

        if !fetchedDetail.moves.isEmpty {
            let firstMoves = fetchedDetail.moves.prefix(10)
            let loadedMoves = await withTaskGroup(of: MoveDetailData?.self) { group -> [MoveDetailData] in
                for moveEntry in firstMoves {
                    group.addTask {
                        return try? await NetworkManager.shared.fetchMoveDetail(moveName: moveEntry.move.name)
                    }
                }
                var results = [MoveDetailData]()
                for await maybeMove in group {
                    if let move = maybeMove {
                        results.append(move)
                    }
                }
                return results
            }

            await MainActor.run {
                self.moveDetails = loadedMoves.sorted { $0.name < $1.name }
            }
        }
        } catch {
            await MainActor.run {
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .invalidURL:
                        self.errorMessage = "Invalid URL. Could not fetch Pokemon details."
                    case .requestFailed(let underlyingError):
                        self.errorMessage = "Request failed: \(underlyingError.localizedDescription)."
                    case .decodingError(let underlyingError):
                        self.errorMessage = "Failed to decode Pokemon details: \(underlyingError.localizedDescription)."
                    case .noConnection:
                        self.errorMessage = "No internet connection. Unable to fetch Pokemon details."
                    case .unknown:
                        self.errorMessage = "An unknown error occurred while fetching Pokemon details."
                    }
                } else {
                    self.errorMessage = "Failed to load details for \(pokemonName.capitalized): \(error.localizedDescription)"
                }
            }
        }
    }

    var englishPokedexEntry: String? {
        guard let species = pokemonSpecies else { return nil }
        
        let entry = species.flavor_text_entries
            .first { $0.language.name == "en" }?
            .flavor_text
        
        // Clean up the text: replace newlines and other special characters
        return entry?
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{000C}", with: " ") // Form feed
            .replacingOccurrences(of: "\r", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var effectiveAgainstTypes: [String] {
        var combinedDamageTo = Set<String>()
        for typeData in typeDetails {
            for effectiveType in typeData.damage_relations.double_damage_to {
                combinedDamageTo.insert(effectiveType.name)
            }
        }
        // Filter out types that are also in the Pokemon's own types, if desired (complex interactions exist)
        // For now, just list all types it's super-effective against.
        return Array(combinedDamageTo).sorted()
    }

    var weakAgainstTypes: [String] {
        var combinedDamageFrom = Set<String>()
        for typeData in typeDetails {
            for weakType in typeData.damage_relations.double_damage_from {
                combinedDamageFrom.insert(weakType.name)
            }
        }
        // Filter out types that the Pokemon might also be resistant to due to its other type (complex interactions)
        // For now, just list all types it's weak against.
        return Array(combinedDamageFrom).sorted()
    }
}
