import SwiftUI

struct StationPopupFullScreenView: View {
    // MARK: - Inputs
    let station: Station
    let onUnlock: (MetroLine, @escaping (GameChallenge?) -> Void) -> Void
    let onClose: () -> Void
    let isSacrificed: Bool
    let failedChallenges: [GameChallenge]
    let controllingTeamName: String?
    let teamNames: [String: String]
    let myTeamID: String
    let selectedLine: MetroLine
    let allUnlocked: [GameChallenge]
    let allCompleted: [GameChallenge]
    let globalCompleted: [GameChallenge]
    let allOtherUnlocked: [String: [GameChallenge]]
    let teamCompletions: [String: [GameChallenge]]

    // MARK: - Bindings
    @Binding var selectedChallenge: GameChallenge?
    @Binding var selectedStation: Station?

    // MARK: - State
    @State private var currentLine: MetroLine
    @State private var isUnlocking = false
    @State private var showUnlockConfirm = false        // NEW

    // MARK: - Init
    init(
        station: Station,
        onUnlock: @escaping (MetroLine, @escaping (GameChallenge?) -> Void) -> Void,
        onClose: @escaping () -> Void,
        isSacrificed: Bool,
        failedChallenges: [GameChallenge],
        controllingTeamName: String?,
        teamNames: [String: String],
        myTeamID: String,
        selectedLine: MetroLine,
        allUnlocked: [GameChallenge],
        allCompleted: [GameChallenge],
        globalCompleted: [GameChallenge],
        allOtherUnlocked: [String: [GameChallenge]],
        teamCompletions: [String: [GameChallenge]],
        selectedChallenge: Binding<GameChallenge?>,
        selectedStation: Binding<Station?>
    ) {
        self.station            = station
        self.onUnlock           = onUnlock
        self.onClose            = onClose
        self.isSacrificed       = isSacrificed
        self.failedChallenges   = failedChallenges
        self.controllingTeamName = controllingTeamName
        self.teamNames          = teamNames
        self.myTeamID           = myTeamID
        self.selectedLine       = selectedLine
        self._currentLine       = State(initialValue: selectedLine)
        self.allUnlocked        = allUnlocked
        self.allCompleted       = allCompleted
        self.globalCompleted    = globalCompleted
        self.allOtherUnlocked   = allOtherUnlocked
        self.teamCompletions    = teamCompletions
        self._selectedChallenge = selectedChallenge
        self._selectedStation   = selectedStation
    }

    // MARK: - UI
    var body: some View {
        VStack(spacing: 16) {

            // ── Header ───────────────────────────────
            Text(station.name)
                .font(.largeTitle).bold()
                .padding(.top)

            // Multiple-line selector
            if station.lines.count > 1 {
                HStack {
                    Text("Viewing:").font(.subheadline)
                    ForEach(station.lines, id: \.self) { line in
                        Button {
                            currentLine = line
                        } label: {
                            Text(line.rawValue)
                                .padding(8)
                                .background(currentLine == line ? line.color
                                                               : Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                }
            }

            // Status
            Text("Status: \(statusText)")
                .font(.headline)
                .foregroundColor(statusColor)

            if let team = controllingTeamName {
                Text("Controlled by: \(team)").font(.subheadline)
            }

            // ── Current challenge (if any) ───────────
            if let challenge = currentChallenge {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Challenge").bold()
                    Button {
                        selectedChallenge = challenge
                        selectedStation   = nil
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challenge.title)
                            Text(challenge.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

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

            // ── Unlock button (with confirmation) ────
            if canUnlock {
                Button("Unlock on \(currentLine.rawValue) Line") {
                    showUnlockConfirm = true          // open dialog
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(currentLine.color)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            // Info messages for sacrificed/failed
            if isSacrificed {
                Text("You sacrificed this station. You cannot unlock its challenge.")
                    .font(.footnote).foregroundColor(.red).padding(.top, 8)
            }
            if isFailed {
                Text("You failed this station. You cannot unlock its challenge.")
                    .font(.footnote).foregroundColor(.red).padding(.top, 8)
            }

            // Close
            Button("Close", action: onClose)
                .foregroundColor(.blue)
                .padding(.top)

            Spacer()
        }
        .padding()
        // ── Confirmation dialog ─────────────────────
        .confirmationDialog(
            "Unlock challenge at \(station.name)?",
            isPresented: $showUnlockConfirm,
            titleVisibility: .visible
        ) {
            Button("Unlock", role: .none) {
                guard !isUnlocking else { return }
                isUnlocking = true
                onUnlock(currentLine) { newChallenge in
                    if let ch = newChallenge {
                        selectedChallenge = ch
                        selectedStation   = nil
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    // MARK: - Helpers / Computed
    private var canUnlock: Bool {
        !isUnlocked && !isCompleted && !isSacrificed && !isFailed && completedByTeamID == nil
    }

    private var isUnlocked: Bool {
        allUnlocked.contains { $0.station == station.name && $0.line == currentLine }
    }
    private var isCompleted: Bool {
        allCompleted.contains { $0.station == station.name && $0.line == currentLine }
    }
    private var isFailed: Bool {
        failedChallenges.contains { $0.station == station.name && $0.line == currentLine }
    }

    private var currentChallenge: GameChallenge? {
        (allUnlocked + globalCompleted + allOtherUnlocked.flatMap { $0.value })
            .first { $0.station == station.name && $0.line == currentLine }
    }

    private var completedByTeamID: String? {
        teamCompletions.first { _, challenges in
            challenges.contains { $0.station == station.name && $0.line == currentLine }
        }?.key
    }

    private var statusText: String {
        if let completedBy = completedByTeamID {
            return completedBy == myTeamID ? "Completed" : "Lost"
        } else if isSacrificed {
            return "Sacrificed"
        } else if isFailed {
            return "Failed"
        } else if isUnlocked {
            return "Unlocked"
        } else {
            return "Locked"
        }
    }

    private var statusColor: Color {
        if let completedBy = completedByTeamID {
            return completedBy == myTeamID ? .green : .red
        } else if isSacrificed || isFailed {
            return .red
        } else if isUnlocked {
            return .orange
        } else {
            return .gray
        }
    }
}
