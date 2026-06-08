import SwiftUI

struct AccessibilityPromptView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var checkTimer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.raised.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Accessibility Permission Required")
                .font(.title2.bold())

            Text("FigmaDock needs Accessibility access to simulate keyboard shortcuts in Figma and launch your plugins.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Label("Open System Settings → Privacy & Security", systemImage: "1.circle.fill")
                Label("Select Accessibility", systemImage: "2.circle.fill")
                Label("Enable FigmaDock", systemImage: "3.circle.fill")
            }
            .font(.callout)

            HStack(spacing: 12) {
                Button("Open System Settings") {
                    AccessibilityManager.requestTrust()
                }
                .buttonStyle(.borderedProminent)

                Button("Check Again") {
                    if AccessibilityManager.isTrusted {
                        dismiss()
                    }
                }
            }

            if AccessibilityManager.isTrusted {
                Label("Access granted!", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .onAppear { dismiss() }
            }
        }
        .padding(32)
        .frame(width: 420)
    }
}
