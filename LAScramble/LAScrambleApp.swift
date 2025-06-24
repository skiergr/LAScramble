//
//  LAScrambleApp.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/4/25.
//

import SwiftUI
import Firebase

@main
struct LAScrambleApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootEntryView()
                .preferredColorScheme(.light)
        }
    }
}

struct RootEntryView: View {
    @State private var gameID: String? = UserDefaults.standard.string(forKey: "cachedGameID")
    @State private var teamID: String? = UserDefaults.standard.string(forKey: "cachedTeamID")

    var body: some View {
        if let gameID = gameID, let teamID = teamID {
            MainGameScreenView(gameID: gameID, teamID: teamID)
        } else {
            GameMenuView()
        }
    }
}
