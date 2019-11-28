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
import PureLayout

public class EditPageSlider: UISlider {

    public var disposeBag: DisposeBag? = DisposeBag()
    var greyTrackImage = UIImage(named: "grey-track", in: GPImageEditorBundle.getBundle(), compatibleWith: nil)
    var greyGreenTrackImage = UIImage(named: "grey-green-track", in: GPImageEditorBundle.getBundle(), compatibleWith: nil)
    var greenGreyTrackImage = UIImage(named: "green-grey-track", in: GPImageEditorBundle.getBundle(), compatibleWith: nil)
    var tempTrackImage = UIImage(named: "temp-track", in: GPImageEditorBundle.getBundle(), compatibleWith: nil)
    let percentLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    
    var isLoaded: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setups()
    }

    func setups() {
        setupPercentlabel()
        resizeImagess()
        
        addTarget(self, action: #selector(didEndDragging), for: .touchUpInside)
        addTarget(self, action: #selector(didEndDragging), for: .touchUpOutside)
        
        if tag == EditPageType.temperature.rawValue {
            setMinimumTrackImage(resizeImage(image: tempTrackImage), for: .normal)
            setMaximumTrackImage(resizeImage(image: tempTrackImage), for: .normal)
        } else {
            setMinimumTrackImage(resizeImage(image: greyTrackImage), for: .normal)
            setMaximumTrackImage(resizeImage(image: greyTrackImage), for: .normal)
        }
        
        layer.masksToBounds = false
        setThumbImage(UIImage.init(named: "slider-thumb"), for: .normal)
        bindValueChange()
    }
    
    func resizeImagess() {
        let size = CGSize(width: UIScreen.main.bounds.width, height: height)
        greyTrackImage = greyTrackImage?.resizeImage(targetSize: size)
        greyGreenTrackImage = greyGreenTrackImage?.resizeImage(targetSize: size)
        greenGreyTrackImage = greenGreyTrackImage?.resizeImage(targetSize: size)
        tempTrackImage = tempTrackImage?.resizeImage(targetSize: size)
    }
    
    func resizeImage(image: UIImage?) -> UIImage? {
        return image?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4))
    }
    
    func bindValueChange() {
        rx.value.subscribe(onNext: { [weak self] (value) in
            guard let self = self else { return }
            if self.tag != EditPageType.temperature.rawValue {
                self.updateTrackImages(with: value)
            }
            if self.isLoaded {
                self.showPercentLabel()
            }
            self.isLoaded = true
        }) => disposeBag
    }
    
    deinit {
        disposeBag = nil
    }
    
    func setupPercentlabel() {
        addSubview(percentLabel)
        percentLabel.isHidden = true
        percentLabel.backgroundColor = UIColor.darkGray
        percentLabel.textColor = UIColor.white
        percentLabel.layer.masksToBounds = true
        percentLabel.textAlignment = .center
        percentLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        percentLabel.layer.cornerRadius = percentLabel.frame.size.width / 2
    }
    
    func showPercentLabel() {
        let trackRect = self.trackRect(forBounds: bounds)
        let thumbFrame = thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        percentLabel.center = CGPoint(x: max(thumbFrame.midX, percentLabel.frame.size.width / 2),
                                      y: thumbFrame.midY - thumbFrame.size.height / 2 - percentLabel.frame.size.height / 2)
        
        let centerValue = (maximumValue + minimumValue) / 2
        let totalDistance = maximumValue - minimumValue
        let offset = 100 * 2 * CGFloat(value - centerValue) / CGFloat(totalDistance)
        
        let text = String(format: "%d", Int(offset))
        percentLabel.text = text
        percentLabel.isHidden = false
    }
    
    @objc func didEndDragging() {
        percentLabel.isHidden = true
    }
    
    func updateTrackImages(with value: Float) {
        let midValue = (minimumValue + maximumValue) / 2.0
        if value == midValue {
            setMinimumTrackImage(resizeImage(image: greyTrackImage), for: .normal)
            setMaximumTrackImage(resizeImage(image: greyTrackImage), for: .normal)
        }
        if value > midValue {
            setMinimumTrackImage(resizeImage(image: greyGreenTrackImage), for: .normal)
            setMaximumTrackImage(resizeImage(image: greyTrackImage), for: .normal)
        }
        if value < midValue {
            setMinimumTrackImage(resizeImage(image: greyTrackImage), for: .normal)
            setMaximumTrackImage(resizeImage(image: greenGreyTrackImage), for: .normal)
        }
    }
    
    override public func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
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
