//
//  EffectPageViewModel.swift
//  GPImageEditor
//
//  Created by Ngoc Thang on 9/13/19.
//

import UIKit
import DTMvvm
import RxSwift
import RxCocoa
import Action
import CoreImage

public class EffectPageViewModel: NSObject {
    
    let kBottomMenuHeight = 60 as CGFloat
    let iPhoneXBottomBarHeight = 34 as CGFloat
    var sourceImage: UIImage
    var thumbImage: UIImage
    var filterThumbImage: UIImage?
    let rxSelectedFilter = BehaviorRelay<GPImageFilter?>(value: nil)
    let rxHideTutorial = BehaviorRelay<Bool>(value: false)
    
    init(image: UIImage) {
        sourceImage = image.fixedOrientation()
        thumbImage = sourceImage.thumbImage()
        let bundle = GPImageEditorBundle.getBundle()
        filterThumbImage = UIImage(named: "filter-example-image", in: bundle, compatibleWith: nil)
        super.init()
        if let image = sourceImage.croppedImageForEditing(with: maxImageSizeForEditing()) {
            sourceImage = image
            thumbImage = sourceImage.thumbImage()
        }
        rxSelectedFilter.accept(items.first)
    }
    
    func maxImageSizeForEditing() -> CGSize {
        var height = UIScreen.main.bounds.height - kBottomMenuHeight
        if UI_USER_INTERFACE_IDIOM() == .phone {
            let screenSize = UIScreen.main.bounds.size
            if screenSize.height >= 812.0 {
                height -= iPhoneXBottomBarHeight
            }
        }
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
    public var items: [GPImageFilter] = [
        GPImageFilter(name: "Ảnh gốc", applier: nil),
        GPImageFilter(name: "Giá lạnh", applier: GPImageFilter.clarendonFilter),
        GPImageFilter(name: "Trầm lắng", coreImageFilterName: "CIPhotoEffectProcess"),
        GPImageFilter(name: "Sôi động", coreImageFilterName: "CIPhotoEffectTransfer"),
        GPImageFilter(name: "Hà Nội", coreImageFilterName: "CIPhotoEffectChrome"),
        GPImageFilter(name: "Huế", coreImageFilterName: "CIPhotoEffectInstant"),
        GPImageFilter(name: "Hội An", coreImageFilterName: "CIPhotoEffectMono"),
        GPImageFilter(name: "Sài Gòn", coreImageFilterName: "CILinearToSRGBToneCurve"),
        GPImageFilter(name: "Party", applier: GPImageFilter.partyFrame),
        GPImageFilter(name: "Petro", applier: GPImageFilter.petroFrame),
        GPImageFilter(name: "Comic", applier: GPImageFilter.comicFrame),
    ]
    
}
