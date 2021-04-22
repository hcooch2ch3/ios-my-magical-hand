import UIKit

class ViewController: UIViewController {
    // MARK: UI Components
    private let blurBackgroundView: UIVisualEffectView = {
        let blurBackgroundView = UIVisualEffectView()
        blurBackgroundView.effect = UIBlurEffect(style: .dark)
        return blurBackgroundView
    }()
    // TODO: Drawable
    private let drawingView: UIView = {
        let drawingView = UIView()
        drawingView.backgroundColor = .white
        return drawingView
    }()
    private let buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        return buttonStackView
    }()
    private let showingResultButton: UIButton = {
        let showingResultButton = UIButton(type: .system)
        showingResultButton.setTitle("결과보기", for: .normal)
        showingResultButton.setTitleColor(.systemOrange, for: .normal)
        return showingResultButton
    }()
    private let removalButton: UIButton = {
        let removalButton = UIButton(type: .system)
        removalButton.setTitle("지우기", for: .normal)
        removalButton.setTitleColor(.systemGray2, for: .normal)
        return removalButton
    }()
    private let labelStackView: UIStackView = {
        let labelStackView = UIStackView()
        labelStackView.axis = .vertical
        labelStackView.alignment = .center
        labelStackView.spacing = 12
        labelStackView.distribution = .equalSpacing
        return labelStackView
    }()
    private let returnResultLabel: UILabel = {
        let returnResultLabel = UILabel()
        // TODO: Apply string interpolation
        returnResultLabel.text = "동그라미처럼 보이네요"
        returnResultLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        returnResultLabel.textColor = .systemGray6
        return returnResultLabel
    }()
    private let similarProportionLabel: UILabel = {
        let similarProportionLabel = UILabel()
        // TODO: Apply string interpolation
        similarProportionLabel.text = "100.0%"
        similarProportionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        similarProportionLabel.textColor = .systemGray2
        return similarProportionLabel
    }()

    // MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
    }
}

// MARK:- Extensions
extension ViewController {
    private func setConstraints() {
        view.addSubview(blurBackgroundView)
        view.addSubview(drawingView)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(showingResultButton)
        buttonStackView.addArrangedSubview(removalButton)
        view.addSubview(labelStackView)
        labelStackView.addArrangedSubview(returnResultLabel)
        labelStackView.addArrangedSubview(similarProportionLabel)

        blurBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        showingResultButton.translatesAutoresizingMaskIntoConstraints = false
        removalButton.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        returnResultLabel.translatesAutoresizingMaskIntoConstraints = false
        similarProportionLabel.translatesAutoresizingMaskIntoConstraints = false

        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            blurBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            blurBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            drawingView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            drawingView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            drawingView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            drawingView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            drawingView.heightAnchor.constraint(equalTo: drawingView.widthAnchor),

            buttonStackView.topAnchor.constraint(equalTo: drawingView.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: drawingView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: drawingView.trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 30),

            labelStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 32),
            labelStackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            labelStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: -100)
        ])
    }
}
