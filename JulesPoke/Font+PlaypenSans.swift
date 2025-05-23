import SwiftUI

extension Font {
    /// Convenience helper for the Playpen Sans font
    static func playpenSans(size: CGFloat) -> Font {
        .custom("Playpen Sans", size: size)
    }
}

extension UIFont {
    /// Convenience helper for the Playpen Sans font
    static func playpenSans(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont(name: "Playpen Sans", size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
