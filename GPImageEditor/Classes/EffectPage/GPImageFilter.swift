//
//  GPImageFilter.swift
//  GPImageEditor
//
//  Created by Ngoc Thang on 9/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import CoreImage
import UIKit
import RxCocoa
import RxSwift
import DTMvvm
import Alamofire

public typealias FilterApplierType = ((_ image: CIImage) -> CIImage?)

public class GPImageFilter: NSObject {
    
    var name = ""
    var applier: FilterApplierType?
    var thumbImage: UIImage?
    var frameImage: UIImage? = nil
    var allowGesture: Bool = false
    var defaultForegroundSize: CGSize? = nil
    var frameModel: FrameModel? = nil
    
    public init(name: String, coreImageFilterName: String) {
        super.init()
        self.name = name
        self.applier = GPImageFilter.coreImageFilter(name: coreImageFilterName)
    }
    
    public init(name: String, applier: FilterApplierType?) {
        super.init()
        self.name = name
        self.applier = applier
    }
    
    public init(frame: FrameModel) {
        super.init()
        self.name = frame.title
        self.allowGesture = true
        self.frameModel = frame
        self.applier = applyFrame
    }
    
    public static func initWithType(_ type: GPImageFilterType) -> GPImageFilter {
        return type.getImageFilter()
    }
    
    func thumbImageObserver(from image: UIImage?) -> Observable<UIImage?> {
        if thumbImage != nil {
            return Observable.just(thumbImage)
        }
        if frameModel != nil {
            return thumbModelFrameImage(url: frameModel?.smallThumb ?? "")
        } else {
            return thumbFilterImage(from: image)
        }
    }
    
    func thumbFilterImage(from image: UIImage?) -> Observable<UIImage?> {
        guard let image = image else { return Observable.just(nil) }
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let self = self else { return Disposables.create() }
            self.thumbImage = self.applyFilter(image: image)
            observer.onNext(self.thumbImage)
            observer.onCompleted()
            return Disposables.create()
        })
    }
    
    func thumbModelFrameImage(url: String,
                              target: String = "thumbImage") -> Observable<UIImage?> {
        return Observable.create({ observer -> Disposable in
            if let url = URL(string: url) {
                AF.request(url)
                    .responseImage(completionHandler: { [weak self] response in
                        if target == "thumbImage" {
                            self?.thumbImage = response.value
                        } else {
                            self?.frameImage = response.value
                        }
                        observer.onNext(response.value)
                        observer.onCompleted()
                    })
            }
            return Disposables.create()
        })
    }
    
    func frameImageObserve() -> Observable<UIImage?> {
        if frameImage != nil {
            return Observable.just(frameImage)
        }
        if frameModel != nil {
            return thumbModelFrameImage(url: frameModel?.largeThumb ?? "",
                                        target: "frameImage")
        }
        return Observable.just(nil)
    }
    
    func applyFrame(foregroundImage: CIImage) -> CIImage? {
        return GPImageFilter.createEndImage(frameImage,
                                            foregroundImage: foregroundImage)
    }
    
    func applyFilter(image: UIImage) -> UIImage? {
        guard let ciImage = image.toCIImage() else { return image }
        guard let filter = applier else { return image }
        
        let outputImage = filter(ciImage)
        return outputImage?.toUIImage()
    }
    
    public static func coreImageFilter(name: String) -> FilterApplierType {
        return { (image: CIImage) -> CIImage? in
            let filter = CIFilter(name: name)
            filter?.setValue(image, forKey: kCIInputImageKey)
            return filter?.outputImage!
        }
    }
    
    public static func clarendonFilter(foregroundImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(red: 127, green: 187, blue: 227, alpha: Int(255 * 0.2), rect: foregroundImage.extent)
        return foregroundImage.applyingFilter("CIOverlayBlendMode", parameters: [
            "inputBackgroundImage": backgroundImage,
            ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.35,
                "inputBrightness": 0.05,
                "inputContrast": 1.1,
                ])
    }
    
    public static func nashvilleFilter(foregroundImage: CIImage) -> CIImage? {
        let backgroundImage = getColorImage(red: 247, green: 176, blue: 153, alpha: Int(255 * 0.56), rect: foregroundImage.extent)
        let backgroundImage2 = getColorImage(red: 0, green: 70, blue: 150, alpha: Int(255 * 0.4), rect: foregroundImage.extent)
        return foregroundImage
            .applyingFilter("CIDarkenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage,
                ])
            .applyingFilter("CISepiaTone", parameters: [
                "inputIntensity": 0.2,
                ])
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.2,
                "inputBrightness": 0.05,
                "inputContrast": 1.1,
                ])
            .applyingFilter("CILightenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage2,
                ])
    }
    
    public static func apply1977Filter(ciImage: CIImage) -> CIImage? {
        let filterImage = getColorImage(red: 243, green: 106, blue: 188, alpha: Int(255 * 0.1), rect: ciImage.extent)
        let backgroundImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.3,
                "inputBrightness": 0.1,
                "inputContrast": 1.05,
                ])
            .applyingFilter("CIHueAdjust", parameters: [
                "inputAngle": 0.3,
                ])
        return filterImage
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": backgroundImage,
                ])
            .applyingFilter("CIToneCurve", parameters: [
                "inputPoint0": CIVector(x: 0, y: 0),
                "inputPoint1": CIVector(x: 0.25, y: 0.20),
                "inputPoint2": CIVector(x: 0.5, y: 0.5),
                "inputPoint3": CIVector(x: 0.75, y: 0.80),
                "inputPoint4": CIVector(x: 1, y: 1),
                ])
    }
    
    public static func toasterFilter(ciImage: CIImage) -> CIImage? {
        let width = ciImage.extent.width
        let height = ciImage.extent.height
        let centerWidth = width / 2.0
        let centerHeight = height / 2.0
        let radius0 = min(width / 4.0, height / 4.0)
        let radius1 = min(width / 1.5, height / 1.5)
        
        let color0 = self.getColor(red: 128, green: 78, blue: 15, alpha: 255)
        let color1 = self.getColor(red: 79, green: 0, blue: 79, alpha: 255)
        let circle = CIFilter(name: "CIRadialGradient", parameters: [
            "inputCenter": CIVector(x: centerWidth, y: centerHeight),
            "inputRadius0": radius0,
            "inputRadius1": radius1,
            "inputColor0": color0,
            "inputColor1": color1,
            ])?.outputImage?.cropped(to: ciImage.extent)
        
        return ciImage
            .applyingFilter("CIColorControls", parameters: [
                "inputSaturation": 1.0,
                "inputBrightness": 0.01,
                "inputContrast": 1.1,
                ])
            .applyingFilter("CIScreenBlendMode", parameters: [
                "inputBackgroundImage": circle!,
                ])
    }
    
    public static func matbiec5Filter(foregroundImage: CIImage) -> CIImage? {
        let overlayImage = getResizeFilterImage(name: "matbiec_overlay_5",
                                                rect: foregroundImage.extent)
        let softLightImage = getResizeFilterImage(name: "matbiec_soft_light_5",
                                                  rect: foregroundImage.extent)
        var result = foregroundImage
        let gaussianBlur = CIFilter(name: "CIGaussianBlur",
                                    parameters: ["inputImage": result,
                                                 "inputRadius": 2])
        result = gaussianBlur?.outputImage ?? result
        result = overlayImage.applyingFilter("CIOverlayBlendMode",
                                             parameters: ["inputBackgroundImage": result])
        result = softLightImage.applyingFilter("CIOverlayBlendMode",
                                               parameters: ["inputBackgroundImage": result])
        return result
    }
    
    public static func createEndImage(_ frame: UIImage?,
                                      foregroundImage: CIImage) -> CIImage? {
        let endImage = foregroundImage.toUIImage().imageWithBottomFrame(frame: frame)
        return endImage?.toCIImage()
    }
    
    private static func getColor(red: Int, green: Int, blue: Int, alpha: Int = 255) -> CIColor {
        return CIColor(red: CGFloat(Double(red) / 255.0),
                       green: CGFloat(Double(green) / 255.0),
                       blue: CGFloat(Double(blue) / 255.0),
                       alpha: CGFloat(Double(alpha) / 255.0))
    }
    
    private static func getColorImage(red: Int, green: Int, blue: Int, alpha: Int = 255, rect: CGRect) -> CIImage {
        let color = self.getColor(red: red, green: green, blue: blue, alpha: alpha)
        return CIImage(color: color).cropped(to: rect)
    }
    
    private static func getResizeFilterImage(name: String, rect: CGRect) -> CIImage {
        let image
            = GPImageEditorBundle
                .imageFromBundle(imageName: name)?
                .resizeImage(targetSize: rect.size, shouldChangeRatio: true)
                .toCIImage()
        return image ?? CIImage()
    }
    
}
