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
        case .A: return .blue
        case .B: return .red
        case .D: return .purple
        case .E: return .yellow
        }
    }
}

let sampleStations: [Station] = [
    // A Line (Blue)
    Station(name: "Southwest Museum", x: 840, y: 141, lines: [.A]),
    Station(name: "Heritage Sq", x: 840, y: 198, lines: [.A]),
    Station(name: "Lincoln/Cypress", x: 840, y: 259, lines: [.A]),
    Station(name: "Chinatown", x: 840, y: 317, lines: [.A]),
    Station(name: "Little Tokyo/Arts Dist", x: 818, y: 506, lines: [.A, .E]),
    Station(name: "Grand Av Arts/Bunker Hill", x: 584, y: 411, lines: [.A, .E]),
    Station(name: "Civic Ctr/Grand Park", x: 706, y: 419, lines: [.B, .D]),
    Station(name: "Grand/LATTC", x: 457, y: 684, lines: [.A]),

    // B Line (Red)
    Station(name: "Hollywood/Vine", x: 244, y: 50, lines: [.B]),
    Station(name: "Hollywood/Western", x: 284, y: 101, lines: [.B]),
    Station(name: "Vermont/Sunset", x: 284, y: 161, lines: [.B]),
    Station(name: "Vermont/Santa Monica", x: 284, y: 221, lines: [.B]),
    Station(name: "Vermont/Beverly", x: 284, y: 279, lines: [.B]),
    Station(name: "Wilshire/Vermont", x: 281, y: 345, lines: [.B, .D]),

    // D Line (Purple)
    Station(name: "Wilshire/Normandie", x: 133, y: 338, lines: [.D]),
    Station(name: "Wilshire/Western", x: 33, y: 338, lines: [.D]),
    Station(name: "Westlake/MacArthur Park", x: 366, y: 431, lines: [.B, .D]),

    // E Line (Yellow)
    Station(name: "Pico/Aliso", x: 918, y: 500, lines: [.E]),
    Station(name: "Mariachi Plaza", x: 979, y: 500, lines: [.E]),
    Station(name: "Historic Broadway", x: 692, y: 506, lines: [.A, .E]),     // shared with A
    Station(name: "Pershing Square", x: 555, y: 493, lines: [.B, .D]),   // shared
    Station(name: "Pico", x: 403, y: 583, lines: [.E, .A]),
    Station(name: "LATTC/Ortho Institute", x: 353, y: 630, lines: [.E]),
    Station(name: "Jefferson/USC", x: 332, y: 686, lines: [.E]),
    Station(name: "Expo Park/USC", x: 237, y: 822, lines: [.E]),
    Station(name: "Expo/Vermont", x: 140, y: 822, lines: [.E]),
]
