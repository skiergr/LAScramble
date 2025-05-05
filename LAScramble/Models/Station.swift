import Foundation
import SwiftUI

struct Station: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let x: CGFloat
    let y: CGFloat
}

let sampleStations: [Station] = [
    Station(name: "Mariachi Plaza", x: 100, y: 120),
    Station(name: "Grand/LATTC", x: 160, y: 190),
    Station(name: "Pico", x: 180, y: 210),
    Station(name: "Expo/Vermont", x: 220, y: 300),
    Station(name: "Hollywood/Vine", x: 290, y: 360)
]
