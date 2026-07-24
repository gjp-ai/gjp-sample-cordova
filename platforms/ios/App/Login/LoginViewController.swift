import UIKit

final class LoginViewController: UIViewController {
    var onLoginSuccess: (() -> Void)?

    private let loginService: LoginService
    private let initialErrorMessage: String?
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let errorLabel = UILabel()
    private let loginButton = UIButton(type: .system)

    init(loginService: LoginService, initialErrorMessage: String? = nil) {
        self.loginService = loginService
        self.initialErrorMessage = initialErrorMessage
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildView()
        if let initialErrorMessage {
            errorLabel.text = initialErrorMessage
            errorLabel.isHidden = false
        }
    }

    deinit {
        loginService.cancel()
    }

    private func buildView() {
        view.backgroundColor = UIColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 1)

        let backgroundView = PanoramicBackgroundView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        let overlayView = LoginGradientOverlayView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)

        let notificationButton = iconButton(
            systemName: "bell.fill",
            accessibilityLabel: "Notifications",
            action: #selector(showNotifications)
        )
        let moreButton = iconButton(
            systemName: "ellipsis",
            accessibilityLabel: "More",
            action: #selector(showMore)
        )
        view.addSubview(notificationButton)
        view.addSubview(moreButton)

        configure(usernameField, placeholder: "Username")
        usernameField.textContentType = .username
        usernameField.returnKeyType = .next
        usernameField.addTarget(self, action: #selector(focusPassword), for: .editingDidEndOnExit)

        configure(passwordField, placeholder: "Password")
        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password
        passwordField.returnKeyType = .go
        passwordField.addTarget(self, action: #selector(submitLogin), for: .editingDidEndOnExit)

        errorLabel.textColor = UIColor(red: 0.70, green: 0.14, blue: 0.09, alpha: 1)
        errorLabel.font = .systemFont(ofSize: 14)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.isHidden = true

        loginButton.setTitle("Sign in", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        loginButton.backgroundColor = UIColor(red: 0.04, green: 0.17, blue: 0.35, alpha: 1)
        loginButton.layer.cornerRadius = 14
        loginButton.layer.cornerCurve = .continuous
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.addTarget(self, action: #selector(submitLogin), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            usernameField,
            passwordField,
            errorLabel,
            loginButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let panelContainer = UIView()
        panelContainer.translatesAutoresizingMaskIntoConstraints = false
        panelContainer.layer.shadowColor = UIColor.black.cgColor
        panelContainer.layer.shadowOpacity = 0.24
        panelContainer.layer.shadowRadius = 18
        panelContainer.layer.shadowOffset = CGSize(width: 0, height: 10)

        let panel = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.layer.cornerRadius = 28
        panel.layer.cornerCurve = .continuous
        panel.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        panel.layer.borderWidth = 1
        panel.clipsToBounds = true
        panel.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        panel.contentView.addSubview(stackView)
        panelContainer.addSubview(panel)
        view.addSubview(panelContainer)

        let preferredBottom = panelContainer.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -18
        )
        preferredBottom.priority = .defaultHigh

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            notificationButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20
            ),
            notificationButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 12
            ),
            notificationButton.widthAnchor.constraint(equalToConstant: 48),
            notificationButton.heightAnchor.constraint(equalToConstant: 48),

            moreButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20
            ),
            moreButton.topAnchor.constraint(equalTo: notificationButton.topAnchor),
            moreButton.widthAnchor.constraint(equalToConstant: 48),
            moreButton.heightAnchor.constraint(equalToConstant: 48),

            panelContainer.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 18
            ),
            panelContainer.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -18
            ),
            preferredBottom,
            panelContainer.bottomAnchor.constraint(
                lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor,
                constant: -12
            ),

            panel.leadingAnchor.constraint(equalTo: panelContainer.leadingAnchor),
            panel.trailingAnchor.constraint(equalTo: panelContainer.trailingAnchor),
            panel.topAnchor.constraint(equalTo: panelContainer.topAnchor),
            panel.bottomAnchor.constraint(equalTo: panelContainer.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: panel.contentView.leadingAnchor, constant: 18),
            stackView.trailingAnchor.constraint(equalTo: panel.contentView.trailingAnchor, constant: -18),
            stackView.topAnchor.constraint(equalTo: panel.contentView.topAnchor, constant: 18),
            stackView.bottomAnchor.constraint(equalTo: panel.contentView.bottomAnchor, constant: -18)
        ])
    }

    private func configure(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.backgroundColor = UIColor.white.withAlphaComponent(0.80)
        field.layer.cornerRadius = 14
        field.layer.cornerCurve = .continuous
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.82).cgColor
        field.layer.borderWidth = 1
        field.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let inset = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.leftView = inset
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        field.rightViewMode = .always
    }

    private func iconButton(
        systemName: String,
        accessibilityLabel: String,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(
            UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(
                pointSize: 19,
                weight: .semibold
            )),
            for: .normal
        )
        button.tintColor = .white
        button.backgroundColor = UIColor(
            red: 0.02,
            green: 0.12,
            blue: 0.25,
            alpha: 0.60
        )
        button.layer.cornerRadius = 24
        button.layer.cornerCurve = .continuous
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.24).cgColor
        button.layer.borderWidth = 1
        button.accessibilityLabel = accessibilityLabel
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func showNotifications() {
        presentDestination(NotificationViewController())
    }

    @objc private func showMore() {
        presentDestination(MoreViewController())
    }

    private func presentDestination(_ destination: UIViewController) {
        let navigationController = UINavigationController(rootViewController: destination)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    @objc private func focusPassword() {
        passwordField.becomeFirstResponder()
    }

    @objc private func submitLogin() {
        view.endEditing(true)
        setLoading(true)

        loginService.login(
            username: usernameField.text ?? "",
            password: passwordField.text ?? ""
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let session):
                SessionStore.shared.save(session)
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
        loginButton.setTitle(isLoading ? "Signing in..." : "Sign in", for: .normal)
        loginButton.alpha = isLoading ? 0.72 : 1
    }
}

private final class PanoramicBackgroundView: UIView {
    private let imageView: UIImageView = {
        let image = Bundle.main.url(
            forResource: "LoginBackground",
            withExtension: "jpg"
        ).flatMap { UIImage(contentsOfFile: $0.path) }
        return UIImageView(image: image)
    }()
    private var renderedSize = CGSize.zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        imageView.contentMode = .scaleToFill
        addSubview(imageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != renderedSize,
              bounds.width > 0,
              bounds.height > 0,
              let image = imageView.image else {
            return
        }

        renderedSize = bounds.size
        imageView.layer.removeAllAnimations()
        imageView.transform = .identity

        let scale = max(
            bounds.width / image.size.width,
            bounds.height / image.size.height
        )
        let imageSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        imageView.frame = CGRect(
            x: 0,
            y: (bounds.height - imageSize.height) / 2,
            width: imageSize.width,
            height: imageSize.height
        )
        startPanning()
    }

    private func startPanning() {
        let travel = max(imageView.frame.width - bounds.width, 0)
        guard travel > 0 else { return }

        UIView.animate(
            withDuration: 36,
            delay: 0,
            options: [.curveLinear, .repeat, .allowUserInteraction]
        ) {
            self.imageView.transform = CGAffineTransform(translationX: -travel, y: 0)
        }
    }
}

private final class LoginGradientOverlayView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [
            UIColor(red: 0.01, green: 0.04, blue: 0.11, alpha: 0.08).cgColor,
            UIColor(red: 0.01, green: 0.04, blue: 0.11, alpha: 0.04).cgColor,
            UIColor(red: 0.02, green: 0.08, blue: 0.18, alpha: 0.62).cgColor
        ]
        gradientLayer.locations = [0, 0.55, 1]
        layer.addSublayer(gradientLayer)
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
