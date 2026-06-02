import BLZPelotaSignalKit
import SwiftUI

@main
struct BLZPelotaMixtecaApp: App {
    @UIApplicationDelegateAdaptor(FirebaseAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            PelotaSignalRootFlow(
                configuration: .blzPelotaPreset,
                requestReviewBeforeCheck: false
            ) {
                ContentView()
            }
        }
    }
}
