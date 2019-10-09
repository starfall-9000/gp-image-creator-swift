//
//  EditPageSlider.swift
//  GPImageEditor_Example
//
//  Created by Ngoc Thang on 10/9/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import DTMvvm

class EditPageSlider: UISlider {

    public var disposeBag: DisposeBag? = DisposeBag()
    let greyTrackImage = UIImage(named: "grey-track")
    let greyGreenTrackImage = UIImage(named: "grey-green-track")
    let greenGreyTrackImage = UIImage(named: "green-grey-track")
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setups()
    }

    func setups() {
        layer.masksToBounds = false
        setThumbImage(UIImage.init(named: "slider-thumb"), for: .normal)
        bindValueChange()
    }
    
    func bindValueChange() {
        rx.value.subscribe(onNext: { [weak self] (value) in
            self?.updateTrackImages(with: value)
        }) => disposeBag
    }
    
    deinit {
        disposeBag = nil
    }
    
    func updateTrackImages(with value: Float) {
        let midValue = (minimumValue + maximumValue) / 2.0
        if value == midValue {
            setMinimumTrackImage(greyTrackImage, for: .normal)
            setMaximumTrackImage(greyTrackImage, for: .normal)
        }
        if value > midValue {
            setMinimumTrackImage(greyGreenTrackImage, for: .normal)
            setMaximumTrackImage(greyTrackImage, for: .normal)
        }
        if value < midValue {
            setMinimumTrackImage(greyTrackImage, for: .normal)
            setMaximumTrackImage(greenGreyTrackImage, for: .normal)
        }
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        guard let image = currentThumbImage else {
            return super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        }
        if value == minimumValue {
            return CGRect(x: -image.size.width * 0.12,
                          y: 0,
                          width: image.size.width,
                          height: image.size.height)
        }
        if value == maximumValue {
            return CGRect(x: frame.size.width - image.size.width * (1 - 0.12),
                          y: 0,
                          width: image.size.width,
                          height: image.size.height)
        }
        return super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
    }
}
