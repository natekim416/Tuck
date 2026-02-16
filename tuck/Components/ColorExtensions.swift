import SwiftUI

extension Color {
    static func fromFolderName(_ name: String) -> Color {
        switch name.lowercased() {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "red": return .red
        case "yellow": return .yellow
        case "gray": return .gray
        default: return .blue
        }
    }
}
