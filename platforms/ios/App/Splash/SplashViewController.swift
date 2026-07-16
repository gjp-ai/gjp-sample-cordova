import UIKit

final class SplashViewController: UIViewController {
    var onFinished: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        buildView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.onFinished?()
        }
    }

    private func buildView() {
        view.backgroundColor = UIColor(red: 0.07, green: 0.23, blue: 0.45, alpha: 1)

        let appIconView = UIImageView(image: UIImage(named: "SplashIcon"))
        appIconView.contentMode = .scaleAspectFit
        appIconView.isAccessibilityElement = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Loading"
        subtitleLabel.textColor = UIColor(white: 0.85, alpha: 1)
        subtitleLabel.textAlignment = .center

        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        spinner.startAnimating()

        let stackView = UIStackView(arrangedSubviews: [appIconView, subtitleLabel, spinner])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            appIconView.widthAnchor.constraint(equalToConstant: 180),
            appIconView.heightAnchor.constraint(equalToConstant: 160),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 28),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -28),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
