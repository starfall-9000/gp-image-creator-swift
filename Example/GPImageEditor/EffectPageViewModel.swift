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
    
    var sourceImage: UIImage
    var thumbImage: UIImage
    let rxSelectedFilter = BehaviorRelay<GPImageFilter?>(value: nil)
    
    init(image: UIImage) {
        sourceImage = image.fixedOrientation()
        thumbImage = sourceImage.thumbImage()
        super.init()
        rxSelectedFilter.accept(items.first)
    }
    
    public var items: [GPImageFilter] = [
        GPImageFilter(name: "Ảnh gốc", applier: nil),
        GPImageFilter(name: "Giá lạnh", applier: GPImageFilter.clarendonFilter),
        GPImageFilter(name: "Trầm lắng", applier: GPImageFilter.nashvilleFilter),
        GPImageFilter(name: "Sôi động", applier: GPImageFilter.toasterFilter),
        GPImageFilter(name: "Chrome", coreImageFilterName: "CIPhotoEffectChrome"),
        GPImageFilter(name: "Instant", coreImageFilterName: "CIPhotoEffectInstant"),
        GPImageFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        GPImageFilter(name: "Tone", coreImageFilterName: "CILinearToSRGBToneCurve"),
        GPImageFilter(name: "Noir", coreImageFilterName: "CIPhotoEffectNoir"),
        GPImageFilter(name: "Process", coreImageFilterName: "CIPhotoEffectProcess"),
        GPImageFilter(name: "Transfer", coreImageFilterName: "CIPhotoEffectTransfer"),
    ]
    
}
