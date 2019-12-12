//
//  GPFrameEditorViewModel.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 12/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm
import RxCocoa
import RxSwift
import GPImageEditor

public class GPFrameEditorViewModel: ViewModel<UIImage> {
    var finishedBlock: ((UIImage) -> Void)?
    let rxImage = BehaviorRelay<UIImage?> (value: nil)
    let rxImageCenter = BehaviorRelay<CGPoint> (value: .zero)
    let rxImageScale = BehaviorRelay<CGFloat> (value: 1)
    let rxImageTransform = BehaviorRelay<CGAffineTransform> (value: .identity)
    
    let GP_MIN_FRAME_SCALE: CGFloat = 0.1
    let GP_MAX_FRAME_SCALE: CGFloat = 5
    
    override public func react() {
        rxImage.accept(model)
        rxImageScale.subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.applyImageChange()
            }) => disposeBag
    }
    
    public func applyImageChange() {
        let imageScale = rxImageScale.value
        let transform = CGAffineTransform(scaleX: imageScale, y: imageScale)
        rxImageTransform.accept(transform)
    }
    
    func handleZoom(_ scale: CGFloat) {
        var newScale = rxImageScale.value * scale
        newScale = newScale < GP_MIN_FRAME_SCALE ? GP_MIN_FRAME_SCALE : newScale
        newScale = newScale > GP_MAX_FRAME_SCALE ? GP_MAX_FRAME_SCALE : newScale
        rxImageScale.accept(newScale)
    }
    
    func handlePan(_ translation: CGPoint) {
        var currentCenter = rxImageCenter.value
        currentCenter = CGPoint(x: currentCenter.x + translation.x,
                                y: currentCenter.y + translation.y)
        rxImageCenter.accept(currentCenter)
    }
    
    func handleDone(_ maskFrame: CGRect) {
        guard
            let image = model,
            let ciImage = CIImage(image: image),
            let ciFilter = CIFilter(name: "CIAffineTransform",
                                    parameters: [kCIInputImageKey: ciImage])
            else { return }
        ciFilter.setDefaults()
        let transform = rxImageTransform.value.inverted2DMatrixTransform()
        ciFilter.setValue(transform, forKey: "inputTransform")
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: false])
        guard
            let outputImage = ciFilter.outputImage,
            let imageRef = context.createCGImage(outputImage, from: outputImage.extent),
            let result = UIImage(cgImage: imageRef).cropImage(in: maskFrame)
            else { return }
        applyFilter(result)
    }
    
    func applyFilter(_ image: UIImage) {
        let filter = GPImageFilter(name: "Comic",
                                   applier: GPImageFilter.comicFrame)
        if let filterResult = filter.applyFilter(image: image) {
            finishedBlock?(filterResult)
        }
    }
    
}

public extension UIImage {
    // return true if needed scale width to fit max size, height is ratio with width
    // return false if needed scale heigh to fit max size, width is ratio with height
    func shouldScaleWidth(toFitSize size: CGSize) -> Bool {
        return self.size.width / size.width > self.size.height / size.height
    }
    
    // calc image view size to fit maxium size
    func calcImageSize(toFitSize size: CGSize) -> CGSize {
        if self.size.width == 0 || self.size.height == 0 {
            return self.size
        }
        var width: CGFloat = 0
        var height: CGFloat = 0
        if shouldScaleWidth(toFitSize: size) {
            width = size.width
            height = width * self.size.height / self.size.width
        } else {
            height = size.height
            width = height * self.size.width / self.size.height
        }
        return CGSize(width: width, height: height)
    }
}
