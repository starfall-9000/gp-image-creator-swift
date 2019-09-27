//
//  GPCropMask.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 9/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm

public enum GPCropCorner: Int {
    case topLeft = 0
    case topRight = 1
    case bottomLeft = 2
    case bottomRight = 3
}

public class GPCropMask: UIView {
    public var type: GPCropType? = .free
    var imageView: UIImageView? = nil
    let imageMask = UIView()
    let displayContent = UIView()
    let displayImageView = UIImageView()
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.clipsToBounds = true
        // display image
        self.addSubview(displayContent)
        displayContent.addSubview(displayImageView)
        displayImageView.contentMode = .scaleAspectFit
        // mask
        self.addSubview(imageMask)
        imageMask.autoPinEdgesToSuperviewEdges()
        drawMaskGrid()
    }
    
    private func drawMaskGrid() {
        imageMask.subviews.forEach({ $0.removeFromSuperview() })
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
        let numberOfDivider = getNumberOfDivider(isVertical)
        for _ in 1...numberOfDivider {
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
    
    private func getNumberOfDivider(_ isVertical: Bool) -> Int {
        // number of line in per axis of grid (vertical or horizontal)
        guard let type = type else { return 4 }
        switch type {
        case .free, .flip, .ratioOneOne:
            return 4
        case .ratioFourThree:
            return isVertical ? 4 : 5
        case .ratioThreeFour:
            return isVertical ? 5 : 4
        }
    }
    
    public func changeMaskType(_ type: GPCropType) {
        self.type = type
        updateImageMaskSize()
        drawMaskGrid()
    }
    
    private func updateImageMaskSize() {
        // using to update mask size after user change other kind of mask
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
    
    public func dragMaskCorner(_ type: GPCropCorner, translation point: CGPoint) {
        // using to calc and set new frame for mask after drag mask corner
        var nextX, nextY, nextWidth, nextHeight: CGFloat
        
        switch type {
        case .topLeft:
            let translation = remakeTranslationWithCropType(translation: point, fixedRatio: 1)
            nextX = frame.minX + translation.x
            nextY = frame.minY + translation.y
            nextWidth = frame.width - translation.x
            nextHeight = frame.height - translation.y
            break
        case .topRight:
            let translation = remakeTranslationWithCropType(translation: point, fixedRatio: -1)
            nextX = frame.minX
            nextY = frame.minY + translation.y
            nextWidth = frame.width + translation.x
            nextHeight = frame.height - translation.y
            break
        case .bottomLeft:
            let translation = remakeTranslationWithCropType(translation: point, fixedRatio: -1)
            nextX = frame.minX + translation.x
            nextY = frame.minY
            nextWidth = frame.width - translation.x
            nextHeight = frame.height + translation.y
            break
        case .bottomRight:
            let translation = remakeTranslationWithCropType(translation: point, fixedRatio: 1)
            nextX = frame.minX
            nextY = frame.minY
            nextWidth = frame.width + translation.x
            nextHeight = frame.height + translation.y
            break
        }
        
        var newFrame = CGRect(x: nextX, y: nextY, width: nextWidth, height: nextHeight)
        newFrame = makeMaskInBounds(newFrame)
        frame = newFrame
    }
    
    private func remakeTranslationWithCropType(translation point: CGPoint, fixedRatio: CGFloat) -> CGPoint {
        // remake translation to using in resize mask with ratio-mask
        // keeping the y translation, remake x translation to fit ratio
        var translation = point
        let negativeRatio: CGFloat = translation.y > 0 ? fixedRatio : -1 * fixedRatio
        if let cropType = self.type {
            switch cropType {
            case .flip, .free:
                break
            case .ratioOneOne:
                translation.x = negativeRatio * fabs(translation.y)
            case .ratioFourThree:
                translation.x = negativeRatio * 4 * fabs(translation.y) / 3
            case .ratioThreeFour:
                translation.x = negativeRatio * 3 * fabs(translation.y) / 4
            }
        }
        return translation
    }
    
    private func makeMaskInBounds(_ rect: CGRect) -> CGRect {
        // remake rect to ensure that mask always in bounds
        var nextX = rect.minX
        var nextY = rect.minY
        var nextWidth = rect.width
        var nextHeight = rect.height
        let imageFrame = imageView?.frame ?? CGRect.zero
        let contentFrame = superview?.frame ?? CGRect.zero
        
        if (nextWidth < 100) {
            nextX = frame.minX
            nextWidth = frame.width
        }
        if (nextHeight < 100) {
            nextY = frame.minY
            nextHeight = frame.height
        }
        if (nextX < imageFrame.minX || nextX < 0) {
            nextX = imageFrame.minX > 0 ? imageFrame.minX : 0
            nextWidth = frame.maxX - nextX
        }
        if (nextY < imageFrame.minY || nextY < 0) {
            nextY = imageFrame.minY > 0 ? imageFrame.minY : 0
            nextHeight = frame.maxY - nextY
        }
        if (nextX + nextWidth > imageFrame.maxX ||
            nextX + nextWidth > contentFrame.width) {
            nextWidth = imageFrame.width < contentFrame.width
                            ? imageFrame.maxX - nextX
                            : contentFrame.width - nextX
        }
        if (nextY + nextHeight > imageFrame.maxY ||
            nextY + nextHeight > contentFrame.height) {
            nextHeight = imageFrame.height < contentFrame.height
                            ? imageFrame.maxY - nextY
                            : contentFrame.height - nextY
        }
        return CGRect(x: nextX, y: nextY, width: nextWidth, height: nextHeight)
    }
}
