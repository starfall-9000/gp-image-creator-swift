//
//  GPCropExtension.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 9/14/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import CoreGraphics
import RxCocoa
import RxSwift

public extension ObservableType {
    func withPrevious() -> Observable<(Element?, Element)> {
        return
            scan([], accumulator: { (previous, current) in
                Array(previous + [current]).suffix(2)
            }).map({ (arr) -> (previous: Element?, current: Element) in
                (arr.count > 1 ? arr.first : nil, arr.last!)
            })
    }
}

public extension Reactive where Base: UIView {
    var transform: Binder<CGAffineTransform> {
        return Binder(self.base) { (view, value) in
            view.transform = value
        }
    }
    
    var center: Binder<CGPoint> {
        return Binder(self.base) { (view, value) in
            view.center = value
        }
    }
}

public extension UIImageView {
    func calcMaskInImage(imageMask: UIView, imageScale: CGFloat) -> CGRect {
        guard let image = image else { return .zero }
        // calculate unused frame (frame of UIImage auto-scale-fit)
        let imageSize = calcRectFitSize(imageScale: imageScale)
        let imgViewX = imageSize.minX
        let imgViewY = imageSize.minY
        // calculate mask in new frame
        let scaleWidth = image.size.width / bounds.width / imageScale
        let scaleHeight = image.size.height / bounds.height / imageScale
        let scale = scaleWidth > scaleHeight ? scaleWidth : scaleHeight
        let maskInNewFrame = CGRect(x: imageMask.frame.minX - imgViewX, y: imageMask.frame.minY - imgViewY, width: imageMask.frame.width, height: imageMask.frame.height)
        let maskScaleFrame = CGRect(x: maskInNewFrame.minX * scale, y: maskInNewFrame.minY * scale, width: maskInNewFrame.width * scale, height: maskInNewFrame.height * scale)
        
        return maskScaleFrame
    }
    
    func calcRectFitSize(imageScale: CGFloat) -> CGRect {
        guard let image = image else { return .zero }
        var imgViewX: CGFloat = frame.minX
        var imgViewY: CGFloat = frame.minY
        var width: CGFloat = frame.width
        var height: CGFloat = frame.height
        
        // calculate unused frame (frame of UIImage auto-scale-fit)
        let scaleWidth = image.size.width / bounds.width / imageScale
        let scaleHeight = image.size.height / bounds.height / imageScale
        if (scaleWidth > scaleHeight) {
            let unusedHeight = bounds.height * imageScale - image.size.height / scaleWidth
            imgViewY = imgViewY + 0.5 * unusedHeight * abs(transform.a / imageScale)
            height = height - unusedHeight
        } else {
            let unusedWidth = bounds.width * imageScale - image.size.width / scaleHeight
            imgViewX = imgViewX + 0.5 * unusedWidth * abs(transform.a / imageScale)
            width = width - unusedWidth
        }
        return CGRect(x: imgViewX, y: imgViewY, width: width, height: height)
    }
    
    func calcRectCoverMask(imageMask: UIView) -> CGRect {
        guard let image = image else { return .zero }
        var imgViewX = frame.minX
        var imgViewY = frame.minY
        var width = imageMask.frame.width
        var height = imageMask.frame.height
        let scaleWidth = image.size.width / imageMask.frame.width
        let scaleHeight = image.size.height / imageMask.frame.height
        if (scaleWidth < scaleHeight) {
            let unusedHeight = image.size.height / scaleWidth - imageMask.frame.height
            imgViewY = imgViewY - 0.5 * unusedHeight
            height = height + unusedHeight
        } else {
            let unusedWidth = image.size.width / scaleHeight - imageMask.frame.width
            imgViewX = imgViewX - 0.5 * unusedWidth
            width = width + unusedWidth
        }
        return CGRect(x: imgViewX, y: imgViewY, width: width, height: height)
    }
}

public extension UIImage {
    func rotateImage(angle: (CGFloat)) -> UIImage {
        if
            let imgRef = self.cgImage,
            let cgImage = rotateImage(imgRef, angle: angle) {
            return UIImage(cgImage: cgImage)
        }
        return self
    }
    
    private func rotateImage(_ imgRef: CGImage, angle:(CGFloat)) -> CGImage? {
        let angleInRadians = angle * (.pi / 180)
        let width = imgRef.width
        let height = imgRef.height
        
        let imgRect = CGRect(x: 0, y: 0, width: width, height: height)
        let transform = CGAffineTransform(rotationAngle: angleInRadians)
        let rotatedRect = imgRect.applying(transform)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        if let bmContext = CGContext(data: nil,
                                  width: Int(rotatedRect.size.width),
                                  height: Int(rotatedRect.size.height),
                                  bitsPerComponent: 8,
                                  bytesPerRow: 0,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) {
            
            bmContext.setAllowsAntialiasing(true)
            bmContext.setShouldAntialias(true)
            bmContext.interpolationQuality = CGInterpolationQuality.high
            bmContext.translateBy(x: +(rotatedRect.size.width / 2), y: +(rotatedRect.size.height / 2))
            bmContext.rotate(by: angleInRadians)
            bmContext.translateBy(x: -(rotatedRect.size.width / 2), y: -(rotatedRect.size.height / 2))
            bmContext.draw(imgRef, in: CGRect(x: 0, y: 0, width: rotatedRect.size.width, height: rotatedRect.size.height))
            
            let rotatedImage = bmContext.makeImage()
            return rotatedImage
        }
        
        return nil
    }
    
    func cropImage(in rect: CGRect) -> UIImage? {
        let origin = CGPoint(x: -rect.origin.x, y: -rect.origin.y)
        var img: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        self.draw(at: origin)
        img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

public extension CGAffineTransform {
    func inverted2DMatrixTransform() -> CGAffineTransform {
        let determinant = a * d - b * c
        if determinant == 0 {
            return self
        }
        var scaleTransform: CGFloat
        if (determinant > 0) {
            scaleTransform = sqrt(determinant)
        } else {
            scaleTransform = -sqrt(-determinant)
        }
        var newTransform = CGAffineTransform()
        newTransform.a = d / scaleTransform
        newTransform.b = -b / scaleTransform
        newTransform.c = -c / scaleTransform
        newTransform.d = a / scaleTransform
        return newTransform
    }
    
    func flipped2DMatrixTransform() -> CGAffineTransform {
        var newTransform = CGAffineTransform()
        newTransform.a = a
        newTransform.b = -b
        newTransform.c = -c
        newTransform.d = d
        return newTransform
    }
}
