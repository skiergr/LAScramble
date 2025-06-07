//
//  UsernamePromptView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 6/1/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UsernamePromptView: View {
    let gameID: String
    let onComplete: (String) -> Void

    @State private var username = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Your Username")
                .font(.title2)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Continue") {
                logInWithUsername()
            }
            .disabled(username.isEmpty)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if let error = errorMessage {
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
    }

    func logInWithUsername() {
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                self.errorMessage = "Login failed: \(error.localizedDescription)"
                return
            }

            guard let uid = result?.user.uid else {
                self.errorMessage = "No UID returned"
                return
            }

            let db = Firestore.firestore()
            db.collection("games").document(gameID)
                .collection("players").document(uid)
                .setData([
                    "uid": uid,
                    "username": username,
                    "joined": Timestamp()
                ]) { err in
                    if let err = err {
                        self.errorMessage = "Save failed: \(err.localizedDescription)"
                    } else {
                        onComplete(username)
                    }
                }
        }
    }
}
