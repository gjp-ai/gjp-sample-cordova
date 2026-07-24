/*
    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.
*/

import Cordova
import UIKit

enum NativeLogoutReason: Equatable {
    case requested
    case inactivity
}

#if compiler(>=6.1)
@objc @implementation
#else
@_objcImplementation
#endif
extension MainViewController {
}

final class WebViewController: MainViewController, UIGestureRecognizerDelegate {
    var onLogout: ((NativeLogoutReason) -> Void)?

    private var logoutObserver: NSObjectProtocol?
    private var lifecycleObservers: [NSObjectProtocol] = []
    private let inactivityController = SessionInactivityController()
    private weak var inactivityWarning: UIAlertController?
    private var inactivityStarted = false
    private var loggingOut = false

    override func viewDidLoad() {
        showInitialSplashScreen = false
        super.viewDidLoad()
        observeLogoutRequests()
        observeApplicationLifecycle()
        configureInactivityMonitoring()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if inactivityStarted {
            inactivityController.resume()
        } else {
            inactivityStarted = true
            inactivityController.start()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        inactivityController.pause()
        super.viewWillDisappear(animated)
    }

    deinit {
        if let logoutObserver {
            NotificationCenter.default.removeObserver(logoutObserver)
        }
        lifecycleObservers.forEach(NotificationCenter.default.removeObserver)
        inactivityController.stop()
    }

    private func observeLogoutRequests() {
        logoutObserver = NotificationCenter.default.addObserver(
            forName: .nativeSessionDidRequestLogout,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.requestLogout(reason: .requested)
        }
    }

    private func observeApplicationLifecycle() {
        let center = NotificationCenter.default
        lifecycleObservers = [
            center.addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.inactivityController.pause()
            },
            center.addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.inactivityController.resume()
            }
        ]
    }

    private func configureInactivityMonitoring() {
        inactivityController.onWarning = { [weak self] in
            self?.showInactivityWarning()
        }
        inactivityController.onSessionExtended = { [weak self] in
            self?.inactivityWarning?.dismiss(animated: true)
        }
        inactivityController.onTimeout = { [weak self] in
            self?.requestLogout(reason: .inactivity)
        }

        let activityGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(userDidInteract(_:))
        )
        activityGesture.minimumPressDuration = 0
        activityGesture.cancelsTouchesInView = false
        activityGesture.delegate = self
        view.addGestureRecognizer(activityGesture)
    }

    @objc private func userDidInteract(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            inactivityController.recordInteraction()
        }
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    private func showInactivityWarning() {
        guard inactivityWarning == nil, presentedViewController == nil else { return }
        let alert = UIAlertController(
            title: "Session expiring",
            message: "You will be signed out in one minute due to inactivity.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Stay signed in", style: .default) {
            [weak self] _ in
            self?.inactivityController.recordInteraction()
        })
        inactivityWarning = alert
        present(alert, animated: true)
    }

    private func requestLogout(reason: NativeLogoutReason) {
        guard !loggingOut else { return }
        loggingOut = true
        inactivityController.stop()
        inactivityWarning?.dismiss(animated: false)
        SessionStore.shared.clear()
        onLogout?(reason)
    }
}

private extension Notification.Name {
    static let nativeSessionDidRequestLogout = Notification.Name("NativeSessionDidRequestLogout")
}
