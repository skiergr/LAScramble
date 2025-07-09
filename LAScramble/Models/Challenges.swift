import Foundation

import Foundation

struct GameChallenge: Identifiable, Equatable {
    var id: String { title + station }

    let title: String
    let description: String
    let station: String
    let line: MetroLine?
    let canFail: Bool?
}



