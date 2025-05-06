import SwiftUI

struct ScoreboardHeaderView: View {
    var teamLineCounts: [String: [MetroLine: Int]]
    var teamNames: [String: String]
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Text("🏁 Line Control")
                .font(.headline)

            HStack {
                ForEach(teamLineCounts.keys.sorted(), id: \.self) { teamID in
                    let teamLabel = teamNames[teamID] ?? "Team \(teamID.prefix(6))"
                    let linesControlled = controlledLines(for: teamID)
                    Text("\(teamLabel): \(linesControlled) lines")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .onTapGesture { onTap() }
    }

    func controlledLines(for team: String) -> Int {
        MetroLine.allCases.filter { line in
            let maxCount = teamLineCounts.mapValues { $0[line] ?? 0 }
            let topTeam = maxCount.max { $0.value < $1.value }?.key
            return topTeam == team && maxCount[team, default: 0] > 0
        }.count
    }
}
