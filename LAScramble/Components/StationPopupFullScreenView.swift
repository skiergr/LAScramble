import SwiftUI

struct StationPopupFullScreenView: View {
    let station: Station
    let onUnlock: (_ selectedLine: MetroLine) -> Void
    let onClose: () -> Void
    let alreadyUnlocked: Bool

    @State private var selectedLine: MetroLine?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(station.name).font(.largeTitle)

                if station.lines.count > 1 {
                    Picker("Choose Line", selection: $selectedLine) {
                        ForEach(station.lines, id: \.self) { line in
                            Text(line.rawValue).tag(line)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                } else {
                    Text("Line: \(station.lines.first!.rawValue)")
                        .font(.headline)
                    // Auto-select single line
                    Color.clear.onAppear {
                        selectedLine = station.lines.first
                    }
                }

                if alreadyUnlocked {
                    Text("✅ Challenge already unlocked")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Button("Unlock Challenge") {
                        if let selected = selectedLine {
                            onUnlock(selected)
                            onClose()
                        }
                    }
                    .disabled(selectedLine == nil)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedLine == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back", action: onClose)
                }
            }
        }
    }
}
