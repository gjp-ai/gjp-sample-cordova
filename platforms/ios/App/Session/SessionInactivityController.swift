import Foundation

final class SessionInactivityController {
    var onWarning: (() -> Void)?
    var onSessionExtended: (() -> Void)?
    var onTimeout: (() -> Void)?

    private let warningInterval: TimeInterval = 60
    private let timeoutInterval: TimeInterval = 120
    private var lastInteractionAt = Date()
    private var evaluationWorkItem: DispatchWorkItem?
    private var started = false
    private var resumed = false
    private var warningShown = false

    func start() {
        started = true
        resumed = true
        warningShown = false
        lastInteractionAt = Date()
        scheduleNextEvaluation()
    }

    func pause() {
        resumed = false
        evaluationWorkItem?.cancel()
        evaluationWorkItem = nil
    }

    func resume() {
        guard started else {
            start()
            return
        }
        resumed = true
        evaluate()
    }

    func recordInteraction() {
        guard started else { return }
        lastInteractionAt = Date()
        warningShown = false
        onSessionExtended?()
        scheduleNextEvaluation()
    }

    func stop() {
        started = false
        resumed = false
        evaluationWorkItem?.cancel()
        evaluationWorkItem = nil
    }

    private func evaluate() {
        guard started, resumed else { return }
        let elapsed = Date().timeIntervalSince(lastInteractionAt)
        if elapsed >= timeoutInterval {
            stop()
            onTimeout?()
            return
        }
        if elapsed >= warningInterval, !warningShown {
            warningShown = true
            onWarning?()
        }
        scheduleNextEvaluation()
    }

    private func scheduleNextEvaluation() {
        evaluationWorkItem?.cancel()
        guard started, resumed else { return }

        let elapsed = Date().timeIntervalSince(lastInteractionAt)
        let nextThreshold = elapsed < warningInterval ? warningInterval : timeoutInterval
        let workItem = DispatchWorkItem { [weak self] in self?.evaluate() }
        evaluationWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + max(nextThreshold - elapsed, 0.001),
            execute: workItem
        )
    }
}
