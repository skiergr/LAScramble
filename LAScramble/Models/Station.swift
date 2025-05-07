import Foundation
import SwiftUI

struct Station: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let x: CGFloat
    let y: CGFloat
    let lines: [MetroLine]
}

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

let sampleStations: [Station] = [
    Station(name: "Mariachi Plaza", x: 100, y: 120, lines: [.E, .B]),
    Station(name: "Grand/LATTC", x: 160, y: 190, lines: [.A]),
    Station(name: "Pico", x: 180, y: 210, lines: [.E]),
    Station(name: "Expo/Vermont", x: 220, y: 90, lines: [.E]),
    Station(name: "Hollywood/Vine", x: 290, y: 140, lines: [.B]),
    Station(name: "Union Station", x: 240, y: 160, lines: [.B, .D]),
    Station(name: "Pershing Square", x: 200, y: 150, lines: [.D]),
    Station(name: "7th Street/Metro Center", x: 190, y: 170, lines: [.A, .D])
]
