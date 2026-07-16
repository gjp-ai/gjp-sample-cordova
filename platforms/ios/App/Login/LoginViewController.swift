import UIKit

final class LoginViewController: UIViewController {
    var onLoginSuccess: (() -> Void)?

    private let loginService: LoginService
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let errorLabel = UILabel()
    private let loginButton = UIButton(type: .system)
    private let mockModeSwitch = UISwitch()
    private let mockScenarioButton = UIButton(type: .system)
    private let mockHintLabel = UILabel()
    private var mockScenario: LoginMockScenario = .success

    init(loginService: LoginService) {
        self.loginService = loginService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildView()
    }

    deinit {
        loginService.cancel()
    }

    private func buildView() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1)

        let titleLabel = UILabel()
        titleLabel.text = "Welcome back"
        titleLabel.textColor = UIColor(red: 0.07, green: 0.13, blue: 0.23, alpha: 1)
        titleLabel.font = .boldSystemFont(ofSize: 30)
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Sign in to continue"
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center

        configure(usernameField, placeholder: "Username")
        usernameField.textContentType = .username
        usernameField.returnKeyType = .next
        usernameField.addTarget(self, action: #selector(focusPassword), for: .editingDidEndOnExit)

        configure(passwordField, placeholder: "Password")
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password
        passwordField.returnKeyType = .go
        passwordField.addTarget(self, action: #selector(submitLogin), for: .editingDidEndOnExit)

        let mockModeLabel = UILabel()
        mockModeLabel.text = "Mock mode"
        mockModeLabel.textColor = UIColor(red: 0.07, green: 0.13, blue: 0.23, alpha: 1)
        mockModeSwitch.isOn = loginService.isMockMode
        mockModeSwitch.accessibilityLabel = "Enable mock mode"
        mockModeSwitch.addTarget(self, action: #selector(mockModeChanged), for: .valueChanged)
        let mockModeRow = UIStackView(arrangedSubviews: [mockModeLabel, UIView(), mockModeSwitch])
        mockModeRow.axis = .horizontal
        mockModeRow.alignment = .center

        mockScenarioButton.contentHorizontalAlignment = .leading
        mockScenarioButton.layer.borderWidth = 1
        mockScenarioButton.layer.borderColor = UIColor.systemGray4.cgColor
        mockScenarioButton.layer.cornerRadius = 8
        mockScenarioButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        mockScenarioButton.showsMenuAsPrimaryAction = true
        configureMockScenarioMenu()

        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true

        loginButton.setTitle("Sign in", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = UIColor(red: 0.11, green: 0.37, blue: 0.82, alpha: 1)
        loginButton.layer.cornerRadius = 8
        loginButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        loginButton.addTarget(self, action: #selector(submitLogin), for: .touchUpInside)

        mockHintLabel.text = "Mock responses are loaded from the app bundle"
        mockHintLabel.textColor = .secondaryLabel
        mockHintLabel.font = .systemFont(ofSize: 13)
        mockHintLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            usernameField,
            passwordField,
            mockModeRow,
            mockScenarioButton,
            errorLabel,
            loginButton,
            mockHintLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -28),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        updateMockControls()
    }

    private func configure(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    @objc private func focusPassword() {
        passwordField.becomeFirstResponder()
    }

    @objc private func submitLogin() {
        view.endEditing(true)
        setLoading(true)

        loginService.login(
            username: usernameField.text ?? "",
            password: passwordField.text ?? "",
            mockScenario: mockScenario
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.onLoginSuccess?()
            case .failure(let error):
                self.errorLabel.text = error.localizedDescription
                self.errorLabel.isHidden = false
                self.setLoading(false)
            }
        }
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            errorLabel.isHidden = true
        }
        usernameField.isEnabled = !isLoading
        passwordField.isEnabled = !isLoading
        loginButton.isEnabled = !isLoading
        mockModeSwitch.isEnabled = !isLoading
        mockScenarioButton.isEnabled = !isLoading
        loginButton.setTitle(isLoading ? "Signing in..." : "Sign in", for: .normal)
    }

    @objc private func mockModeChanged() {
        loginService.setMockMode(mockModeSwitch.isOn)
        errorLabel.isHidden = true
        updateMockControls()
    }

    private func configureMockScenarioMenu() {
        let actions = LoginMockScenario.allCases.map { scenario in
            UIAction(
                title: scenario.title,
                state: scenario == mockScenario ? .on : .off
            ) { [weak self] _ in
                self?.mockScenario = scenario
                self?.configureMockScenarioMenu()
            }
        }
        mockScenarioButton.setTitle("Mock response: \(mockScenario.title)", for: .normal)
        mockScenarioButton.menu = UIMenu(title: "Mock login response", children: actions)
    }

    private func updateMockControls() {
        mockScenarioButton.isHidden = !mockModeSwitch.isOn
        mockHintLabel.isHidden = !mockModeSwitch.isOn
    }
}
