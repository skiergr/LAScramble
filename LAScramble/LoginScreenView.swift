//
//  LoginScreenView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/4/25.
//

import SwiftUI
import FirebaseAuth

struct LoginScreenView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false

    var body: some View {
        VStack {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button("Login") {
                login()
            }
            Button("Create Account") {
                createAccount()
            }
        }
        .padding()
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if result != nil {
                isLoggedIn = true
            }
        }
    }

    func createAccount() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if result != nil {
                isLoggedIn = true
            }
        }
    }
}
