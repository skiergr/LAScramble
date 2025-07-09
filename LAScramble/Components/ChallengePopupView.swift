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
    
    @State private var showCompleteConfirm = false
    @State private var showSacrificeConfirm = false
    @State private var showFailConfirm = false

    var body: some View {
        VStack(spacing: 16) {
            Text(challenge.title)
                .font(.title2)
                .bold()

            Text("Station: \(challenge.station)")
                .font(.headline)

            if let station = selectedStation, !station.lines.isEmpty {
                Text("Line: \(station.lines.map { $0.rawValue }.joined(separator: ", "))")
                    .font(.subheadline)
            }

            Text(challenge.description)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)

            Button("Complete") {
                showCompleteConfirm = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .confirmationDialog("Mark this challenge complete?", isPresented: $showCompleteConfirm) {
                Button("Complete", role: .destructive) {
                    onComplete()
                }
                Button("Cancel", role: .cancel) {}
            }

            Button("Sacrifice") {
                showSacrificeConfirm = true
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(8)
            .confirmationDialog("Sacrifice this challenge?", isPresented: $showSacrificeConfirm) {
                Button("Sacrifice", role: .destructive) {
                    onSacrifice()
                }
                Button("Cancel", role: .cancel) {}
            }

            // ✅ Show this only if canFail is true
            if challenge.canFail == true {
                Button("Fail") {
                    showFailConfirm = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                .confirmationDialog("Fail this challenge?", isPresented: $showFailConfirm) {
                    Button("Fail", role: .destructive) {
                        onFail()
                    }
                    Button("Cancel", role: .cancel) {}
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
