//
//  MissionView.swift
//  LAScramble
//
//  Created by Grady Ramberg on 5/6/25.
//

import SwiftUI

struct MissionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 Purpose / Mission")
                .font(.largeTitle)
                .padding(.bottom)

            Text("LA Scramble was created to:")
            Text("• Encourage exploration of Los Angeles using the Metro.")
            Text("• Promote public transportation in a fun and competitive way.")
            Text("• Help people discover hidden gems around the city.")
            Text("• Build teamwork and creativity through citywide challenges.")

            Spacer()
        }
        .padding()
        .navigationTitle("Purpose / Mission")
    }
}
