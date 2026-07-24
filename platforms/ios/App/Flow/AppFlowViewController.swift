import UIKit

final class AppFlowViewController: UIViewController {
    private var activeViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        showSplashScreen()
    }

    private func showSplashScreen() {
        let splashViewController = SplashViewController()
        splashViewController.onFinished = { [weak self] in
            self?.showLoginScreen()
        }
        show(splashViewController)
    }

    private func showLoginScreen(initialErrorMessage: String? = nil) {
        let loginViewController = LoginViewController(
            loginService: LoginService(),
            initialErrorMessage: initialErrorMessage
        )
        loginViewController.onLoginSuccess = { [weak self] in
            self?.showWebApp()
        }
        show(loginViewController)
    }

    private func showWebApp() {
        let webViewController = WebViewController()
        webViewController.onLogout = { [weak self] reason in
            let message = reason == .inactivity
                ? "Your session expired due to inactivity. Sign in again."
                : nil
            self?.showLoginScreen(initialErrorMessage: message)
        }
        show(webViewController)
    }

    private func show(_ viewController: UIViewController) {
        removeActiveViewController()

        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        viewController.didMove(toParent: self)
        activeViewController = viewController
    }

    private func removeActiveViewController() {
        guard let activeViewController else { return }
        activeViewController.willMove(toParent: nil)
        activeViewController.view.removeFromSuperview()
        activeViewController.removeFromParent()
        self.activeViewController = nil
    }
}
