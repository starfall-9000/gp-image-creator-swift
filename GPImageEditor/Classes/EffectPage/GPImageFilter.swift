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

public typealias FilterApplierType = ((_ image: CIImage) -> CIImage?)

public class GPImageFilter: NSObject {
    
    var name = ""
    var applier: FilterApplierType?
    var thumbImage: UIImage?
    
    public init(name: String, coreImageFilterName: String) {
        super.init()
        self.name = name
        self.applier = GPImageFilter.coreImageFilter(name: coreImageFilterName)
    }
    
    public init(name: String,
                applier: FilterApplierType?,
                imageStr: String? = nil) {
        super.init()
        self.name = name
        self.applier = applier
        if let imageStr = imageStr {
            self.thumbImage = GPImageEditorBundle.imageFromBundle(imageName: imageStr)
        }
    }
    
    func thumbImageObserver(from image: UIImage?) -> Observable<UIImage?> {
        guard let image = image else { return Observable.just(nil) }
        if thumbImage != nil {
            return Observable.just(thumbImage)
        }
        if name.lowercased() == "party" {
            let image = GPImageFilter.partyFrameImage()
            return Observable.just(image?.thumbImage())
        }
        if name.lowercased() == "petro" {
            let image = GPImageFilter.petroFrameImage()
            return Observable.just(image?.thumbImage())
        }
        if name.lowercased() == "comic" {
            let image = GPImageFilter.comicFrameImage()
            return Observable.just(image?.thumbImage())
        }
        
        return Observable.create({ [weak self] (observer) -> Disposable in
            guard let self = self else { return Disposables.create() }
            
            self.thumbImage = self.applyFilter(image: image)
            observer.onNext(self.thumbImage)
            observer.onCompleted()
            return Disposables.create()
        })
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
    
    private static func partyFrameImage() -> UIImage? {
        return GPImageEditorBundle.imageFromBundle(imageName: "Frame 1")
    }
    
    private static func petroFrameImage() -> UIImage? {
        return GPImageEditorBundle.imageFromBundle(imageName: "Frame 2")
    }
    
    private static func comicFrameImage() -> UIImage? {
        return GPImageEditorBundle.imageFromBundle(imageName: "Frame 3")
    }
    
    private static func matbiec1FrameImage() -> UIImage? {
        return GPImageEditorBundle.imageFromBundle(imageName: "matbiec_filter_1")
    }
    
    private static func matbiec2FrameImage() -> UIImage? {
        return GPImageEditorBundle.imageFromBundle(imageName: "matbiec_filter_2")
    }
    
    private static func matbiec3FrameImage() -> UIImage? {
        return GPImageEditorBundle.imageFromBundle(imageName: "matbiec_filter_3")
    }
    
    private static func matbiec4FrameImage() -> UIImage? {
        return GPImageEditorBundle.imageFromBundle(imageName: "matbiec_filter_4")
    }
    
    public static func partyFrame(foregroundImage: CIImage) -> CIImage? {
        let frame = GPImageFilter.partyFrameImage()
        return createEndImage(frame, foregroundImage: foregroundImage)
    }
    
    public static func petroFrame(foregroundImage: CIImage) -> CIImage? {
        let frame = GPImageFilter.petroFrameImage()
        return createEndImage(frame, foregroundImage: foregroundImage)
    }
    
    public static func comicFrame(foregroundImage: CIImage) -> CIImage? {
        let frame = GPImageFilter.comicFrameImage()
        return createEndImage(frame, foregroundImage: foregroundImage)
    }
    
    public static func matbiec1Frame(foregroundImage: CIImage) -> CIImage? {
        let frame = GPImageFilter.matbiec1FrameImage()
        return createEndImage(frame, foregroundImage: foregroundImage)
    }
    
    public static func matbiec2Frame(foregroundImage: CIImage) -> CIImage? {
        let frame = GPImageFilter.matbiec2FrameImage()
        return createEndImage(frame, foregroundImage: foregroundImage)
    }
    
    public static func matbiec3Frame(foregroundImage: CIImage) -> CIImage? {
        let frame = GPImageFilter.matbiec3FrameImage()
        return createEndImage(frame, foregroundImage: foregroundImage)
    }
    
    public static func matbiec4Frame(foregroundImage: CIImage) -> CIImage? {
        let frame = GPImageFilter.matbiec4FrameImage()
        return createEndImage(frame, foregroundImage: foregroundImage)
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
    
}
