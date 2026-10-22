import SwiftUI

struct BlockOverlayView: View {
    
    @ObservedObject var siteManager: SiteManager
    
    // Get version number automatically from app settings
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 55))
                        .foregroundColor(.red)
                }
                
                Text("Time's Up!")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Instagram is blocked.")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                ZStack {
                    Circle()
                        .stroke(Color.red.opacity(0.3), lineWidth: 14)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(
                            from: 0,
                            to: CGFloat(siteManager.blockTimeRemaining) / 7200
                        )
                        .stroke(
                            Color.red,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(
                            .linear(duration: 1),
                            value: siteManager.blockTimeRemaining
                        )
                    
                    VStack(spacing: 4) {
                        Text(siteManager.timeString(from: siteManager.blockTimeRemaining))
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundColor(.red)
                        
                        Text("until unblocked")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("💪 Stay Strong!")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("You made a commitment to focus.\nThis block is protecting your time.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Version stamp at bottom
                Text("FocusGuard \(appVersion)")
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.4))
                    .padding(.bottom, 20)
            }
        }
    }
}
