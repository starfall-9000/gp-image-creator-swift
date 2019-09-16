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
        let tramlang = GPImageFilter(name: "Trầm lắng", coreImageFilterName: "clarendon")
        let soidong = GPImageFilter(name: "Sôi động", coreImageFilterName: "nashville")
        let gialanh = GPImageFilter(name: "Giá lạnh", coreImageFilterName: "toaster")
        return [origin, tramlang, soidong, gialanh]
    }
    
}
