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
    var sourceImage: UIImage
    var thumbImage: UIImage
    var filterThumbImage: UIImage?
    let rxSelectedFilter = BehaviorRelay<GPImageFilter?>(value: nil)
    let rxHideTutorial = BehaviorRelay<Bool>(value: false)
    var stickerInfos: [StickerInfo] = []
    
    init(image: UIImage) {
        sourceImage = image.fixedOrientation()
        if let image = sourceImage.croppedImageForEditing(with: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - kBottomMenuHeight)) {
            sourceImage = image
        }
        thumbImage = sourceImage.thumbImage()
        let bundle = GPImageEditorBundle.getBundle()
        filterThumbImage = UIImage(named: "filter-example-image", in: bundle, compatibleWith: nil)
        super.init()
        rxSelectedFilter.accept(items.first)
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
    
    func recordEditorFinished() {
        var params: [AnyHashable: Any] = [:]
        if let filterId = rxSelectedFilter.value?.name {
            params[PEAnalyticsEvent.FILTER_ID] = filterId
        }
        let stickers = stickerInfos.filter{ $0.type == .sticker }
        if stickers.count > 0 {
            let stickerIds = stickers.map{ $0.stickerId }.joined(separator: ",")
            params[PEAnalyticsEvent.STICKER_IDS] = stickerIds
        }
        let emojis = stickerInfos.filter{ $0.type == .emoji }
        if emojis.count > 0 {
            let emojiIds = stickers.map{ $0.stickerId }.joined(separator: ",")
            params[PEAnalyticsEvent.EMOJI_IDS] = emojiIds
        }
        let texts = stickerInfos.filter{ $0.type == .text }
        params[PEAnalyticsEvent.HAVE_TEXT] = texts.count > 0 ? "true" : "false"
        
        GPImageEditorConfigs.analyticsTracker?.recordEvent(PEAnalyticsEvent.PHOTO_EDITOR_FINISHED, params: params)
    }
    
    func recordEditorCancel() {
        GPImageEditorConfigs.analyticsTracker?.recordEvent(PEAnalyticsEvent.PHOTO_EDITOR_CANCEL, params: nil)
    }
    
    func recordEditorShown() {
        GPImageEditorConfigs.analyticsTracker?.recordEvent(PEAnalyticsEvent.PHOTO_EDITOR_SHOWN, params: nil)
    }
}
