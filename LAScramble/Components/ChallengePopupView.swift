import SwiftUI
import FirebaseFirestore

struct ChallengePopupView: View {
    let challenge: GameChallenge
    let gameID: String
    let teamID: String
    let onComplete: () -> Void
    let onSacrifice: () -> Void
    let onFail: () -> Void
    let onClose: () -> Void

    @Binding var selectedStation: Station?
    @Binding var selectedChallenge: GameChallenge?

    var body: some View {
        VStack(spacing: 16) {
            Text(challenge.title)
                .font(.title2)
                .bold()

            Text("Station: \(challenge.station)")
                .font(.headline)

            if let line = challenge.line {
                Text("Line: \(line.rawValue)")
                    .font(.subheadline)
            }

            Text(challenge.description)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)

            Button(action: onComplete) {
                Text("Complete")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: onSacrifice) {
                Text("Sacrifice")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            // ✅ Show this only if canFail is true
            if challenge.canFail == true {
                Button(action: onFail) {
                    Label("Fail", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            Button("Close") {
                onClose()
            }
            .padding(.top, 8)
        }
        .padding()
    }
}
