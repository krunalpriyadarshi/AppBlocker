import SwiftUI
import WebKit

struct ContentView: View {
    
    @StateObject private var siteManager = SiteManager()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                topBar
                webContent
            }
            
            // Block overlay sits on top
            if siteManager.isBlocked {
                BlockOverlayView(siteManager: siteManager)
                    .transition(.opacity)
                    .zIndex(999)
                    // Intercept ALL touches when blocked
                    .allowsHitTesting(true)
                    .ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: siteManager.isBlocked)
        .onAppear {
            if !siteManager.isBlocked && !siteManager.timerActive {
                siteManager.startFocusTimer()
            }
        }
        // Detect app coming back to foreground
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification
            )
        ) { _ in
            siteManager.restoreState()
        }
    }
    
    // MARK: Web Content
    var webContent: some View {
        ZStack {
            WebBrowserView(url: URL(string: "https://www.instagram.com")!)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
                // Disable ALL interaction when blocked
                .allowsHitTesting(!siteManager.isBlocked)
                // Blur instagram when blocked
                .blur(radius: siteManager.isBlocked ? 20 : 0)
                .animation(.easeInOut(duration: 0.3), value: siteManager.isBlocked)
        }
    }
    
    // MARK: Top Bar
    var topBar: some View {
        HStack {
            Text("FocusGuard")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            timerBadge
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [Color.purple, Color.pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // MARK: Timer Badge
    var timerBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: timerIcon)
                .foregroundColor(timerIconColor)
            Text(timerText)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
    }
    
    // MARK: Computed Properties
    var timerIcon: String {
        if siteManager.isBlocked { return "hand.raised.fill" }
        return siteManager.timerActive ? "timer" : "checkmark.circle.fill"
    }
    
    var timerIconColor: Color {
        if siteManager.isBlocked { return .red }
        return siteManager.timerActive ? .yellow : .green
    }
    
    var timerText: String {
        if siteManager.isBlocked {
            return siteManager.timeString(from: siteManager.blockTimeRemaining)
        }
        return siteManager.timerActive
            ? siteManager.timeString(from: siteManager.focusTimeRemaining)
            : "Ready"
    }
}
