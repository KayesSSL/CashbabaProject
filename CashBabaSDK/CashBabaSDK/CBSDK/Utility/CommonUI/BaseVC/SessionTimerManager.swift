import Foundation
import UIKit

public final class SessionTimerManager {
    public static let shared = SessionTimerManager()
    private var timer: Timer?
    private var expiryDate: Date? // Absolute expiry timestamp
    public private(set) var isTimerRunning = false // Track whether timer is running
    
    private init() {
        // Observe app lifecycle to recalculate timer when returning from background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // Computed property: calculates remaining seconds from absolute expiry time
    public var remainingSeconds: Int {
        guard let expiry = expiryDate else {
            print("[SessionTimer] No expiry date set, returning 0")
            return 0
        }
        let remaining = expiry.timeIntervalSinceNow
        let seconds = max(0, Int(remaining))
        return seconds
    }
    
    // Start the timer with an optional custom duration (always on main run loop)
    public func start(with seconds: Int? = nil) {
        guard let seconds = seconds else {
            print("[SessionTimer] start() called with nil seconds")
            return
        }
        
        print("[SessionTimer] start() called with \(seconds) seconds, on main thread: \(Thread.isMainThread)")
        
        // Ensure we're on main thread
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.start(with: seconds)
            }
            return
        }
        
        // Calculate absolute expiry time (wall-clock time)
        self.expiryDate = Date().addingTimeInterval(TimeInterval(seconds))
        print("[SessionTimer] expiryDate set to \(self.expiryDate!), remainingSeconds=\(self.remainingSeconds)")
        
        // If timer is already running, just update expiry and notify
        if self.isTimerRunning {
            print("[SessionTimer] Timer already running, updating expiry only")
            self.notifyTick()
            return
        }

        // Stop any existing timer (but keep expiryDate that was just set)
        stopTimerOnly()

        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(Self.tick), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: .common)
        self.isTimerRunning = true
        print("[SessionTimer] Timer created and added to RunLoop, isRunning=\(self.isTimerRunning), remainingSeconds=\(self.remainingSeconds)")
        self.notifyTick() // Initial UI update
    }
    
    // Stop the timer and clear all state (public method for full reset)
    public func stop() {
        print("[SessionTimer] stop() called - full reset")
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        expiryDate = nil // Clear expiry date to fully reset
    }
    
    // Internal: Stop timer only, keep expiryDate (used during start)
    private func stopTimerOnly() {
        print("[SessionTimer] stopTimerOnly() called")
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        // Don't clear expiryDate
    }
    
    // Reset the timer to a specific time (e.g., 10 minutes)
    public func reset(to seconds: Int) {
        expiryDate = Date().addingTimeInterval(TimeInterval(seconds))
        notifyTick() // Update immediately
    }
    
    // Update the timer every tick
    @objc private func tick() {
        let remaining = remainingSeconds
        print("[SessionTimer] tick() called, remainingSeconds=\(remaining)")
        
        // Always notify first, so observers can check state before we stop
        notifyTick()
        
        // Then stop if expired
        if remaining <= 0 {
            print("[SessionTimer] Timer expired, stopping")
            stop()
        }
    }
    
    // Handle app returning from background
    @objc private func appDidBecomeActive() {
        // Recalculate when app comes to foreground
        if isTimerRunning {
            // Notify first so observers can check expiry while timer is still running
            notifyTick()
            
            // Then stop if expired
            if remainingSeconds <= 0 {
                print("[SessionTimer] Timer expired after background, stopping")
                stop()
            }
        }
    }
    
    // Notify that the timer has ticked, so observers can update the UI
    private func notifyTick() {
        NotificationCenter.default.post(name: .sessionTimerDidTick, object: nil)
    }
}

public extension Notification.Name {
    static let sessionTimerDidTick = Notification.Name("SessionTimerManagerDidTick")
}


