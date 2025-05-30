import Foundation

// 1. PokemonListItem
struct PokemonListItem: Codable, Identifiable {
    let name: String
    let url: String
    var id: String { name }
}

// 2. PokemonDetail
struct PokemonDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let sprites: SpriteImages
    let moves: [MoveEntry]
    let types: [TypeEntry]
    let height: Int
    let weight: Int
}

// 3. SpriteImages
/// A container for all sprite URLs returned by the PokeAPI.  The sprite
/// structure of the API is quite nested and can change between generations.
/// Instead of modelling every possible field, this struct recursively
/// collects every URL found in the `sprites` object.
struct SpriteImages: Codable {
    /// All sprite URL strings discovered in the API response.
    let all: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        var urls: [String] = []
        SpriteImages.collectURLs(from: container, into: &urls)
        self.all = urls
    }

    // MARK: - Recursive helpers

    /// Recursively collect any URL strings from a keyed container.
    private static func collectURLs(from container: KeyedDecodingContainer<DynamicCodingKey>, into urls: inout [String]) {
        for key in container.allKeys {
            if let url = try? container.decode(String.self, forKey: key), url.hasPrefix("http") {
                urls.append(url)
            } else if let nested = try? container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: key) {
                collectURLs(from: nested, into: &urls)
            } else if var unkeyed = try? container.nestedUnkeyedContainer(forKey: key) {
                collectURLs(from: &unkeyed, into: &urls)
            }
        }
    }

    /// Recursively collect any URL strings from an unkeyed container.
    private static func collectURLs(from container: inout UnkeyedDecodingContainer, into urls: inout [String]) {
        while !container.isAtEnd {
            if let url = try? container.decode(String.self), url.hasPrefix("http") {
                urls.append(url)
            } else if let nested = try? container.nestedContainer(keyedBy: DynamicCodingKey.self) {
                collectURLs(from: nested, into: &urls)
            } else if var unkeyed = try? container.nestedUnkeyedContainer() {
                collectURLs(from: &unkeyed, into: &urls)
            } else {
                _ = try? container.decode(EmptyDecodable.self)
            }
        }
    }
}

/// A helper coding key that can be created from any string or integer key.
private struct DynamicCodingKey: CodingKey {
    var stringValue: String
    init?(stringValue: String) { self.stringValue = stringValue }
    var intValue: Int?
    init?(intValue: Int) { self.stringValue = String(intValue); self.intValue = intValue }
}

/// Used to skip over values we don't care about while decoding.
private struct EmptyDecodable: Decodable {}

// 4. MoveEntry
struct MoveEntry: Codable, Identifiable {
    let move: Move
    var id: String { move.id }
}

// 5. Move
struct Move: Codable, Identifiable {
    let name: String
    let url: String
    var id: String { name }
}

// Details for an individual move used to display additional
// information such as the move's type.
struct MoveDetailData: Codable, Identifiable {
    let id: Int
    let name: String
    let type: TypeDetail
}

// 6. TypeEntry
struct TypeEntry: Codable {
    let slot: Int
    let type: TypeDetail
}

// 7. TypeDetail
struct TypeDetail: Codable, Identifiable {
    let name: String
    let url: String
    var id: String { name }
}

// 8. PokemonSpecies
struct PokemonSpecies: Codable {
    let flavor_text_entries: [FlavorTextEntry]
    let id: Int // Useful for fetching, not necessarily for Identifiable here
}

// 9. FlavorTextEntry
struct FlavorTextEntry: Codable {
    let flavor_text: String
    let language: Language
    let version: Version? // Optional
}

// 10. Language
struct Language: Codable {
    let name: String // e.g., "en"
    let url: String
}

// 11. Version
struct Version: Codable {
    let name: String
    let url: String
}

// 12. TypeData
struct TypeData: Codable, Identifiable {
    let name: String
    let damage_relations: DamageRelations
    let id: Int
}

// 13. DamageRelations
struct DamageRelations: Codable {
    let double_damage_from: [TypeDetail]
    let double_damage_to: [TypeDetail]
    let half_damage_from: [TypeDetail]?
    let half_damage_to: [TypeDetail]?
    let no_damage_from: [TypeDetail]?
    let no_damage_to: [TypeDetail]?
}

// 14. PokemonListResponse
struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItem]
}
