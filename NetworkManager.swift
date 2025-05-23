import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingError(Error)
    case unknown
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://pokeapi.co/api/v2/"
    private let decoder = JSONDecoder()

    private init() {
        // Configure the decoder if needed, e.g., key decoding strategy
        // decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // Generic function to fetch data from a specific endpoint
    private func fetchData<T: Codable>(from endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                print("Decoding Error: \(error) for URL: \(url)")
                print("Raw data: \(String(data: data, encoding: .utf8) ?? "No raw data")")
                throw NetworkError.decodingError(error)
            }
        } catch {
            if error is NetworkError {
                throw error // Re-throw our custom decoding error
            }
            print("Request Failed: \(error) for URL: \(url)")
            throw NetworkError.requestFailed(error)
        }
    }

    // Generic function to fetch data from a full URL string
    func fetchData<T: Codable>(fromURL urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                print("Decoding Error: \(error) for URL: \(url)")
                print("Raw data: \(String(data: data, encoding: .utf8) ?? "No raw data")")
                throw NetworkError.decodingError(error)
            }
        } catch {
             if error is NetworkError {
                throw error // Re-throw our custom decoding error
            }
            print("Request Failed: \(error) for URL: \(url)")
            throw NetworkError.requestFailed(error)
        }
    }

    // Specific API call functions

    func fetchPokemonList(limit: Int = 151, offset: Int = 0) async throws -> PokemonListResponse {
        let endpoint = "pokemon?limit=\(limit)&offset=\(offset)"
        return try await fetchData(from: endpoint)
    }

    func fetchPokemonDetail(name: String) async throws -> PokemonDetail {
        let endpoint = "pokemon/\(name.lowercased())"
        return try await fetchData(from: endpoint)
    }

    func fetchPokemonSpecies(name: String) async throws -> PokemonSpecies {
        // Species can be identified by name or ID. The API seems to handle names well.
        let endpoint = "pokemon-species/\(name.lowercased())"
        return try await fetchData(from: endpoint)
    }
    
    // It can also be fetched by ID if we have it from PokemonDetail
    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpecies {
        let endpoint = "pokemon-species/\(id)"
        return try await fetchData(from: endpoint)
    }

    func fetchTypeData(typeName: String) async throws -> TypeData {
        let endpoint = "type/\(typeName.lowercased())"
        return try await fetchData(from: endpoint)
    }
}
