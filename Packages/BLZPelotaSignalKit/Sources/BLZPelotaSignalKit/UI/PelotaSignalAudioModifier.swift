import SwiftUI

#if canImport(UIKit)
import UIKit

private struct PelotaSignalAudioModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                PelotaSignalRuntime.activateGameAudio()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                PelotaSignalRuntime.activateGameAudio()
            }
    }
}

extension View {
    func pelotaSignalAudioAware() -> some View {
        modifier(PelotaSignalAudioModifier())
    }
}
#endif
