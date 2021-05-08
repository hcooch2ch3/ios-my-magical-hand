# 내 손은 금손(My Magical Hand)
## 야곰 iOS 커리어 스타터 캠프 12번째 프로젝트

<p align="center">
<img src="https://user-images.githubusercontent.com/28377820/117255584-c6410c80-ae84-11eb-9a3d-d1971581ed1c.gif" width="20%"/>
</p>

- 내용: 사용자가 화면에 그린 그림을 동그라미, 네모, 세모, 별, 4가지 모양으로 판별해주는 앱을 구현.
  
- 진행 기간: 2021.04.19 ~ 2021.04.30 [2주]

- 팀 구성: 밤(본인), [Glenn](https://github.com/Journey36) [2인]

- 역할 분담: 기능을 각자 구현한 다음, 상호 검토 후 코드 병합

- 리뷰어: [Daheen Lee](https://github.com/daheenallwhite)

- 학습 키워드: Core ML, Create ML, Keras, CoreGraphics, UIGraphicsImageRenderer

## 1. 구현
// (기능?) 스크린샷에 대한 설명
  - UI
  - 모델
  - 기능

## 2. 문제해결(Troubleshooting)
### 2.1. CanvasView의 선이 매끄럽게 이어지지 않는 문제
#### 2.1.1 문제점
  아래의 그림과 같이 `CanvasView`에 그림을 그리면, 선이 매끄럽게 이어지지 않고 꼭지점 부분이 부자연스럽게 그려지는 문제가 발생하였습니다.

<p align="center">
<img src="https://user-images.githubusercontent.com/28377820/117548933-893a6d00-b072-11eb-9c18-15532b8c139c.png" width="20%"/>
</p>

처음에는 선의 캡 모양이 butt이라서 꼭지점이 날카로워진다고 생각하였습니다. 그래서 선의 캡을 round로 설정하면 해결될거라고 판단했는데, 모양만 살짝 달라질뿐 마찬가지로 선이 매끄럽게 이어지지 않았습니다. 그래서 `draw` 메서드의 로직을 수정해가면서 아래와 같이 원인을 찾아서 해결하였습니다.

#### 2.1.2 원인
`CanvasView`의 `draw` 로직에 문제가 있었습니다. 아래 코드에서 그림이 그려지는 로직은 터치가 움직일 때마다 좌표를 `lines`에 저장하고 첫번째 좌표만 `move`로 인해 그림의 시작으로 지정되고 이외의 좌표는 모두 `addLine`으로 선을 추가합니다.
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
이렇게 사용자가 터치를 계속 이어서 그림을 그리면, 좌표마다 선이 추가 되면서 선이 쌓이기 때문에 꼭지점 부분이 날카롭게 된다고 판단하였습니다. 그래서 좌표를 저장하는 `lines` 프로퍼티와 `touchesBegan`, `touchesMoved` 를 수정하여 좌표를 저장하는 방식을 변경하였고, 또한 `draw` 메서드에서 선이 그려지는 방식을 변경하였습니다.

#### 2.1.3 해결과정

### 2.2. 모양 분류에 실패했을 경우에 대한 예외처리
  - 분류에 실패했을 경우, 재시도를 할지 바로 메세지로 보여줄지?
  - 재시도 3회후 메세지 표시하도록 구현


## 3. 참고
  - https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml
  - https://ichi.pro/ko/uivieweseo-geuligi-83319484592706
 
