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
    case A, B, D, E, C, K

    var color: Color {
        switch self {
        case .A: return .blue
        case .B: return .red
        case .D: return .purple
        case .E: return .yellow
        case .C: return .green
        case .K: return Color(red: 1.0, green: 0.2, blue: 0.6)
        }
    }
}

let sampleStations: [Station] = [
    // E Line (Yellow)
    Station(name: "Mariachi Plaza", x: 2162, y: 1092, lines: [.E]),
    Station(name: "Pico/Aliso", x: 2071, y: 1092, lines: [.E]),
    Station(name: "Little Tokyo/Arts Dist", x: 1909, y: 1092, lines: [.E, .A]),
    Station(name: "Historic Broadway", x: 1726, y: 1092, lines: [.E, .A]),
    Station(name: "Grand Av Arts/Bunker Hill", x: 1554, y: 950, lines: [.E, .A]),
    Station(name: "7th St/Metro Ctr", x: 1351, y: 1135, lines: [.E, .A, .B, .D]),
    Station(name: "Pico", x: 1279, y: 1220, lines: [.E, .A]),
    Station(name: "LATTC/Ortho Institute", x: 1201, y: 1288, lines: [.E]),
    Station(name: "Jefferson/USC", x: 1175, y: 1369, lines: [.E]),
    Station(name: "Expo Park/USC", x: 1020, y: 1589, lines: [.E]),
    Station(name: "Expo/Vermont", x: 876, y: 1589, lines: [.E]),
    Station(name: "Expo/Western", x: 728, y: 1589, lines: [.E]),
    Station(name: "Expo/Crenshaw", x: 584, y: 1589, lines: [.E, .K]),
    Station(name: "Farmdale", x: 475, y: 1589, lines: [.E]),
    Station(name: "Expo/La Brea", x: 367, y: 1589, lines: [.E]),
    Station(name: "La Cienega/Jefferson", x: 263, y: 1589, lines: [.E]),
    Station(name: "Culver City", x: 156, y: 1589, lines: [.E]),
    
    // A Line (Blue)
    Station(name: "Memorial Park", x: 1960, y: 91, lines: [.A]),
    Station(name: "Del Mar", x: 1960, y: 185, lines: [.A]),
    Station(name: "Filmore", x: 1960, y: 271, lines: [.A]),
    Station(name: "South Pasadena", x: 1960, y: 366, lines: [.A]),
    Station(name: "Highland Park", x: 1960, y: 453, lines: [.A]),
    Station(name: "Southwest Museum", x: 1960, y: 540, lines: [.A]),
    Station(name: "Heritage Sq", x: 1960, y: 630, lines: [.A]),
    Station(name: "Lincoln/Cypress", x: 1960, y: 726, lines: [.A]),
    Station(name: "Chinatown", x: 1960, y: 811, lines: [.A]),
    Station(name: "Union Station", x: 1960, y: 970, lines: [.A, .B, .D]),
    Station(name: "Grand/LATTC", x: 1362, y: 1373, lines: [.A]),
    Station(name: "San Pedro St", x: 1480, y: 1493, lines: [.A]),
    Station(name: "Washington", x: 1554, y: 1604, lines: [.A]),
    Station(name: "Vernon", x: 1554, y: 1709, lines: [.A]),
    Station(name: "Slauson", x: 1554, y: 1822, lines: [.A]),
    Station(name: "Florence", x: 1554, y: 1944, lines: [.A]),
    Station(name: "Firestone", x: 1554, y: 2049, lines: [.A]),
    Station(name: "103rd ST/Watts Towers", x: 1554, y: 2164, lines: [.A]),
    Station(name: "Willowbrook/Rosa Parks", x: 1550, y: 2372, lines: [.A, .C]),
    
    // C Line (Green)
    Station(name: "Avalon", x: 1358, y: 2372, lines: [.C]),
    Station(name: "Harbor Fwy", x: 1173, y: 2372, lines: [.C]),
    Station(name: "Vermont/Athens", x: 1050, y: 2372, lines: [.C]),
    Station(name: "Crenshaw", x: 924, y: 2372, lines: [.C]),
    Station(name: "Hawthorne/Lennox", x: 802, y: 2372, lines: [.C]),
    Station(name: "Aviation/Imperial", x: 682, y: 2372, lines: [.C]),
    Station(name: "Aviation/Century", x: 588, y: 2319, lines: [.C, .K]),
    Station(name: "LAX/Metro Transit Center", x: 588, y: 2223, lines: [.C, .K]),

    // K Line (Pink)
    Station(name: "Westchester/Veterans", x: 588, y: 2123, lines: [.K]),
    Station(name: "Downtown Inglewood", x: 588, y: 2032, lines: [.K]),
    Station(name: "Fairview Heights", x: 588, y: 1949, lines: [.K]),
    Station(name: "Hyde Park", x: 588, y: 1862, lines: [.K]),
    Station(name: "Leimert Park", x: 588, y: 1783, lines: [.K]),
    Station(name: "MLK Jr", x: 588, y: 1694, lines: [.K]),
    
    // B Line (Red)
    Station(name: "North Hollywood", x: 759, y:127, lines: [.B]),
    Station(name: "Universal City/Studio City", x: 850, y: 222, lines: [.B]),
    Station(name: "Hollywood/Highland", x: 943, y: 313, lines: [.B]),
    Station(name: "Hollywood/Vine", x: 1036, y: 404, lines: [.B]),
    Station(name: "Hollywood/Western", x: 1096, y: 484, lines: [.B]),
    Station(name: "Vermont/Sunset", x: 1096, y: 575, lines: [.B]),
    Station(name: "Vermont/Santa Monica", x: 1096, y: 666, lines: [.B]),
    Station(name: "Vermont/Beverly", x: 1096, y: 759, lines: [.B]),
    Station(name: "Wilshire/Vermont", x: 1096, y: 856, lines: [.B, .D]),
    Station(name: "Westlake/MacArthur Park", x: 1224, y: 988, lines: [.B, .D]),
    Station(name: "Pershing Square", x: 1514, y: 1090, lines: [.B, .D]),
    Station(name: "Civic Ctr/Grand Park", x: 1739, y: 975, lines: [.B, .D]),

    // D Line (Purple)
    Station(name: "Wilshire/Normandie", x: 867, y: 853, lines: [.D]),
    Station(name: "Wilshire/Western", x: 718, y: 853, lines: [.D]),

]
