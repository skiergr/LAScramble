//
//  GameMenuView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/4/25.
//

import SwiftUI

struct GameMenuView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("LA Scramble")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Group {
                    NavigationLink(destination: CreateGameView()) {
                        menuButtonLabel("Create Game", color: .green)
                    }

                    NavigationLink(destination: JoinGameView()) {
                        menuButtonLabel("Join Game", color: .blue)
                    }

                    NavigationLink(destination: GalleryView()) {
                        menuButtonLabel("Gallery", color: .purple)
                    }

                    NavigationLink(destination: RulesView()) {
                        menuButtonLabel("Rules", color: .orange)
                    }

                    NavigationLink(destination: MissionView()) {
                        menuButtonLabel("Purpose / Mission", color: .gray)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }

    // Helper function for uniform button styling
    private func menuButtonLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
