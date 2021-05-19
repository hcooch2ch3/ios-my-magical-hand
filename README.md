# 내 손은 금손

> 사용자가 화면에 그린 그림을 동그라미, 세모, 네모, 별, 네 가지 모양 중 하나로 판별하여 결과와 정확도를 출력해주는 앱

![magichand](/Users/iluxsm/Downloads/magichand.gif)

## 1. 함께한 사람들

- 팀원 및 기간: [Bam](https://github.com/hcooch2ch3)과 함께 2021.04.29 ~ 2021.04.30, 총 2주 동안 진행
- 코드 리뷰어: [daheenallwhite](https://github.com/daheenallwhite)
- 학습 키워드: `UIVisualEffectView`,  `CoreML`, `CreateML`, `Colaboratory`, `Vision`

## 2. 앱 상세

<img width="360" src="https://user-images.githubusercontent.com/73573732/118834184-febcfd80-b8fc-11eb-9949-d33d5bd4f199.png">

1. 사용자의 그림을 터치로 입력받을 수 있는 뷰입니다.
2. 사용자의 입력을 바탕으로 동그라미, 세모, 네모, 별 4가지 모양 중 하나로 분류를 수행하고, 4번 레이블과 5번 레이블이 나타나도록 하는 버튼입니다.
3. 캔버스를 초기화하고 다시 4번, 5번 레이블을 숨기는 기능을 하는 버튼입니다.
4. 사용자 입력을 바탕으로 수행한 도형 분류 결과 값을 나타내는 레이블입니다.
5. 사용자 입력을 바탕으로 수행한 도형 분류의 정확도를 나타내는 레이블입니다.

## 3. 앱 구현 과정 및 트러블 슈팅

### 2.1 CoreML 모델 학습

 CreateML과 Keras를 통한 모델의 학습을 진행했습니다. 전자의 경우 Xcode에 포함된 CreateML 툴을 사용해서 진행했고, 후자의 경우 Google의 Colab을 통해 진행했습니다. 그리고 정확도가 조금 더 높은 모델을 최종으로 선정했습니다.

<***해당 부분에서 했던 문제 또는 고민점들***>

- CreateML과 Keras를 모두 사용해서 모델을 두 개 만들었는데, 신기하게 파일 용량에서 꽤 차이가 났습니다. 아래 그림에서 볼 수 있듯이 CreateML로 학습한 파일은 50KB로 비교적 작은 반면, Keras로 학습한 파일은 4.8MB로 용량이 비교적 컸습니다.

  ![image](https://user-images.githubusercontent.com/73573732/118828254-104fd680-b8f8-11eb-912b-0eee992fb69b.png)![image](https://user-images.githubusercontent.com/73573732/118828185-ff06ca00-b8f7-11eb-9385-9399b675d4e1.png)

  - iOS 11 부터 CoreML이, iOS 12 부터 CoreML2와 CreateML이 함께 출시되었습니다. Keras는 CoreML을 기반으로, CreateML은 CoreML2를 기반으로 동작합니다. CoreML은 가중치 값이 `Float32` 로 저장되어있지만, CoreML2은 가중치 값을 양자화를 통해 1~8 bit 까지 줄일 수 있습니다. 그렇기에 용량차이가 발생하게 된 것입니다. 하지만 Keras에서도 양자화 코드를 따로 입력하면 용량을 줄일 수 있습니다.

### 2.2 UI 구현

 스토리보드로 작업 후 Merge 시에 발생하는 충돌 및 각종 스토리보드 버그를 피하기 위해 코드로 UI를 구현했습니다. 그리고 배경보다 캔버스에 집중되는 효과를 위해 단순히 배경에 색상을 주는 것이 아닌, `UIVisualEffectView` 를 사용하여 구현했습니다.

<***해당 부분에서 했던 문제 또는 고민점들***>

- `UIStackView`에서 `addArrangedSubview(_:)`을 사용해야하는 이유에 대해 고민했습니다.

  - `UIStackView`를 사용하여 버튼들을 배치할 때, `addSubview(_:)`를 사용했었는데, 아래 사진 처럼 원하는 대로 배치가 되지 않고 겹쳐서 배치가 되는 것을 확인했습니다.

    <img width="360" alt="스크린샷 2021-05-19 오후 11 18 32" src="https://user-images.githubusercontent.com/73573732/118830038-9a4c6f00-b8f9-11eb-90f5-060f3df6befa.png">

    그 [이유](https://developer.apple.com/documentation/uikit/uistackview/)는 `UIStackView`는 하위 뷰들을 `arrangedSubviews`라는 배열로 관리하기 때문이었습니다. 그리고 해당 배열에 `addArrangedSubview(_:)`메서드를 사용하여 하위 뷰들을 배열 끝에 추가할 수 있습니다. 즉, `addArrangedSubview(_:)`를 호출하는 순서에 따라 `UIStackView` 배열 순서가 달라질 수 있음을 확인할 수 있었습니다.

- 배경 뷰의 색을 회색으로 처리함에 있어서 고민이 있었습니다.
  - 처음에는 간단하게 `view.backgroundColor`를 회색으로 처리하려고 했습니다. 하지만 사용자가 직관적으로 '캔버스에 그림을 그린다.' 라는 것을 알 수 있도록 구현하는 차원에서는 단순히 배경색으로 처리하는 것보다, Modal 처럼 사용에서 중요한 캔버스를 강조하고, 뒷 배경을 흐리도록 하는 것이 정황상 더 맞는 구현이라고 생각했습니다. 그래서 대신 `UIVisualEffectView`을 사용하여 기본 배경을 흐리게 처리했습니다.

### 2.3 기능 구현

 캔버스에 그림을 그릴 수 있고,  해당 이미지를 학습 모델과 비교하기 위해 이미지를 추출하도록 구현했습니다. 학습용 데이터와 이미지가 최대한 유사하도록 선 굵기 및 선 끝처리 등도 추가했습니다. 그리고 '결과보기' 버튼을 누르면 추출된 이미지를 학습 데이터를 기반으로 분류 정확도가 얼마고 어떤 도형인지 예측하도록 했습니다.

<***해당 부분에서 했던 문제 또는 고민점들***>

- 이미지 분류에 실패했을 경우에 대한 예외처리를 어떻게 해야할지 고민했습니다.

  - 초기에는 이미지 분류에 실패하는 등의 예외처리를 다음과 같이 `fatalError` 나 `print` 로 확인하도록 구현했습니다.

    ```swift
      private func updateClassifications(for image: UIImage) {
            ...
            guard let ciImage = CIImage(image: image) else {
                fatalError("Unable to create \(CIImage.self) from \(image).")
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
                do {
                    try handler.perform([self.classificationRequest])
                } catch {
                    print("Failed to perform classification.\n\(error.localizedDescription)")
                }
            }
        }
    ```

    하지만 코드 리뷰어가  `fatalError` 같은 경우 앱이 죽는 경우가 발생하게 되는데, 그러면 사용자는 어떤 에러 때문에 앱이 종료되는지 알지 못할 뿐더러 사용에 있어서 매우 중요한 것이라서 의도적으로 앱을 종료하도록 하는 것이 아니라면 좋은 예외처리가 아니라는 의견을 주셨습니다. 그래서 저희는 어떤 처리 방법이 있을지 고민했는데,

    1. `UIAlertController` 를 통한 알림
    2. 기존의 `UILabel` 을 통한 알림

    이렇게 두 가지 방법을 생각했습니다. 저희는 사용자들에게 어떤 문제인지를 알려줄 수 있기만 하면 되고 그 것을 위해 새로운 기능을 넣는 것 보다는, 기존에 있던 UI 컴포넌트를 재사용하여 사용자에게 에러 메시지를 전달하는 것이 더 좋을 것이라고 판단해서 2번 방법을 사용하기로 했습니다. 그리고 추가로, 1회 실패 후 메시지를 출력하는 것보다, 3회 재시도를 한 후에 메시지를 출력하는 것이 자연스럽고 더 사용성을 높이는 방법이라고 판단했습니다. 그래서  매개변수에 있는 `retry` 값 만큼 재귀 호출을 하는 `dispatchWork` 메서드를 구현했습니다.

    ```swift
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
    ```

    그리고 최종적으로, `dispatchWork` 메서드를 이용하여 3회 시도 후 `UILabel`에 에러 메시지를 표시하도록 아래와 같이 코드를 수정하였습니다. `updateClassifications` 메서드는 이미지 분류 결과를 갱신하는 메서드이며, `결과보기` 버튼을 누르면 호출됩니다.

    ```swift
      private func updateClassifications() {
            ...
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
                self.dispatchWork(handler, retry: 3)
            }
        }
    ```