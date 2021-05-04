//
//  Canvas.swift
//  MyMagicalHand
//
//  Created by 임성민 on 2021/04/22.
//

import UIKit

final class CanvasView: UIView {
    
    private var lines: [Line] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .white
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setLineWidth(20)
        context.setLineCap(.round)
        
        lines.forEach { (line) in
            if let startPoint = line.startPoint {
                context.move(to: startPoint)
            }
            if let endPoint = line.endPoint {
                context.addLine(to: endPoint)
            }
        }
        
        context.strokePath()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newPoint = touches.first?.location(in: self) else {
            return
        }
        lines.append(Line(startPoint: newPoint, endPoint: nil))
    }
    
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
    
    func eraseAll() {
        lines.removeAll()
        setNeedsDisplay()
    }
    
    func exportDrawing() -> UIImage? {
        UIGraphicsBeginImageContext(frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        draw(layer, in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
