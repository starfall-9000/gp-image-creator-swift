//
//  GPCropMask.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 9/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm

public class GPCropMask: UIView {
    public var type: GPCropType? = .free
    var imageView: UIImageView? = nil
    let imageMask = UIView()
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        // blur
//        let blurView = UIView()
//        self.addSubview(blurView)
//        blurView.backgroundColor = .init(r: 0, g: 0, b: 0, a: 0.5)
//        blurView.autoPinEdgesToSuperviewEdges()
        // mask
        self.addSubview(imageMask)
        imageMask.autoPinEdgesToSuperviewEdges()
        
        createVerticalStack()
        createHorizontalStack()
    }
    
    private func createVerticalStack() {
        createStack(isVertical: true)
    }
    
    private func createHorizontalStack() {
        createStack(isVertical: false)
    }
    
    private func createStack(isVertical: Bool) {
        let stackLayout = StackLayout().justifyContent(.equalCentering).children(getStackDividers(isVertical))
        stackLayout.axis = isVertical ? .vertical : .horizontal
        imageMask.addSubview(stackLayout)
        stackLayout.autoPinEdgesToSuperviewEdges()
    }
    
    private func getStackDividers(_ isVertical: Bool) -> [UIView] {
        var children: [UIView] = []
        let NUM_OF_DIVIDER = 4
        for _ in 1...NUM_OF_DIVIDER {
            let divider = UIView()
            divider.backgroundColor = .white
            children.append(divider)
            if (isVertical) {
                divider.autoSetDimension(.height, toSize: 1)
            } else {
                divider.autoSetDimension(.width, toSize: 1)
            }
        }
        return children
    }
    
    public func changeMaskType(_ type: GPCropType) {
        self.type = type
        updateImageMaskSize()
    }
    
    private func updateImageMaskSize() {
        guard
            let contentView = superview,
            let type = type,
            let image = imageView?.image
        else { return }
        
        let contentWidth = contentView.frame.width
        let contentHeight = contentView.frame.height
        var width = contentWidth
        var height = contentHeight
        
        switch type {
        case .flip:
            return
        case .free:
            let tempImgView = UIImageView(frame: contentView.frame)
            tempImgView.image = image
            let imageFrame = tempImgView.calcRectFitSize(imageScale: 1)
            width = imageFrame.width
            height = imageFrame.height
            break
        case .ratioOneOne, .ratioFourThree, .ratioThreeFour:
            let ratio = GPCropType.getRatio(type)
            let widthRatio = ratio["width"] ?? 1
            let heightRatio = ratio["height"] ?? 1
            if contentHeight * widthRatio > contentWidth * heightRatio {
                width = contentWidth
                height = contentWidth * heightRatio / widthRatio
            } else {
                width = contentHeight * widthRatio / heightRatio
                height = contentHeight
            }
            break
        }
        self.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        let center = CGPoint(x: 0.5 * contentWidth, y: 0.5 * contentHeight)
        self.center = center
    }
}
