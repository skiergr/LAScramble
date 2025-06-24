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
    var teamLineCounts: [String: [MetroLine: Int]]

    @Environment(\.presentationMode) var presentationMode
    @State private var showLeaderboard = false
    @State private var showRules = false
    @State private var showHelp = false
    @State private var showLeaveConfirmation = false
    @State private var leaveGame = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Game Menu")) {
                    Button("Leaderboard") {
                        showLeaderboard = true
                    }

                    Button("Leave Game") {
                        showLeaveConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)

            // Sheets
            .sheet(isPresented: $showLeaderboard) {
                ScoreDetailsView(
                    teamLineCounts: teamLineCounts,
                    teamNames: teamNames
                )
            }

            .sheet(isPresented: $showRules) {
                Text("Game Rules Go Here")
                    .padding()
            }

            .sheet(isPresented: $showHelp) {
                Text("Metro Help Content Here")
                    .padding()
            }

            .fullScreenCover(isPresented: $leaveGame) {
                GameMenuView()
            }

            // Confirmation Dialog
            .alert(isPresented: $showLeaveConfirmation) {
                Alert(
                    title: Text("Leave Game?"),
                    message: Text("Are you sure you want to leave the game?"),
                    primaryButton: .destructive(Text("Leave")) {
                        leaveGameAction()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    func leaveGameAction() {
        UserDefaults.standard.removeObject(forKey: "cachedGameID")
        UserDefaults.standard.removeObject(forKey: "cachedTeamID")
        leaveGame = true
    }

    func forfeitGame() {
        let db = Firestore.firestore()
        db.collection("games").document(gameID)
            .collection("teams").document(teamID)
            .updateData(["forfeited": true])

        print("Team \(teamID) forfeited the game")
    }
}
