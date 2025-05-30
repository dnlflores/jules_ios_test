import SwiftUI

struct FlexibleFlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State private var availableWidth: CGFloat = 0

    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }

            VStack(alignment: alignment, spacing: spacing) {
                ForEach(computeRows(), id: \.self) { rowElements in
                    HStack(spacing: spacing) {
                        ForEach(rowElements, id: \.self) { element in
                            content(element)
                        }
                    }
                }
            }
        }
    }

    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRowWidth: CGFloat = 0
        
        guard availableWidth > 0 else { // Ensure availableWidth is positive
            if !data.isEmpty { // If data is not empty, return it as a single row to render something
                 return [Array(data)]
            }
            return [] // No width, no data, no rows
        }

        for element in data {
            // This is a simplified width estimation.
            // For TypeBadgeView, a more accurate measurement would involve PreferenceKeys
            // or a fixed size if all badges are similar.
            // Let's estimate based on character count of the typeName (assuming element is String).
            let elementText = String(describing: element) // Works if element is String, adapt if not
            let estimatedElementWidth = CGFloat(elementText.count) * 8 + 40 // Approx. char width * count + padding/spacing
                                                                      // (8 for char width, 40 for horizontal padding + potential icon)

            if currentRowWidth + estimatedElementWidth + (rows.last!.isEmpty ? 0 : spacing) > availableWidth {
                if rows.last!.isEmpty { // If the first element itself is too wide
                     rows[rows.count - 1].append(element) // Add it to the current row (it will overflow)
                     rows.append([]) // Start a new row for subsequent elements
                     currentRowWidth = 0 // Reset for the new row started for others
                } else {
                    rows.append([element]) // Start a new row
                    currentRowWidth = estimatedElementWidth
                }
            } else {
                rows[rows.count - 1].append(element)
                currentRowWidth += estimatedElementWidth + (rows.last!.count == 1 ? 0 : spacing)
            }
        }
        return rows.filter { !$0.isEmpty } // Ensure no empty rows are returned
    }
}

// Helper to read view size
struct ReadSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: ReadSizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(ReadSizePreferenceKey.self, perform: onChange)
    }
}

// Preview for FlexibleFlowLayout (Optional but good for testing)
struct FlexibleFlowLayout_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTypes = ["fire", "water", "grass", "electric", "psychic", "normal", "fighting", "flying", "poison", "ground", "rock", "bug", "ghost", "steel", "dragon", "dark", "fairy", "shadowmagiclongtype"]
        
        ScrollView {
            VStack(alignment: .leading) {
                Text("Layout with Type Badges:")
                    .font(.headline)
                FlexibleFlowLayout(data: sampleTypes, spacing: 8, alignment: .leading) { typeName in
                    TypeBadgeView(typeName: typeName)
                }
                .padding()
                .background(Color.gray.opacity(0.2))

                Text("Layout with Simple Text:")
                    .font(.headline)
                    .padding(.top)
                FlexibleFlowLayout(data: sampleTypes.map { $0.capitalized }, spacing: 10, alignment: .leading) { text in
                    Text(text)
                        .padding(8)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(5)
                }
                .padding()
                .background(Color.green.opacity(0.2))
            }
            .padding()
        }
    }
}
