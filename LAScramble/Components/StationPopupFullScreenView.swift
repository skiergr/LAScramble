import SwiftUI

struct StationPopupFullScreenView: View {
    let station: Station
    let onUnlock: (MetroLine) -> Void
    let onClose: () -> Void

    let alreadyUnlocked: Bool
    let isCompleted: Bool
    let isSacrificed: Bool

    let controllingTeamName: String?
    let currentChallenge: GameChallenge?
    let completedByTeamID: String?
    let teamNames: [String: String]
    let myTeamID: String

    @State private var isUnlocking = false

    var body: some View {
        VStack(spacing: 16) {
            Text(station.name)
                .font(.largeTitle)
                .bold()
                .padding(.top)

            Text("Status: \(statusText)")
                .font(.headline)
                .foregroundColor(statusColor)

            if let team = controllingTeamName {
                Text("Controlled by: \(team)")
                    .font(.subheadline)
            }

            if let challenge = currentChallenge {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Challenge").bold()
                    Text(challenge.title)
                    Text(challenge.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if let completedTeam = completedByTeamID {
                        Text("Completed by: \(teamNames[completedTeam] ?? completedTeam)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }

            if !alreadyUnlocked && !isCompleted && !isSacrificed && completedByTeamID == nil {
                VStack(spacing: 8) {
                    ForEach(station.lines, id: \.self) { line in
                        Button(action: {
                            guard !isUnlocking else { return }
                            isUnlocking = true
                            onUnlock(line)
                        }) {
                            Text("Unlock on \(line.rawValue) Line")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(line.color)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }

            Button("Close") {
                onClose()
            }
            .foregroundColor(.blue)
            .padding(.top)

            Spacer()
        }
        .padding()
    }

    private var statusText: String {
        if let completedBy = completedByTeamID {
            return completedBy == myTeamID ? "Completed" : "Lost"
        } else if isSacrificed {
            return "Sacrificed"
        } else if alreadyUnlocked {
            return "Unlocked"
        } else {
            return "Locked"
        }
    }

    private var statusColor: Color {
        if let completedBy = completedByTeamID {
            return completedBy == myTeamID ? .green : .red
        } else if isSacrificed {
            return .red
        } else if alreadyUnlocked {
            return .orange
        } else {
            return .gray
        }
    }
}
