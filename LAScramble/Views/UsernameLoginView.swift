import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UsernameLoginView: View {
    @State private var username = ""
    @State private var isLoggedIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your username to start")
                .font(.headline)

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Continue") {
                logInWithUsername()
            }
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

    func logInWithUsername() {
        guard !username.isEmpty else {
            errorMessage = "Please enter a username"
            return
        }

        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                errorMessage = "Login failed: \(error.localizedDescription)"
                return
            }

            guard let uid = result?.user.uid else {
                errorMessage = "Login failed: No user ID"
                return
            }

            let db = Firestore.firestore()
            db.collection("players").document(uid).setData([
                "username": username,
                "joined": Timestamp()
            ]) { error in
                if let error = error {
                    errorMessage = "Failed to save username: \(error.localizedDescription)"
                } else {
                    isLoggedIn = true
                }
            }
        }
    }
}
