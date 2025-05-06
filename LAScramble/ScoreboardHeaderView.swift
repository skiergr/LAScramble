import SwiftUI

struct ScoreboardHeaderView: View {
    var controlledLineCounts: [String: Int]
    var teamNames: [String: String]
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Text("🏁 Line Control")
                .font(.headline)

            HStack {
                ForEach(controlledLineCounts.keys.sorted(), id: \.self) { teamID in
                    let teamLabel = teamNames[teamID] ?? "Team \(teamID.prefix(6))"
                    let linesControlled = controlledLineCounts[teamID] ?? 0
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
}
