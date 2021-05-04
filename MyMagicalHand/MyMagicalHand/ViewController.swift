import UIKit
import Vision

class ViewController: UIViewController {
    // MARK: UI Components
    private let blurBackgroundView: UIVisualEffectView = {
        let blurBackgroundView = UIVisualEffectView()
        blurBackgroundView.effect = UIBlurEffect(style: .dark)
        return blurBackgroundView
    }()
    private let canvasView = CanvasView()
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
        showingResultButton.addTarget(self, action: #selector(showResult), for: .touchUpInside)
        return showingResultButton
    }()
    private let removalButton: UIButton = {
        let removalButton = UIButton(type: .system)
        removalButton.setTitle("지우기", for: .normal)
        removalButton.setTitleColor(.systemGray2, for: .normal)
        removalButton.addTarget(self, action: #selector(removeDrawing), for: .touchUpInside)
        return removalButton
    }()
    private let labelStackView: UIStackView = {
        let labelStackView = UIStackView()
        labelStackView.axis = .vertical
        labelStackView.alignment = .center
        labelStackView.spacing = 12
        labelStackView.distribution = .equalSpacing
        labelStackView.isHidden = true
        return labelStackView
    }()
    private let returnResultLabel: UILabel = {
        let returnResultLabel = UILabel()
        returnResultLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        returnResultLabel.textColor = .systemGray6
        returnResultLabel.numberOfLines = 0
        return returnResultLabel
    }()
    private let similarProportionLabel: UILabel = {
        let similarProportionLabel = UILabel()
        similarProportionLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        similarProportionLabel.textColor = .systemGray2
        similarProportionLabel.numberOfLines = 0
        return similarProportionLabel
    }()
    
    lazy var classificationRequest: VNCoreMLRequest? = {
        do {
            let configuration = MLModelConfiguration()
            let model = try VNCoreMLModel(for: ShapeDetectorKeras(configuration: configuration).model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            returnResultLabel.text = "모델을 로드하는데 실패했습니다."
            return nil
        }
    }()

    // MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
    }
}

// MARK:- Extensions
extension ViewController {
    //MARK: Methods
    private func setConstraints() {
        view.addSubview(blurBackgroundView)
        view.addSubview(canvasView)
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(showingResultButton)
        buttonStackView.addArrangedSubview(removalButton)
        view.addSubview(labelStackView)
        labelStackView.addArrangedSubview(returnResultLabel)
        labelStackView.addArrangedSubview(similarProportionLabel)

        blurBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.translatesAutoresizingMaskIntoConstraints = false
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

            canvasView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            canvasView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor, constant: -50),
            canvasView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            canvasView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            canvasView.heightAnchor.constraint(equalTo: canvasView.widthAnchor),

            buttonStackView.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 30),

            labelStackView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 32),
            labelStackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            labelStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: -100)
        ])
    }

    //MARK: Selectors
    @objc private func removeDrawing() {
        returnResultLabel.text = ""
        similarProportionLabel.text = ""
        labelStackView.isHidden = true
        canvasView.eraseAll()
    }

    @objc private func showResult() {
        updateClassifications()
        labelStackView.isHidden = false
    }
    
    private func updateClassifications() {
        guard let image = canvasView.exportDrawing(),
              let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else {
            return
        }
        guard let ciImage = CIImage(image: image) else {
            self.returnResultLabel.text = "이미지에 문제가 있습니다!"
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            self.dispatchWork(handler, retry: 3)
        }
    }

    private func dispatchWork(_ handler: VNImageRequestHandler, retry count: Int) {
        guard count > 0 else {
            returnResultLabel.text = "재시도 했으나 이미지 분류에 실패했습니다."
            return
        }
        do {
            if let classificationRequest = self.classificationRequest {
                try handler.perform([classificationRequest])
            }
        } catch {
            dispatchWork(handler, retry: count - 1)
        }
    }
    
    private func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results,
                  let classifications = results as? [VNClassificationObservation] else {
                return
            }
            let topClassifications = classifications.prefix(1)
            let descriptions = topClassifications.map { classification in
                return (confidence: classification.confidence, identifier: classification.identifier)
            }
            self.updateLabel(descriptions)
        }
    }

    private func updateLabel(_ descriptions: [(confidence: VNConfidence, identifier: String)] ) {
        guard let shape = descriptions.first?.identifier,
              let confidence = descriptions.first?.confidence else {
            self.returnResultLabel.text = "결과를 도출할 수 없습니다."
            return
        }
        let similarProportion = (confidence * 100).rounded()
        self.returnResultLabel.text = "\(shape)처럼 보이네요."
        self.similarProportionLabel.text = "\(similarProportion) %"
    }
}
