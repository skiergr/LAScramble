import Foundation
import SwiftUI

struct Station: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let x: CGFloat
    let y: CGFloat
    let lines: [MetroLine]
}

let sampleStations: [Station] = [
    Station(name: "Mariachi Plaza", x: 100, y: 120, lines: [.E, .B]), // 👈 Now multi-line
    Station(name: "Grand/LATTC", x: 160, y: 190, lines: [.A]),
    Station(name: "Pico", x: 180, y: 210, lines: [.E]),
    Station(name: "Expo/Vermont", x: 220, y: 90, lines: [.E]),
    Station(name: "Hollywood/Vine", x: 290, y: 140, lines: [.B])
]


enum MetroLine: String, CaseIterable, Codable {
    case A, B, D, E

    var color: Color {
        switch self {
        case .A: return .yellow
        case .B: return .red
        case .D: return .purple
        case .E: return .blue
        }
    }
}
