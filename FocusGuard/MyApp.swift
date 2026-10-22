import SwiftUI

@main
struct FocusGuardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("✅ App launched successfully")
                }
        }
    }
}
