import SwiftUI

#if canImport(UIKit)
public struct PelotaSignalLaunchPanel: View {
    public let configuration: PelotaSignalConfiguration
    @AppStorage("appLanguage") private var preferredLanguage = "en"
    @State private var isLoading = false
    @State private var statusMessage: String?
    @State private var presentedDestination: PelotaSignalPresentedDestination?

    public init(configuration: PelotaSignalConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("BLZ Signal Check", systemImage: "antenna.radiowaves.left.and.right")
                .font(.headline)
                .foregroundStyle(PelotaSignalTheme.accent)

            Text("Checks the remote BLZ Pelota signal and opens the server-provided destination when available.")
                .font(.subheadline)
                .foregroundStyle(PelotaSignalTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await loadDestination() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(PelotaSignalTheme.navy)
                    }
                    Text(isLoading ? "Checking..." : "Check signal")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(PelotaSignalTheme.accent)
            .foregroundStyle(PelotaSignalTheme.navy)
            .disabled(isLoading)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(PelotaSignalTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PelotaSignalTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .fullScreenCover(item: $presentedDestination) { destination in
            PelotaSignalBrowserScreen(configuration: destination.configuration)
        }
        .pelotaSignalAudioAware()
    }

    @MainActor
    private func loadDestination() async {
        isLoading = true
        statusMessage = nil
        defer { isLoading = false }

        do {
            let client = PelotaSignalRequestClient(configuration: configuration)
            let decision = try await client.loadDecision(preferredLanguage: preferredLanguage)

            guard decision.enabled else {
                statusMessage = "No remote destination. Continuing with the native BLZ Pelota app."
                return
            }

            guard let url = decision.url else {
                statusMessage = "The signal was enabled but did not include a destination."
                return
            }

            presentedDestination = PelotaSignalPresentedDestination(
                configuration: configuration.resolvedDestination(url)
            )
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

public struct PelotaSignalPresentedDestination: Identifiable {
    public let id = UUID()
    public let configuration: PelotaSignalConfiguration

    public init(configuration: PelotaSignalConfiguration) {
        self.configuration = configuration
    }
}
#endif
