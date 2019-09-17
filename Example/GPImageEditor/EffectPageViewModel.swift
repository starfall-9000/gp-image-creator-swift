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
    var items: [GPImageFilter]
    let rxSelectedFilter = BehaviorRelay<GPImageFilter?>(value: nil)
    
    init(image: UIImage) {
        sourceImage = image
        thumbImage = image.thumbImage()
        items = EffectPageViewModel.createFilterItems(image: image)
        super.init()
        rxSelectedFilter.accept(items.first)
    }
    
    static func createFilterItems(image: UIImage) -> [GPImageFilter] {
        let origin = GPImageFilter(name: "Ảnh gốc", coreImageFilterName: "")
        let gialanh = GPImageFilter(name: "Giá lạnh", coreImageFilterName: "clarendon")
        let tramlang = GPImageFilter(name: "Trầm lắng", coreImageFilterName: "nashville")
        let soidong = GPImageFilter(name: "Sôi động", coreImageFilterName: "toaster")
        let chrome = GPImageFilter(name: "Chrome", coreImageFilterName: "CIPhotoEffectChrome")
        let instant = GPImageFilter(name: "Instant", coreImageFilterName: "CIPhotoEffectInstant")
        let mono = GPImageFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono")
        let tone = GPImageFilter(name: "Tone", coreImageFilterName: "CILinearToSRGBToneCurve")
        let noir = GPImageFilter(name: "Noir", coreImageFilterName: "CIPhotoEffectNoir")
        let process = GPImageFilter(name: "Process", coreImageFilterName: "CIPhotoEffectProcess")
        let transfer = GPImageFilter(name: "Transfer", coreImageFilterName: "CIPhotoEffectTransfer")
        return [origin, tramlang, soidong, gialanh, chrome, instant, mono, tone, noir, process, transfer]
    }
    
}
