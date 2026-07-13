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

#if compiler(>=6.1)
@objc @implementation
#else
@_objcImplementation
#endif
extension MainViewController {
}

class ViewController: MainViewController {
    private let mockLoginService = MockLoginService()
    private let nativeOverlay = UIView()
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let errorLabel = UILabel()
    private let loginButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        webView?.isHidden = true
        buildNativeLoginView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            self?.showLoginForm()
        }
    }

    private func buildNativeLoginView() {
        nativeOverlay.translatesAutoresizingMaskIntoConstraints = false
        nativeOverlay.backgroundColor = UIColor(red: 0.07, green: 0.23, blue: 0.45, alpha: 1)
        view.addSubview(nativeOverlay)
        NSLayoutConstraint.activate([
            nativeOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nativeOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nativeOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            nativeOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let title = UILabel()
        title.text = "GJPS"
        title.textColor = .white
        title.font = .boldSystemFont(ofSize: 34)
        title.textAlignment = .center
        let subtitle = UILabel()
        subtitle.text = "Preparing your workspace"
        subtitle.textColor = UIColor(white: 0.85, alpha: 1)
        subtitle.textAlignment = .center
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        spinner.startAnimating()
        let stack = UIStackView(arrangedSubviews: [title, subtitle, spinner])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        nativeOverlay.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: nativeOverlay.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: nativeOverlay.centerYAnchor)
        ])
    }

    private func showLoginForm() {
        nativeOverlay.subviews.forEach { $0.removeFromSuperview() }
        nativeOverlay.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1)

        let title = UILabel()
        title.text = "Welcome back"
        title.textColor = UIColor(red: 0.07, green: 0.13, blue: 0.23, alpha: 1)
        title.font = .boldSystemFont(ofSize: 30)
        title.textAlignment = .center
        let subtitle = UILabel()
        subtitle.text = "Sign in to continue"
        subtitle.textColor = .secondaryLabel
        subtitle.textAlignment = .center

        configure(usernameField, placeholder: "Username")
        configure(passwordField, placeholder: "Password")
        passwordField.isSecureTextEntry = true
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
        loginButton.setTitle("Sign in", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = UIColor(red: 0.11, green: 0.37, blue: 0.82, alpha: 1)
        loginButton.layer.cornerRadius = 8
        loginButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        loginButton.addTarget(self, action: #selector(submitLogin), for: .touchUpInside)

        let hint = UILabel()
        hint.text = "Demo credentials: demo / demo"
        hint.textColor = .secondaryLabel
        hint.font = .systemFont(ofSize: 13)
        hint.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [title, subtitle, usernameField, passwordField, errorLabel, loginButton, hint])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        nativeOverlay.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: nativeOverlay.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: nativeOverlay.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: nativeOverlay.centerYAnchor)
        ])
    }

    private func configure(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    @objc private func submitLogin() {
        errorLabel.isHidden = true
        loginButton.isEnabled = false
        loginButton.setTitle("Signing in...", for: .normal)
        mockLoginService.login(username: usernameField.text ?? "", password: passwordField.text ?? "") { [weak self] success, message in
            guard let self else { return }
            if success {
                self.nativeOverlay.removeFromSuperview()
                self.webView?.isHidden = false
            } else {
                self.errorLabel.text = message
                self.errorLabel.isHidden = false
                self.loginButton.isEnabled = true
                self.loginButton.setTitle("Sign in", for: .normal)
            }
        }
    }
}

private struct MockLoginService {
    func login(username: String, password: String, completion: @escaping (Bool, String) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            let success = username == "demo" && password == "demo"
            completion(success, success ? "" : "Use the demo credentials shown below.")
        }
    }
}
