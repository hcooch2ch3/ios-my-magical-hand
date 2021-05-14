# 내 손은 금손(My Magical Hand)
## 야곰 iOS 커리어 스타터 캠프 12번째 프로젝트

<p align="center">
<img src="https://user-images.githubusercontent.com/28377820/117255584-c6410c80-ae84-11eb-9a3d-d1971581ed1c.gif" width="20%"/>
</p>

- 요약 : 사용자가 화면에 그린 그림을 동그라미, 네모, 세모, 별, 4가지 모양 중 하나로 판별해주는 앱을 구현.
  
- 진행 기간 : 2021.04.19 ~ 2021.04.30 [2주]

- 팀 구성 : 밤(본인), [Glenn](https://github.com/Journey36) [2인]

- 역할 분담 : 기능을 각자 구현한 다음, 상호 검토 후 코드 병합

- 코드 리뷰어 : [Daheen Lee](https://github.com/daheenallwhite)

- 학습 키워드 : `Core ML`, `Create ML`, `Keras`, `Classification`, `Core Graphics`, `UIGraphics`

## 1. 앱 상세 기능

<p align="center">
<img src="https://user-images.githubusercontent.com/28377820/117620484-7aa3a100-b1ab-11eb-847a-9129c672c87b.png" width="30%"/>
</p>

- 그림 그리기 기능
  - 사용자는 화면 중앙의 흰색 정사각형 영역에 터치로 그림을 그릴 수 있습니다.
- 이미지 분류 기능
  - 화면 왼쪽의 `결과보기` 버튼을 누르면 사용자가 그린 그림을 적절한 모양으로 분류합니다.
  - 그림을 동그라미, 네모, 세모, 별, 4가지 모양 중 하나로 분류합니다.
  - 그림 분류 결과를 화면 하단부에 표시하며, 분류 정확도를 같이 표시합니다.
- 지우기 기능
  - 화면 오른쪽의 `지우기` 버튼을 누르면 정사각형 영역의 그림을 모두 삭제합니다.
  - 분류 결과가 나타나 있으면 사라지게 하여 화면을 초기상태로 만듭니다.
## 2. 구현 과정
### 2.1. ML Model 구현

<p align="center">
  <img src="https://user-images.githubusercontent.com/28377820/118229791-936fc780-b4c7-11eb-8af0-74df6bbd728a.png" width="40%"/>
  <img src="https://user-images.githubusercontent.com/28377820/118229848-ac787880-b4c7-11eb-8a41-81777ca7b77e.png" width="41%"/>
</p>

- `Core ML`과 `Keras`를 이용하여 모델을 각각 1개씩 만들고, 두 모델 중에서 더 정확성이 높은 모델을 최종 모델로 선정하였습니다.
### 2.2. UI 구현
- 협업시 Conflict 발생을 최소화하고자 코드로 UI를 구현하였습니다.
- 1개 화면으로만 구성되며, 아래와 같이 화면 중앙에는 `CanvasView`가 있고 그 아래에 2개의 `UIButton`과 2개의 `UILabel`이 있습니다.
<p align="center">
<img src="https://user-images.githubusercontent.com/28377820/118233042-607c0280-b4cc-11eb-97f5-15ca7d240496.png" width="30%"/>
</p>

  - ⓐ (CanvasView) : Custom으로 구현한 View이고, 사용자가 그림을 그릴 수 있도록 구현하였습니다.
  - ⓑ (UIButton) : 사용자가 버튼을 누르면 이미지 분류를 수행하고, ⓓ와 ⓔ가 나타나서 분류 결과를 보여주도록 구현하였습니다.
  - ⓒ (UIButton) : 사용자가 버튼을 누르면 ⓐ에 그린 그림을 지우고, ⓓ와 ⓔ가 사라지도록 구현하였습니다.
  - ⓓ (UILabel) : 분류결과를 보여주도록 구현하였습니다.
  - ⓔ (UILabel) : 분류정확도를 보여주도록 구현하였습니다.

### 2.3. 기능 구현
- `CanvasView`의 그리기 기능
- `CanvasView`의 이미지 추출 기능
- `CanvasView`의 그림 지우기 기능
- 이미지 분류 기능
- 이미지 분류 결과 표시 기능
- 이미지 분류 결과 숨김 기능

## 3. 문제 해결(Troubleshooting)
### 3.1. CanvasView의 선이 매끄럽게 이어지지 않는 문제
#### 3.1.1. 문제 내용
  아래의 그림과 같이 `CanvasView`에 그림을 그리면, 선이 매끄럽게 이어지지 않고 꼭지점 부분이 부자연스럽게 그려지는 문제가 발생하였습니다.

<p align="center">
<img src="https://user-images.githubusercontent.com/28377820/117548933-893a6d00-b072-11eb-9c18-15532b8c139c.png" width="20%"/>
</p>

처음에는 선끝 모양이 butt이라서 꼭지점이 날카로워진다고 생각하였습니다. 그래서 선끝을 round로 설정하면 해결될 것이라고 생각했는데, 모양만 살짝 달라질 뿐 마찬가지로 선이 매끄럽게 이어지지 않았습니다. 그래서 아래의 과정과 같이 `draw` 메서드의 로직을 수정해가면서 원인을 찾으려고 시도하였습니다.

#### 3.1.2. 문제 원인
`CanvasView`의 `draw` 로직에 문제가 있을 것이라고 진단하였습니다. 아래 코드의 `touchesMoved` 메서드에서 터치가 움직일 때마다 좌표를 `lines`에 저장하고, `draw` 메서드에서 첫번째 좌표만 `move`를 호출하고 이외의 좌표는 모두 `addLine`으로 선을 추가함으로써 그림이 그려지게 됩니다.
```swift
final class CanvasView: UIView {
    private var lines: [[CGPoint]] = []
    ...
    override func draw(_ rect: CGRect) {
        ...
        lines.forEach { (line) in
            for (index, point) in line.enumerated() {
                if index == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
        }
        ...
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        guard var lastLine = lines.popLast() else {
            return
        }
        lastLine.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
    ...
}
```
그래서 사용자가 터치를 계속 이어서 그림을 그리면, 좌표마다 선이 추가 되어 쌓이기 때문에 꼭지점 부분이 날카롭게 된다고 판단하였습니다. 그래서 지금처럼 터치 좌표마다 선이 쌓이게 하지 않고, 직전 터치 좌표와 현재 터치 좌표를 연결하는 선을 그리도록 수정하면 될 것이라 가정하고 `CanvasView` 코드를 다음의 과정을 거쳐서 수정하였습니다.

#### 3.1.3. 해결 과정
#### 3.1.3.1. lines 프로퍼티 타입 변경
터치 좌표를 시작점과 끝점을 가진 선으로 나타내기 위하여 lines 프로퍼티의 타입을 `2차원 CGPoint Array`에서 `1차원 Line Array`로 수정하였습니다.
```swift
final class CanvasView: UIView {
    /// private var lines: [[CGPoint]] = []
    private var lines: [Line] = []
    ...
```

```swift
struct Line {
    var startPoint: CGPoint?
    var endPoint: CGPoint?
}
```
#### 3.1.3.2. line이 추가되는 로직 변경
`lines` 프로퍼티 타입 변경에 맞추어서 `Line`이 추가되는 로직을 아래 코드와 같이 변경하였습니다. 그래서 그림을 그림으로써 새로운 터치 좌표가 추가될 때마다 직전 터치 좌표와 현재 터치 좌표를 연결하는 `Line`이 추가되도록 변경하였습니다.
```swift
final class CanvasView: UIView {
    ...  
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())
    }
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newPoint = touches.first?.location(in: self) else {
            return
        }
        lines.append(Line(startPoint: newPoint, endPoint: nil))
    }
    
    /*
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        
        guard var lastLine = lines.popLast() else {
            return
        }
        lastLine.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }
    */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newPoint = touches.first?.location(in: self) else {
            return
        }
        
        guard var lastLine = lines.popLast() else {
            return
        }
        lastLine.endPoint = newPoint
        lines.append(lastLine)
        let newLine = Line(startPoint: newPoint, endPoint: nil)
        lines.append(newLine)
        setNeedsDisplay()
    }
    ...
}
```
#### 3.1.3.3. draw 메서드 로직 변경
마지막으로 `draw` 메서드 로직을 변경하였습니다. 이전의 `draw` 메서드의 로직은 터치 시작 좌표만을 move하고 이외의 모든 좌표는 addLine하였는데, 새로운 로직은 터치좌표가 추가될 때마다 마지막 좌표를 시작점으로 move하고 새 터치좌표를 끝점으로 addLine 하도록 아래와 같이 변경되었습니다.

```swift
final class CanvasView: UIView {    
    ...
    /*
    override func draw(_ rect: CGRect) {
        ...
        lines.forEach { (line) in
            for (index, point) in line.enumerated() {
                if index == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }
        }
        ...
    }
    */
    
    override func draw(_ rect: CGRect) {
        ...
        lines.forEach { (line) in
            if let startPoint = line.startPoint {
                context.move(to: startPoint)
            }
            if let endPoint = line.endPoint {
                context.addLine(to: endPoint)
            }
        }
        ...
    }
    ...
}
```

따라서 `CanvasView`의 선이 매끄럽게 이어지지 않는 문제를 해결하기 위하여 `lines` 프로퍼티의 타입을 변경하였고,  `touchesBegan`, `touchesMoved` 에서 좌표를 저장하는 방식을 변경하였으며, `draw` 메서드가 선을 추가하는 방식을 변경하였습니다. 이를 통해 터치를 따라 선이 매끄럽게 이어져서 `CanvasView`에 그림이 더 자연스럽게 그려지게 되었습니다.

### 3.2. 모양 분류에 실패했을 경우에 대한 예외처리 문제
  - 분류에 실패했을 경우, 재시도를 할지 바로 메세지로 보여줄지?
  - 재시도 3회후 메세지 표시하도록 구현

## 4. 참고
  - https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml
  - https://ichi.pro/ko/uivieweseo-geuligi-83319484592706
 
