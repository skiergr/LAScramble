import SwiftUI

struct ChallengePopupView: View {
    let challenge: GameChallenge
    var onComplete: () -> Void
    var onSacrifice: () -> Void
    var onClose: () -> Void
    @Binding var selectedStation: Station?
    @Binding var selectedChallenge: GameChallenge?

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(challenge.title)
                    .font(.title2)
                    .bold()

                Button(action: {
                    if let station = sampleStations.first(where: { $0.name == challenge.station }) {
                        selectedStation = station
                        selectedChallenge = nil
                    }
                }) {
                    Text("📍 \(challenge.station)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }

                Text(challenge.description)
                    .font(.body)
                    .padding(.horizontal)

                Button("✅ Mark as Complete") {
                    onComplete()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("⚠️ Sacrifice This Challenge") {
                    onSacrifice()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        onClose()
                    }
                }
            }
        }
    }
}
