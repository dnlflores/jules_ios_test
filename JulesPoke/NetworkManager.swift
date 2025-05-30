import Foundation
import Network

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingError(Error)
    case noConnection
    case unknown
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://pokeapi.co/api/v2/"
    private let decoder = JSONDecoder()
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var isConnected: Bool = true
    var isNetworkAvailable: Bool { isConnected }

    private init() {
        // Configure the decoder if needed, e.g., key decoding strategy
        // decoder.keyDecodingStrategy = .convertFromSnakeCase
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: monitorQueue)
    }

    // Internal helper to perform a request with retry capability
    private func fetchData<T: Codable>(url: URL, retryAttempts: Int) async throws -> T {
        guard isConnected else { throw NetworkError.noConnection }

        var attempt = 0
        var lastError: Error?
        while attempt <= retryAttempts {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                return try decoder.decode(T.self, from: data)
            } catch {
                if let networkError = error as? NetworkError {
                    throw networkError
                }
                lastError = error
                if attempt < retryAttempts {
                    attempt += 1
                    let delay = pow(2.0, Double(attempt))
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    print("Request Failed: \(error) for URL: \(url)")
                    throw NetworkError.requestFailed(error)
                }
            }
        }
        throw lastError ?? NetworkError.unknown
    }

    // Generic function to fetch data from a specific endpoint
    private func fetchData<T: Codable>(from endpoint: String, retryAttempts: Int = 2) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        return try await fetchData(url: url, retryAttempts: retryAttempts)
    }

    // Generic function to fetch data from a full URL string
    func fetchData<T: Codable>(fromURL urlString: String, retryAttempts: Int = 2) async throws -> T {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        return try await fetchData(url: url, retryAttempts: retryAttempts)
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

    func fetchEvolutionChain(urlString: String) async throws -> EvolutionChain {
        return try await fetchData(fromURL: urlString)
    }
}
