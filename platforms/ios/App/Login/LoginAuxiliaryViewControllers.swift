import UIKit

final class NotificationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(close)
        )

        let icon = UIImageView(image: UIImage(systemName: "bell.badge"))
        icon.tintColor = UIColor(red: 0.11, green: 0.37, blue: 0.82, alpha: 1)
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 42)
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = "You’re all caught up"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center

        let detailLabel = UILabel()
        detailLabel.text = "New account and security notifications will appear here."
        detailLabel.font = .systemFont(ofSize: 15)
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        detailLabel.textAlignment = .center

        let content = UIStackView(arrangedSubviews: [icon, titleLabel, detailLabel])
        content.axis = .vertical
        content.alignment = .fill
        content.spacing = 12
        content.translatesAutoresizingMaskIntoConstraints = false

        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 20
        card.layer.cornerCurve = .continuous
        card.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        view.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: 32),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -32),
            icon.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}

final class MoreViewController: UIViewController {
    private struct MenuItem {
        let title: String
        let symbol: String
    }

    private let items = [
        MenuItem(title: "Device info", symbol: "iphone.gen3"),
        MenuItem(title: "About app", symbol: "info.circle"),
        MenuItem(title: "Security", symbol: "lock.shield"),
        MenuItem(title: "Privacy", symbol: "hand.raised"),
        MenuItem(title: "Help", symbol: "questionmark.circle"),
        MenuItem(title: "Contact", symbol: "envelope")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "More"
        view.backgroundColor = .systemGroupedBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(close)
        )

        let rows = stride(from: 0, to: items.count, by: 3).map { start -> UIStackView in
            let buttons = items[start..<min(start + 3, items.count)].enumerated().map {
                offset,
                item in
                makeMenuButton(item: item, index: start + offset)
            }
            let row = UIStackView(arrangedSubviews: buttons)
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 12
            return row
        }

        let grid = UIStackView(arrangedSubviews: rows)
        grid.axis = .vertical
        grid.spacing = 12
        grid.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(grid)

        NSLayoutConstraint.activate([
            grid.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            grid.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            grid.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }

    private func makeMenuButton(item: MenuItem, index: Int) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = item.title
        configuration.image = UIImage(systemName: item.symbol)
        configuration.imagePlacement = .top
        configuration.imagePadding = 10
        configuration.baseForegroundColor = UIColor(
            red: 0.11,
            green: 0.37,
            blue: 0.82,
            alpha: 1
        )
        configuration.baseBackgroundColor = .secondarySystemGroupedBackground
        configuration.cornerStyle = .large
        configuration.titleAlignment = .center
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 6,
            bottom: 14,
            trailing: 6
        )

        let button = UIButton(configuration: configuration)
        button.tag = index
        button.heightAnchor.constraint(equalToConstant: 116).isActive = true
        button.addTarget(self, action: #selector(openMenuItem(_:)), for: .touchUpInside)
        return button
    }

    @objc private func openMenuItem(_ sender: UIButton) {
        let item = items[sender.tag]
        let message: String
        switch item.title {
        case "Device info":
            message = "\(UIDevice.current.model)\n"
                + "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        case "About app":
            let name = Bundle.main.object(
                forInfoDictionaryKey: "CFBundleDisplayName"
            ) as? String ?? "GJPS"
            let version = Bundle.main.object(
                forInfoDictionaryKey: "CFBundleShortVersionString"
            ) as? String ?? "1.0"
            message = "\(name)\nVersion \(version)"
        default:
            message = "\(item.title) options will be available here."
        }

        let alert = UIAlertController(title: item.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default))
        present(alert, animated: true)
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
