//
//  GPCropViewModel.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 9/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm
import Action
import RxCocoa
import RxSwift

public class GPCropViewModel: ViewModel<UIImage> {
    let rxImageCenter = BehaviorRelay<CGPoint> (value: .zero)
    let rxImageTransform = BehaviorRelay<CGAffineTransform> (value: .identity)
    let rxIsFlippedImage = BehaviorRelay<Bool> (value: false)
    let rxImageRotateAngle = BehaviorRelay<CGFloat> (value: 0)
    let rxImageScale = BehaviorRelay<CGFloat> (value: 1)
    let rxSliderValue = BehaviorRelay<Float> (value: 0)
    
    lazy var doneAction: Action<CGRect, Void> = {
        return Action(workFactory: { [weak self] maskFrame in
            guard let self = self else { return .empty() }
            return .just(self.handleDone(maskFrame: maskFrame))
        })
    }()
    
    lazy var zoomAction: Action<CGFloat, Void> = {
        return Action(workFactory: { [weak self] scale in
            guard let self = self else { return .empty() }
            return .just(self.handleZoom(scale))
        })
    }()
    
    lazy var panAction: Action<CGPoint, Void> = {
        return Action(workFactory: { [weak self] translation in
            guard let self = self else { return .empty() }
            return .just(self.handlePan(translation))
        })
    }()
    
    lazy var doubleTapAction: Action<CGPoint, Void> = {
        return Action(workFactory: { [weak self] center in
            guard let self = self else { return .empty() }
            return .just(self.handleDoubleTap(center))
        })
    }()
    
    public override func react() {
        rxSliderValue.subscribe(onNext: { [weak self] (value) in
            // rotate image
            guard let self = self else { return }
            self.handleChangeSlider(value)
        }) => disposeBag
        Observable
            .combineLatest(rxIsFlippedImage,
                           rxImageRotateAngle,
                           rxImageScale,
                           rxImageCenter)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.applyImageChange()
            }) => disposeBag
    }
    
    private func handleDone(maskFrame: CGRect) {
        guard
            let image = model,
            let ciImage = CIImage(image: image),
            let ciFilter = CIFilter(name: "CIAffineTransform",
                                    withInputParameters: [kCIInputImageKey: ciImage])
            else { return }
        ciFilter.setDefaults()
        var transform = rxImageTransform.value.inverted2DMatrixTransform()
        if (rxIsFlippedImage.value) {
            transform = transform.flipped2DMatrixTransform()
        }
        ciFilter.setValue(transform, forKey: "inputTransform")
        let context = CIContext(options: [kCIContextUseSoftwareRenderer: false])
        guard
            let outputImage = ciFilter.outputImage,
            let imageRef = context.createCGImage(outputImage, from: outputImage.extent),
            let result = UIImage(cgImage: imageRef).cropImage(in: maskFrame)
            else { return }
        model = result
        rxImageScale.accept(1)
        rxImageRotateAngle.accept(0)
        rxIsFlippedImage.accept(false)
        rxSliderValue.accept(0)
    }
    
    public func handleChangeSlider(_ value: Float) {
        let angle = CGFloat(value) * CGFloat.pi / 180
        rxImageRotateAngle.accept(angle)
    }
    
    public func applyImageChange() {
        let imageScale = rxImageScale.value
        let isFlipped = rxIsFlippedImage.value
        let imageRotateAngle = rxImageRotateAngle.value
        
        var transform = CGAffineTransform(scaleX: imageScale, y: imageScale).rotated(by: imageRotateAngle)
        transform = isFlipped ? transform.scaledBy(x: -1, y: 1) : transform
        rxImageTransform.accept(transform)
    }
}

// MARK: image gesture extension
extension GPCropViewModel {
    private func handleZoom(_ scale: CGFloat) {
        var newScale = rxImageScale.value * scale
        newScale = newScale < 1 ? 1 : newScale
        newScale = newScale > 5 ? 5 : newScale
        rxImageScale.accept(newScale)
    }
    
    private func handlePan(_ translation: CGPoint) {
        var currentCenter = rxImageCenter.value
        currentCenter = CGPoint(x: currentCenter.x + translation.x,
                                y: currentCenter.y + translation.y)
        rxImageCenter.accept(currentCenter)
    }
    
    private func handleDoubleTap(_ center: CGPoint) {
        // need calc center
        //        var imageScale = rxImageScale.value
        //        imageScale = imageScale < 5 ? imageScale * 2 : 1
        //        imageScale = imageScale > 5 ? imageScale : 5
        //        rxImageScale.accept(imageScale)
        //        rxImageCenter.accept(center)
    }
}