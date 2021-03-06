//
//  GPTriangleView.swift
//
//  Created by ToanDK on 7/10/19.
//

import DTMvvm

public class GPTriangleView: AbstractView {
    
    public var color: UIColor = .clear {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public var reversed = false {
        didSet {
            if reversed {
                transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            } else {
                transform = .identity
            }
        }
    }
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()
        
        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}
