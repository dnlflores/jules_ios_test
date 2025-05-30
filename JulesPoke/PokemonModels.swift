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
struct SpriteImages: Codable {
    let front_default: String?
    let front_shiny: String?
    // Optional other sprite URLs
    let back_default: String?
    let back_shiny: String?
}

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
    let evolution_chain: EvolutionChainInfo
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

// 15. EvolutionChainInfo
struct EvolutionChainInfo: Codable {
    let url: String
}

// 16. EvolutionChain
struct EvolutionChain: Codable {
    let id: Int
    let chain: EvolutionChainLink
}

// 17. EvolutionChainLink
struct EvolutionChainLink: Codable {
    let species: SpeciesSummary
    let evolves_to: [EvolutionChainLink]
}

// 18. SpeciesSummary
struct SpeciesSummary: Codable {
    let name: String
    let url: String
}
