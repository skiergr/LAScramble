//
//  LobbyView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/5/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LobbyView: View {
    var gameID: String
    var teamID: String

    @State private var teams: [String: [String]] = [:] // [teamName: [usernames]]
    @State private var isCreator = false
    @State private var hasStarted = false

    var body: some View {
        VStack {
            Text("🕹️ Lobby").font(.largeTitle).padding()

            ScrollView {
                ForEach(teams.keys.sorted(), id: \.self) { team in
                    VStack(alignment: .leading) {
                        Text(team).font(.headline)
                        ForEach(teams[team] ?? [], id: \.self) { player in
                            Text("👤 \(player)")
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }

            if isCreator {
                Button("Start Game") {
                    startGame()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
            }

        }
        .onAppear {
            fetchTeamsAndPlayersLive()
            checkIfCreator()
            listenForStart()
        }
        .fullScreenCover(isPresented: $hasStarted) {
            MainGameScreenView(gameID: gameID, teamID: teamID)
        }
    }

    func fetchTeamsAndPlayersLive() {
        let db = Firestore.firestore()
        let teamsRef = db.collection("games").document(gameID).collection("teams")

        teamsRef.addSnapshotListener { snapshot, _ in
            guard let teamDocs = snapshot?.documents else { return }

            var updatedTeams: [String: [String]] = [:]

            for doc in teamDocs {
                let teamID = doc.documentID
                let teamName = doc.data()["teamName"] as? String ?? teamID

                db.collection("games").document(gameID)
                    .collection("teams").document(teamID)
                    .collection("players")
                    .addSnapshotListener { playerSnapshot, _ in
                        let usernames = playerSnapshot?.documents.map {
                            $0.data()["username"] as? String ?? "Unknown"
                        } ?? []

                        DispatchQueue.main.async {
                            updatedTeams[teamName] = usernames
                            self.teams = updatedTeams
                        }
                    }
            }
        }
    }


    func checkIfCreator() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("games").document(gameID).getDocument { snapshot, _ in
            let creatorID = snapshot?.data()?["createdBy"] as? String ?? ""
            self.isCreator = (creatorID == uid)
        }
    }

    func startGame() {
        Firestore.firestore().collection("games").document(gameID).updateData([
            "hasStarted": true,
            "startTime": Timestamp()
        ])
    }

    func listenForStart() {
        Firestore.firestore().collection("games").document(gameID)
            .addSnapshotListener { snapshot, _ in
                let started = snapshot?.data()?["hasStarted"] as? Bool ?? false
                if started {
                    self.hasStarted = true
                }
            }
    }
}
