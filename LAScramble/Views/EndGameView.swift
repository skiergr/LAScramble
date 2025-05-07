//
//  EndGameView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/5/25.
//

import SwiftUI
import FirebaseFirestore

struct EndGameView: View {
    let gameID: String

    @Environment(\.presentationMode) var presentationMode

    @State private var teamLineCounts: [String: [MetroLine: Int]] = [:]
    @State private var teamChallengeCounts: [String: Int] = [:]
    @State private var teamNames: [String: String] = [:]
    @State private var winnerTeamID: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Game Over").font(.largeTitle).bold()

            if let winner = winnerTeamID {
                Text("Winner: \(teamNames[winner] ?? winner)").font(.title2).padding()
            }

            ScrollView {
                ForEach(teamNames.keys.sorted(), id: \.self) { teamID in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(teamNames[teamID] ?? teamID)").font(.headline)

                        if let lineData = teamLineCounts[teamID] {
                            ForEach(MetroLine.allCases, id: \.self) { line in
                                let count = lineData[line] ?? 0
                                Text("🛤 Line \(line.rawValue): \(count) station(s)")
                            }
                        }

                        Text("Challenges Completed: \(teamChallengeCounts[teamID] ?? 0)")
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }

            Button("Return to Home") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .onAppear {
            fetchGameSummary()
        }
    }

    func fetchGameSummary() {
        let db = Firestore.firestore()
        let teamsRef = db.collection("games").document(gameID).collection("teams")

        teamsRef.getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }

            var tempNames: [String: String] = [:]
            var tempLineCounts: [String: [MetroLine: Set<String>]] = [:]
            var tempChallengeCounts: [String: Int] = [:]

            let dispatch = DispatchGroup()

            for doc in docs {
                let teamID = doc.documentID
                let teamName = doc.data()["teamName"] as? String ?? teamID
                tempNames[teamID] = teamName

                let completedRef = teamsRef.document(teamID).collection("completedChallenges")
                dispatch.enter()
                completedRef.getDocuments { challengeDocs, _ in
                    let challenges = challengeDocs?.documents ?? []

                    // Challenge count
                    tempChallengeCounts[teamID] = challenges.count

                    // Line → station tracking
                    for doc in challenges {
                        let station = doc.data()["station"] as? String ?? ""
                        let lineRaw = doc.data()["line"] as? String ?? ""
                        if let line = MetroLine(rawValue: lineRaw) {
                            tempLineCounts[teamID, default: [:]][line, default: []].insert(station)
                        }
                    }

                    dispatch.leave()
                }
            }

            dispatch.notify(queue: .main) {
                // Convert Set<String> station lists to Int counts
                var lineCounts: [String: [MetroLine: Int]] = [:]
                for (team, lines) in tempLineCounts {
                    for (line, stations) in lines {
                        lineCounts[team, default: [:]][line] = stations.count
                    }
                }

                self.teamNames = tempNames
                self.teamLineCounts = lineCounts
                self.teamChallengeCounts = tempChallengeCounts

                determineWinner()
            }
        }
    }

    func determineWinner() {
        var bestTeam: String?
        var bestLineTotal = -1

        for (teamID, lines) in teamLineCounts {
            let totalLinesControlled = lines.values.filter { $0 > 0 }.count
            if totalLinesControlled > bestLineTotal {
                bestTeam = teamID
                bestLineTotal = totalLinesControlled
            }
        }

        self.winnerTeamID = bestTeam
    }
}
