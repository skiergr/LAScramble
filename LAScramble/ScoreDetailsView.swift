import SwiftUI

struct ScoreDetailsView: View {
    var teamLineCounts: [String: [MetroLine: Int]]
    var teamNames: [String: String]

    var body: some View {
        NavigationView {
            List {
                // 🔼 Summary section at the top
                Section(header: Text("Team Scores").font(.headline)) {
                    let lineWinners: [MetroLine: String] = {
                        var result = [MetroLine: String]()
                        for line in MetroLine.allCases {
                            let maxCount = teamLineCounts.values.map { $0[line] ?? 0 }.max() ?? 0
                            let contenders = teamLineCounts.filter { $0.value[line] ?? 0 == maxCount && maxCount > 0 }
                            if contenders.count == 1 {
                                result[line] = contenders.first!.key
                            }
                        }
                        return result
                    }()

                    let teamScore: [String: Int] = {
                        var score = [String: Int]()
                        for (_, winner) in lineWinners {
                            score[winner, default: 0] += 1
                        }
                        return score
                    }()

                    ForEach(teamScore.keys.sorted(), id: \.self) { teamID in
                        let name = teamNames[teamID] ?? "Team \(teamID.prefix(6))"
                        let score = teamScore[teamID] ?? 0
                        HStack {
                            Text(name)
                            Spacer()
                            Text("\(score) lines")
                        }
                        .foregroundColor(.blue)
                    }
                }

                // 🔽 Existing per-line control breakdown
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
                                let teamLabel = teamNames[teamID] ?? "Team \(teamID.prefix(6))"
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
