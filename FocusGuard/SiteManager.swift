import Foundation
import Combine

class SiteManager: ObservableObject {
    
    @Published var isBlocked: Bool = false
    @Published var focusTimeRemaining: Int = 180
    @Published var blockTimeRemaining: Int = 7200
    @Published var timerActive: Bool = false
    
    private var timer: Timer?
    private let blockEndTimeKey = "blockEndTime"
    private let focusEndTimeKey = "focusEndTime"
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.restoreState()
        }
    }
    
    // MARK: Restore State
    func restoreState() {
        let now = Date()
        
        // Check block state first
        if let blockEndTime = UserDefaults.standard.object(
            forKey: blockEndTimeKey) as? Date {
            
            if blockEndTime > now {
                let remaining = Int(blockEndTime.timeIntervalSince(now))
                print("FocusGuard: Block active, \(remaining)s remaining")
                self.blockTimeRemaining = remaining
                self.isBlocked = true
                self.timerActive = false
                self.startBlockCountdown()
                return
            } else {
                print("FocusGuard: Block expired while closed")
                self.clearSavedState()
                return
            }
        }
        
        // Check focus timer state
        if let focusEndTime = UserDefaults.standard.object(
            forKey: focusEndTimeKey) as? Date {
            
            if focusEndTime > now {
                let remaining = Int(focusEndTime.timeIntervalSince(now))
                print("FocusGuard: Focus timer active, \(remaining)s remaining")
                self.focusTimeRemaining = remaining
                self.timerActive = true
                self.startFocusCountdown()
            } else {
                print("FocusGuard: Focus expired while closed, blocking now")
                self.clearSavedState()
                self.startBlock()
            }
        }
        
        print("FocusGuard: Fresh start")
    }
    
    // MARK: Start Focus Timer
    func startFocusTimer() {
        guard !timerActive && !isBlocked else { return }
        focusTimeRemaining = 90
        timerActive = true
        
        let endTime = Date().addingTimeInterval(90)
        UserDefaults.standard.set(endTime, forKey: focusEndTimeKey)
        print("FocusGuard: Focus timer started")
        
        startFocusCountdown()
    }
    
    // MARK: Focus Countdown
    private func startFocusCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { _ in
            DispatchQueue.main.async {
                if self.focusTimeRemaining > 0 {
                    self.focusTimeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                    self.clearFocusState()
                    self.startBlock()
                }
            }
        }
    }
    
    // MARK: Start Block
    func startBlock() {
        isBlocked = true
        timerActive = false
        blockTimeRemaining = 1800
        
        let endTime = Date().addingTimeInterval(1800)
        UserDefaults.standard.set(endTime, forKey: blockEndTimeKey)
        print("FocusGuard: Block started")
        
        startBlockCountdown()
    }
    
    // MARK: Block Countdown
    private func startBlockCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true
        ) { _ in
            DispatchQueue.main.async {
                if self.blockTimeRemaining > 0 {
                    self.blockTimeRemaining -= 1
                } else {
                    self.timer?.invalidate()
                    self.clearSavedState()
                    self.isBlocked = false
                    self.focusTimeRemaining = 90
                    self.blockTimeRemaining = 1800
                    print("FocusGuard: Block lifted!")
                }
            }
        }
    }
    
    // MARK: Clear States
    private func clearFocusState() {
        UserDefaults.standard.removeObject(forKey: focusEndTimeKey)
    }
    
    func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: blockEndTimeKey)
        UserDefaults.standard.removeObject(forKey: focusEndTimeKey)
    }
    
    // MARK: Time String
    func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
