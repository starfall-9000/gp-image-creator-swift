//
//  EditPageViewModel.swift
//  GPImageEditor_Example
//
//  Created by Ngoc Thang on 10/7/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DTMvvm
import Action

enum EditPageType: Int {
    case brightness = 0
    case saturation = 1
    case contrast = 2
    case temperature = 3
    case cropAndRotate = 4
}

public class EditPageViewModel: ViewModel<UIImage> {

    var image: CIImage?
    // -0.75 to 0.75 default 0
    let rxBrightness = BehaviorRelay<Float>(value: 0.0)
    // 0.0 to 2.0 default 1
    let rxSaturation = BehaviorRelay<Float>(value: 1.0)
    // 0.0 to 4.0 default 1
    let rxContrast = BehaviorRelay<Float>(value: 1.0)
    // -3000 to 3000 default 0
    let rxTemperature = BehaviorRelay<Float>(value: 0)
    
    let rxSelectedEditing = BehaviorRelay<EditPageType>(value: .temperature)
    let rxOutputImage = BehaviorRelay<UIImage?>(value: nil)
    var isApplyingFilter: Bool = false
    
    public required init(model: UIImage? = nil) {
        super.init(model: model)
        image = model?.toCIImage()
    }
    
    public override func react() {
        Observable
            .combineLatest(rxBrightness,
                           rxSaturation,
                           rxContrast,
                           rxTemperature)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }

                self.applyImageChange(brightness: self.rxBrightness.value,
                                      saturation: self.rxSaturation.value,
                                      constrast: self.rxContrast.value,
                                      temperature: self.rxTemperature.value)
            }) => disposeBag
    }
    
    func applyImageChange(brightness: Float, saturation: Float, constrast: Float, temperature: Float) {
        guard let image = image else { return }
        if self.isApplyingFilter { return }
        
        self.isApplyingFilter = true
        DispatchQueue.global(qos: .background).async {
            let output = image.applyFilter(brightness: brightness,
                                           saturation: saturation,
                                           constrast: constrast,
                                           temperature: temperature)
            let endImage = output?.toUIImage()
            self.rxOutputImage.accept(endImage)
            self.isApplyingFilter = false
        }
    }
    
}

extension CIImage {
    
    func applyFilter(brightness: Float,
                     saturation: Float,
                     constrast: Float,
                     temperature: Float) -> CIImage? {
        return self
            .applyingFilter("CIExposureAdjust",
                            parameters: ["inputEV": brightness])
            .applyingFilter("CIColorControls",
                            parameters: [
                                kCIInputSaturationKey: saturation,
//                                    kCIInputBrightnessKey: brightness,
                                kCIInputContrastKey: constrast])
            .applyingFilter("CITemperatureAndTint",
                            parameters: [
                                "inputNeutral": CIVector.init(x: CGFloat(temperature) + 6500, y: 0),
                                "inputTargetNeutral": CIVector.init(x: 6500, y: 0)])
    }
}
