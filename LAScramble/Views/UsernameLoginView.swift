import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UsernameLoginView: View {
    @State private var username = ""
    @State private var teamName = ""
    @State private var isLoggedIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your info to start")
                .font(.headline)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Team Name", text: $teamName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Continue") {
                logInWithUserInfo()
            }
            .disabled(username.isEmpty || teamName.isEmpty)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            if let error = errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .fullScreenCover(isPresented: $isLoggedIn) {
            GameMenuView()
        }
    }

    func logInWithUserInfo() {
        guard !username.isEmpty && !teamName.isEmpty else {
            errorMessage = "Enter both username and team name"
            return
        }

        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                errorMessage = "Login failed: \(error.localizedDescription)"
                return
            }

            guard let uid = result?.user.uid else {
                errorMessage = "No UID returned"
                return
            }

            let db = Firestore.firestore()
            db.collection("players").document(uid).setData([
                "username": username,
                "teamName": teamName,
                "joined": Timestamp()
            ]) { error in
                if let error = error {
                    errorMessage = "Failed to save info: \(error.localizedDescription)"
                } else {
                    isLoggedIn = true
                }
            }
        }
    }
}
