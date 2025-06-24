import SwiftUI

struct ScoreboardHeaderView: View {
    var controlledLineCounts: [String: Int]
    var teamNames: [String: String]
    var onTap: () -> Void

    var body: some View {
        VStack(spacing: 2) {
            Text("Line Control")
                .font(.subheadline)
                .fontWeight(.semibold)

            HStack(spacing: 4) {
                ForEach(controlledLineCounts.keys.sorted(), id: \.self) { teamID in
                    let teamLabel = teamNames[teamID] ?? "Team \(teamID.prefix(6))"
                    let linesControlled = controlledLineCounts[teamID] ?? 0
                    Text("\(teamLabel): \(linesControlled)")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .onTapGesture { onTap() }
    }
}
