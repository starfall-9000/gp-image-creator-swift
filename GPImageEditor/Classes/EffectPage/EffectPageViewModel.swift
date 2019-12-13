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
    var stickerInfos: [StickerInfo] = []
    
    let rxImageCenter = BehaviorRelay<CGPoint> (value: .zero)
    let rxImageScale = BehaviorRelay<CGFloat> (value: 1)
    let rxImageTransform = BehaviorRelay<CGAffineTransform> (value: .identity)
    var disposeBag: DisposeBag? = DisposeBag()
    
    let GP_MIN_FRAME_SCALE: CGFloat = 0.1
    let GP_MAX_FRAME_SCALE: CGFloat = 5
    
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
        rxImageScale.subscribe(onNext: { [weak self] (_) in
            guard let self = self else { return }
            self.applyImageChange()
        }) => disposeBag
    }
    
    deinit {
       disposeBag = nil
    }
    
    public func applyImageChange() {
        let imageScale = rxImageScale.value
        let transform = CGAffineTransform(scaleX: imageScale, y: imageScale)
        rxImageTransform.accept(transform)
    }
    
    public func resetImageTransform() {
        rxImageScale.accept(1)
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
        GPImageFilterType.matbiec1.getImageFilter(),
        GPImageFilterType.matbiec2.getImageFilter(),
        GPImageFilterType.matbiec3.getImageFilter(),
        GPImageFilterType.matbiec4.getImageFilter(),
        GPImageFilterType.matbiec5.getImageFilter(),
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
    
    func handleMergeGestureFrame(filterFrame: CGRect) -> UIImage? {
        guard let filter = rxSelectedFilter.value, filter.allowGesture
        else { return sourceImage }
        let cropImage
            = sourceImage.cropTransformImage(maskFrame: filterFrame,
                                             transform: rxImageTransform.value)
        return filter.applyFilter(image: cropImage)
    }
    
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
    
    func handleZoom(_ scale: CGFloat) {
        // not enable this feature with image frame not has gesture
        guard (rxSelectedFilter.value?.allowGesture ?? false) else { return }
        var newScale = rxImageScale.value * scale
        newScale = newScale < GP_MIN_FRAME_SCALE ? GP_MIN_FRAME_SCALE : newScale
        newScale = newScale > GP_MAX_FRAME_SCALE ? GP_MAX_FRAME_SCALE : newScale
        rxImageScale.accept(newScale)
    }
    
    func handlePan(_ translation: CGPoint) {
        // not enable this feature with image frame not has gesture
        guard (rxSelectedFilter.value?.allowGesture ?? false) else { return }
        var currentCenter = rxImageCenter.value
        currentCenter = CGPoint(x: currentCenter.x + translation.x,
                                y: currentCenter.y + translation.y)
        rxImageCenter.accept(currentCenter)
    }
    
    func recordEditorCancel() {
        GPImageEditorConfigs.analyticsTracker?.recordEvent(PEAnalyticsEvent.PHOTO_EDITOR_CANCEL, params: nil)
    }
    
    func recordEditorShown() {
        GPImageEditorConfigs.analyticsTracker?.recordEvent(PEAnalyticsEvent.PHOTO_EDITOR_SHOWN, params: nil)
    }
}
