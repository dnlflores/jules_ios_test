import SwiftUI

@main
struct PokeAppApp: App {

    init() {
        // Navigation Bar Appearance
        let appearance = UINavigationBarAppearance()
        
        // Background Color
        appearance.configureWithOpaqueBackground() // Or .configureWithTransparentBackground() if you want more control below
        appearance.backgroundColor = UIColor(Theme.pokemonRed) // Use your theme's red color
        
        // Title Text Attributes (for large titles and inline titles)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(Theme.pokemonWhite), // White title text
            .font: UIFont(name: "PokemonFont-Bold", size: 22) ?? UIFont.boldSystemFont(ofSize: 22) // Theme bold font
        ]
        appearance.titleTextAttributes = titleAttributes
        appearance.largeTitleTextAttributes = titleAttributes // Consistent for large titles
        
        // Bar Button Item Color (e.g., back button)
        // UINavigationBar.appearance().tintColor = UIColor(Theme.pokemonWhite) // This is a global tint for the whole bar
        // For more specific control with appearance object:
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.pokemonWhite),
            .font: UIFont(name: "PokemonFont-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        ]
        appearance.buttonAppearance = buttonAppearance
        appearance.backButtonAppearance = buttonAppearance // Apply to back button too

        // Apply the appearance settings
        UINavigationBar.appearance().standardAppearance = appearance
        U UINavigationBar.appearance().scrollEdgeAppearance = appearance // Used when content scrolls under navbar
        UINavigationBar.appearance().compactAppearance = appearance // For compact nav bars

        // Optional: Set the tint color for the back button arrow and other bar button items if not covered by UIBarButtonItemAppearance
         UINavigationBar.appearance().tintColor = UIColor(Theme.pokemonWhite)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
