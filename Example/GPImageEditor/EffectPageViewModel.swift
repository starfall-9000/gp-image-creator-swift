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
        sourceImage = image
        thumbImage = image.thumbImage()
        super.init()
        rxSelectedFilter.accept(items.first)
    }
    
    public var items: [GPImageFilter] = [
        GPImageFilter(name: "Ảnh gốc", coreImageFilterName: ""),
        GPImageFilter(name: "Giá lạnh", coreImageFilterName: "clarendon"),
        GPImageFilter(name: "Trầm lắng", coreImageFilterName: "nashville"),
        GPImageFilter(name: "Sôi động", coreImageFilterName: "toaster"),
        GPImageFilter(name: "Chrome", coreImageFilterName: "CIPhotoEffectChrome"),
        GPImageFilter(name: "Instant", coreImageFilterName: "CIPhotoEffectInstant"),
        GPImageFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
        GPImageFilter(name: "Tone", coreImageFilterName: "CILinearToSRGBToneCurve"),
        GPImageFilter(name: "Noir", coreImageFilterName: "CIPhotoEffectNoir"),
        GPImageFilter(name: "Process", coreImageFilterName: "CIPhotoEffectProcess"),
        GPImageFilter(name: "Transfer", coreImageFilterName: "CIPhotoEffectTransfer"),
    ]
    
}
