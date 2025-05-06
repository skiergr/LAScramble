import SwiftUI

struct ScoreDetailsView: View {
    var teamLineCounts: [String: [MetroLine: Int]]
    var teamNames: [String: String]

    var body: some View {
        NavigationView {
            List {
                ForEach(MetroLine.allCases, id: \.self) { line in
                    Section(header:
                        Text("LINE \(line.rawValue)")
                            .foregroundColor(line.color)
                    ) {
                        let allTeams = teamLineCounts.keys.sorted()
                        let maxCount = teamLineCounts.values.map { $0[line] ?? 0 }.max() ?? 0
                        let controllers = teamLineCounts.filter { $0.value[line] ?? 0 == maxCount && maxCount > 0 }.keys

                        if maxCount == 0 {
                            Text("Uncontrolled").foregroundColor(.gray)
                        } else {
                            ForEach(allTeams, id: \.self) { teamID in
                                let count = teamLineCounts[teamID]?[line] ?? 0
                                let teamLabel = teamNames[teamID] ?? teamID
                                HStack {
                                    Text(teamLabel)
                                    Spacer()
                                    Text("\(count) stations")
                                }
                                .foregroundColor(controllers.contains(teamID) ? .green : .primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Line Control Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

