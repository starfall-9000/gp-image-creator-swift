//
//  GPTextEditorViewModel.swift
//  GPImageEditor_Example
//
//  Created by ToanDK on 9/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import DTMvvm
import Action

private let kFontSize: CGFloat = 30

public class GPTextEditorViewModel: ViewModel<StickerInfo> {
    
    let rxText = BehaviorRelay<String?>(value: nil)
    let rxFontIndex = BehaviorRelay<Int>(value: 0)
    let rxColorIndex = BehaviorRelay<Int>(value: 0)
    let rxBgColorHidden = BehaviorRelay<Bool>(value: true)
    let rxAlignmentIndex = BehaviorRelay<Int>(value: 0)
//    var rxFontButtonWidth: Observable<CGFloat> {
//        return rxFontIndex.map{
//            let config = GPImageEditorConfigs.fontSet[$0]
//            let font = UIFont.boldSystemFont(ofSize: 16)
//            let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20)
//            let boundingBox = config.name.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
//            return boundingBox.size.width + 30
//        }
//    }
    var rxTextColor: Observable<UIColor?> {
        return rxColorIndex.map{
            let color = self.rxBgColorHidden.value ? GPImageEditorConfigs.colorSet[$0].bgColor : GPImageEditorConfigs.colorSet[$0].textColor
            return UIColor.fromHex(color)
        }
    }
    var rxBgColor: Observable<UIColor?> {
        return rxColorIndex.map{ self.rxBgColorHidden.value ? .clear : UIColor.fromHex(GPImageEditorConfigs.colorSet[$0].bgColor) }
    }
    var rxStackAlignment: Observable<UIStackView.Alignment> {
        let alignments: [UIStackView.Alignment] = [.leading, .center, .trailing]
        return rxAlignmentIndex.map{ alignments[$0] }
    }
    var rxAlignment: Observable<NSTextAlignment> {
        let alignments: [NSTextAlignment] = [.left, .center, .right]
        return rxAlignmentIndex.map{ alignments[$0] }
    }
    var rxAlignmentIcon: Observable<UIImage?> {
        let names: [String] = ["ie_ic_align-left", "ie_ic_align-center", "ie_ic_align-right"]
        return rxAlignmentIndex.map{ GPImageEditorBundle.imageFromBundle(imageName: names[$0]) }
    }
    var rxFont: Observable<UIFont?> {
        return rxFontIndex.map{
            let fontInfo = GPImageEditorConfigs.fontSet[$0]
            return UIFont(name: fontInfo.font, size: CGFloat(fontInfo.size))
        }
    }
    
    var rxFontName: Observable<String?> {
        return rxFontIndex.map{ GPImageEditorConfigs.fontSet[$0].name }
    }
    
    var rxTextInset: Observable<CGFloat> {
        return rxFontIndex.map{ CGFloat(GPImageEditorConfigs.fontSet[$0].inset) }
    }
    
    lazy var changeColorAction: Action<Int, Void> = {
        return Action { index in
            .just(self.changeColor(index))
        }
    }()
    
    lazy var changeAlignmentAction: Action<Void, Void> = {
        return Action { index in
            .just(self.changeAlignment())
        }
    }()
    
    lazy var changeFontAction: Action<Void, Void> = {
        return Action { index in
            .just(self.changeFont())
        }
    }()
    
    lazy var showHideBgAction: Action<Void, Void> = {
        return Action { index in
            .just(self.showHideBg())
        }
    }()
    
    
    override public func modelChanged() {
        super.modelChanged()
        guard let model = model else { return }
        rxText.accept(model.text)
        rxFontIndex.accept(model.fontIndex)
        rxColorIndex.accept(model.colorIndex)
        rxAlignmentIndex.accept(model.alignmentIndex)
    }
    
    func changeAlignment() {
        rxAlignmentIndex.accept((rxAlignmentIndex.value + 1) % 3)
    }
    
    func showHideBg() {
        rxBgColorHidden.accept(!rxBgColorHidden.value)
        rxColorIndex.accept(rxColorIndex.value)
    }
    
    func changeColor(_ index: Int) {
        rxColorIndex.accept(index)
    }
    
    func changeFont() {
        rxFontIndex.accept((rxFontIndex.value + 1) % GPImageEditorConfigs.fontSet.count)
    }
    
    func getStickerInfo(image: UIImage, size: CGSize) -> StickerInfo {
        let position: CGPoint = model?.position ?? .zero
        let viewSize: CGSize = model?.viewSize ?? .zero
        let scale = model?.scale ?? 1.0
        return StickerInfo(image: image, text: rxText.value ?? "", type: .text, fontIndex: rxFontIndex.value, bgColorHidden: rxBgColorHidden.value, colorIndex: rxColorIndex.value, alignmentIndex: rxAlignmentIndex.value, size: size, scale: scale, viewSize: viewSize, position: position, transform: model?.transform)
    }
}
