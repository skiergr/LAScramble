import SwiftUI

struct StationPopupFullScreenView: View {
    let station: Station
    let onUnlock: (MetroLine) -> Void
    let onClose: () -> Void
    let isSacrificed: Bool
    let controllingTeamName: String?
    let teamNames: [String: String]
    let myTeamID: String
    let selectedLine: MetroLine
    let allUnlocked: [GameChallenge]
    let allCompleted: [GameChallenge]
    let globalCompleted: [GameChallenge]
    let allOtherUnlocked: [String: [GameChallenge]]
    let teamCompletions: [String: [GameChallenge]]

    @State private var isUnlocking = false
    @State private var currentLine: MetroLine

    init(
        station: Station,
        onUnlock: @escaping (MetroLine) -> Void,
        onClose: @escaping () -> Void,
        isSacrificed: Bool,
        controllingTeamName: String?,
        teamNames: [String: String],
        myTeamID: String,
        selectedLine: MetroLine,
        allUnlocked: [GameChallenge],
        allCompleted: [GameChallenge],
        globalCompleted: [GameChallenge],
        allOtherUnlocked: [String: [GameChallenge]],
        teamCompletions: [String: [GameChallenge]]
    ) {
        self.station = station
        self.onUnlock = onUnlock
        self.onClose = onClose
        self.isSacrificed = isSacrificed
        self.controllingTeamName = controllingTeamName
        self.teamNames = teamNames
        self.myTeamID = myTeamID
        self.selectedLine = selectedLine
        self._currentLine = State(initialValue: selectedLine)
        self.allUnlocked = allUnlocked
        self.allCompleted = allCompleted
        self.globalCompleted = globalCompleted
        self.allOtherUnlocked = allOtherUnlocked
        self.teamCompletions = teamCompletions
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(station.name)
                .font(.largeTitle)
                .bold()
                .padding(.top)

            if station.lines.count > 1 {
                HStack {
                    Text("Viewing:").font(.subheadline)
                    ForEach(station.lines, id: \.self) { line in
                        Button(action: {
                            currentLine = line
                        }) {
                            Text(line.rawValue)
                                .padding(8)
                                .background(currentLine == line ? line.color : Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                }
            }

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

            if !isUnlocked && !isCompleted && !isSacrificed && completedByTeamID == nil {
                Button(action: {
                    guard !isUnlocking else { return }
                    isUnlocking = true
                    onUnlock(currentLine)
                }) {
                    Text("Unlock on \(currentLine.rawValue) Line")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(currentLine.color)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            if isSacrificed {
                Text("You sacrificed this station. You cannot unlock its challenge.")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.top, 8)
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

    // MARK: - Derived Logic

    private var isUnlocked: Bool {
        allUnlocked.contains { $0.station == station.name && $0.line == currentLine }
    }

    private var isCompleted: Bool {
        allCompleted.contains { $0.station == station.name && $0.line == currentLine }
    }

    private var currentChallenge: GameChallenge? {
        (allUnlocked + globalCompleted + allOtherUnlocked.flatMap { $0.value })
            .first { $0.station == station.name && $0.line == currentLine }
    }

    private var completedByTeamID: String? {
        teamCompletions.first(where: { (_, challenges) in
            challenges.contains {
                $0.station == station.name && $0.line == currentLine
            }
        })?.key
    }

    private var statusText: String {
        if let completedBy = completedByTeamID {
            return completedBy == myTeamID ? "Completed" : "Lost"
        } else if isSacrificed {
            return "Sacrificed"
        } else if isUnlocked {
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
        } else if isUnlocked {
            return .orange
        } else {
            return .gray
        }
    }
}
