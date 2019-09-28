//
//  GPCropSlider.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 9/22/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class GPCropSlider: UIView {
    let slider = UISlider()
    let sliderCenter = UIView()
    let leftHiddenSlider = UIView()
    let rightHiddenSlider = UIView()
    var leftSliderConstraint: NSLayoutConstraint? = nil
    var rightSliderConstraint: NSLayoutConstraint? = nil
    
    let GP_SLIDER_CROP_VALUE: Float = 90
    let GP_SLIDER_COLOR = UIColor(r: 115, g: 115, b: 115)
    let GP_SLIDER_HIGH_LIGHT_COLOR = UIColor(hexString: "#6FBE49")
    
    convenience init() {
        self.init(frame: .zero)
        // add sub view
        addSubview(sliderCenter)
        addSubview(slider)
        addSubview(leftHiddenSlider)
        addSubview(rightHiddenSlider)
        // slider
        slider.autoPinEdgesToSuperviewEdges()
        slider.maximumTrackTintColor = GP_SLIDER_COLOR
        slider.minimumTrackTintColor = GP_SLIDER_COLOR
        slider.setThumbImage(UIImage.init(named: "ic_crop_slider_thumb.png"), for: .normal)
        slider.minimumValue = -GP_SLIDER_CROP_VALUE
        slider.maximumValue = GP_SLIDER_CROP_VALUE
        slider.value = 0
        // slider center
        sliderCenter.backgroundColor = GP_SLIDER_HIGH_LIGHT_COLOR
        sliderCenter.autoAlignAxis(.horizontal, toSameAxisOf: slider)
        sliderCenter.autoAlignAxis(.vertical, toSameAxisOf: slider)
        sliderCenter.autoSetDimensions(to: .init(width: 3, height: 9))
        // hidden slider view
        leftHiddenSlider.backgroundColor = GP_SLIDER_COLOR
        leftHiddenSlider.isHidden = true
        rightHiddenSlider.backgroundColor = GP_SLIDER_COLOR
        rightHiddenSlider.isHidden = true
        leftHiddenSlider.autoPinEdge(.left, to: .left, of: slider)
        leftSliderConstraint = leftHiddenSlider.autoPinEdge(.right, to: .left, of: sliderCenter)
        leftHiddenSlider.autoAlignAxis(.horizontal, toSameAxisOf: slider)
        leftHiddenSlider.autoSetDimension(.height, toSize: 2)
        rightSliderConstraint = rightHiddenSlider.autoPinEdge(.left, to: .right, of: sliderCenter)
        rightHiddenSlider.autoPinEdge(.right, to: .right, of: slider)
        rightHiddenSlider.autoAlignAxis(.horizontal, toSameAxisOf: slider)
        rightHiddenSlider.autoSetDimension(.height, toSize: 2)
    }
    
    public func updateSliderUI(_ value: Float) {
        updateSliderConstraint(value)
        // update hightlight in slider
        let isNegativeValue = value < 0
        slider.maximumTrackTintColor = isNegativeValue ? GP_SLIDER_HIGH_LIGHT_COLOR : GP_SLIDER_COLOR
        slider.minimumTrackTintColor = isNegativeValue ? GP_SLIDER_COLOR : GP_SLIDER_HIGH_LIGHT_COLOR
        leftHiddenSlider.isHidden = isNegativeValue
        rightHiddenSlider.isHidden = !isNegativeValue
    }
    
    private func updateSliderConstraint(_ value: Float) {
        // set constraint in case of thumb image in safe area,
        // unless hiddenSlider view will cover thumb image
        let safeValue = GP_SLIDER_CROP_VALUE * 5 / 100
        let safeConstraint = CGFloat(6.5 - 6.5 * abs(value) / safeValue)
        let constraint: CGFloat = (value < safeValue && value > -safeValue) ? safeConstraint : 0
        leftSliderConstraint?.constant = -constraint
        rightSliderConstraint?.constant = constraint
    }
}
