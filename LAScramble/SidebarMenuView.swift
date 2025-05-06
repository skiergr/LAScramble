//
//  SidebarMenuView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/5/25.
//

import SwiftUI
import FirebaseFirestore

struct SidebarMenuView: View {
    var gameID: String
    var teamID: String
    var teamNames: [String: String]

    @State private var showLeaderboard = false
    @State private var showRules = false
    @State private var showHelp = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Game Menu")) {
                    Button("📊 Leaderboard") { showLeaderboard = true }
                    Button("🏁 Completed Challenges") {
                        // Could push a ChallengeListView here
                    }
                    Button("📜 Rules") { showRules = true }
                    Button("🚇 Metro Help") { showHelp = true }
                    Button("❌ Forfeit Game") {
                        forfeitGame()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showLeaderboard) {
                ScoreDetailsView(
                    teamLineCounts: [:], // pass real data if needed
                    teamNames: teamNames
                )
            }
            .sheet(isPresented: $showRules) {
                Text("📜 Game Rules Go Here") // Replace with full RulesView later
                    .padding()
            }
            .sheet(isPresented: $showHelp) {
                Text("🚇 Metro Help Content Here") // Replace with MetroHelpView
                    .padding()
            }
        }
    }

    func forfeitGame() {
        let db = Firestore.firestore()
        db.collection("games").document(gameID)
            .collection("teams").document(teamID)
            .updateData(["forfeited": true])

        print("🚨 Team \(teamID) forfeited the game")
    }
}
