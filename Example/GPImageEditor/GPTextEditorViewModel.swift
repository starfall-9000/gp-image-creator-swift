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
    var rxFontButtonWidth: Observable<CGFloat> {
        return rxFontIndex.map{
            let font = UIFont(name: GPImageEditorConfigs.fontSet[$0].1, size: kFontSize) ?? UIFont.systemFont(ofSize: 30)
            let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20)
            let boundingBox = GPImageEditorConfigs.fontSet[$0].0.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
            return boundingBox.size.width + 20
        }
    }
    var rxTextColor: Observable<UIColor?> {
        return rxColorIndex.map{
            let color = self.rxBgColorHidden.value ? GPImageEditorConfigs.colorSet[$0].0 : GPImageEditorConfigs.colorSet[$0].1
            return color
        }
    }
    var rxBgColor: Observable<UIColor?> {
        return rxColorIndex.map{ self.rxBgColorHidden.value ? .clear : GPImageEditorConfigs.colorSet[$0].0 }
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
        return rxFontIndex.map{ UIFont(name: GPImageEditorConfigs.fontSet[$0].1, size: kFontSize) }
    }
    
    var rxFontName: Observable<String?> {
        return rxFontIndex.map{ GPImageEditorConfigs.fontSet[$0].0 }
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
        return StickerInfo(image: image, text: rxText.value ?? "", type: .text, fontIndex: rxFontIndex.value, colorIndex: rxColorIndex.value, alignmentIndex: rxAlignmentIndex.value, size: size)
    }
}
