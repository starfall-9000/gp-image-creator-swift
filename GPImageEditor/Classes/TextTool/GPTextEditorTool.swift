//
//  GPTextEditorView.swift
//  GPImageEditor_Example
//
//  Created by ToanDK on 9/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import DTMvvm

public class GPTextEditorTool: View<GPTextEditorViewModel> {
    let contentView: GPTextEditorView = GPTextEditorView.loadFrom(nibNamed: "GPTextEditorView", bundle: GPImageEditorBundle.getBundle())!
    var completion: ((StickerView?) -> Void)?
    
    var containerView: UIView? = nil
    
    override public func initialize() {
        super.initialize()
        backgroundColor = .clear
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
    }
    
    override public func destroy() {
        super.destroy()
        contentView.doneButton.rx.unbindAction()
        contentView.changeColorButton.rx.unbindAction()
        contentView.fontButton.rx.unbindAction()
        contentView.alignButton.rx.unbindAction()
    }
    
    override public func bindViewAndViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.rxText <~> contentView.textView.rx.text => disposeBag
//        viewModel.rxBgColor ~> contentView.textView.rx.backgroundColor => disposeBag
        viewModel.rxTextColor ~> contentView.textView.rx.textColor => disposeBag
        viewModel.rxAlignment ~> contentView.textView.rx.textAlignment => disposeBag
        viewModel.rxFont ~> contentView.textView.rx.font => disposeBag
        viewModel.rxFont ~> contentView.placeholderLabel.rx.font => disposeBag
        viewModel.rxFontName ~> contentView.fontButton.rx.title(for: .normal) => disposeBag
        viewModel.rxFontButtonWidth ~> contentView.fontButtonWidth.rx.constant => disposeBag
        viewModel.rxAlignmentIcon ~> contentView.alignButton.rx.image(for: .normal) => disposeBag
        
        Observable.combineLatest(viewModel.rxBgColor, viewModel.rxText)
            .subscribe(onNext: { [weak self] (color, text) in
                guard let self = self else { return }
                if text == nil || text!.isEmpty || color == nil || color == .clear {
                    self.contentView.textView.backgroundColor = .clear
                }
                else {
                    self.contentView.textView.backgroundColor = color
                }
            }) => disposeBag
        
        viewModel.rxFont.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.contentView.textViewDidChange(self.contentView.textView)
        }) => disposeBag
        
        contentView.doneButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.doneAction()
            }) => disposeBag
        contentView.showBgButton.rx.bind(to: viewModel.showHideBgAction, input: ())
        viewModel.rxBgColorHidden.map{ !$0 } ~> contentView.showBgButton.rx.isSelected => disposeBag
        for i in 0..<contentView.colorButtons.count {
            let button = contentView.colorButtons[i]
            button.button.rx.bind(to: viewModel.changeColorAction, input: button.tag)
        }
        
        viewModel.rxColorIndex.skip(2).subscribe(onNext: { [weak self] (index) in
            guard let buttons = self?.contentView.colorButtons else { return }
            for button in buttons {
                button.isSelected = button.tag == index
            }
        }) => disposeBag
        
        contentView.fontButton.rx.bind(to: viewModel.changeFontAction, input: ())
        contentView.alignButton.rx.bind(to: viewModel.changeAlignmentAction, input: ())
        
        viewModel.changeColorAction.execute(0)
    }
    
    func doneAction() {
        guard let containerView = containerView,
            let viewModel = viewModel,
            let textView = contentView.textView
            else { return }
        contentView.textView.resignFirstResponder()
        if let image = UIImage.imageWithView(view: textView, size: textView.frame.size) {
            let info = viewModel.getStickerInfo(image: image, size: textView.frame.size)
            let stickerView = StickersLayerView.addSticker(stickerInfo: info, toView: containerView)
            completion?(stickerView)
        }
        contentView.cancelAction()
    }
}

extension GPTextEditorTool {
    @discardableResult
    public static func show(inView view: UIView, completion: ((StickerView?) -> Void)?) -> GPTextEditorTool? {
        var editor: GPTextEditorTool!
        guard let superview = view.superview else { return nil }
        for subview in superview.subviews {
            if subview is GPTextEditorTool {
                editor = (subview as! GPTextEditorTool)
                break
            }
        }
        if editor == nil {
            editor = GPTextEditorTool(viewModel: GPTextEditorViewModel())
            editor.containerView = view
            superview.addSubview(editor)
            editor.autoPinEdgesToSuperviewEdges()
        }
        editor.isHidden = false
        editor.alpha = 0
        editor.contentView.textView.becomeFirstResponder()
        UIView.animate(withDuration: 0.3) {
            editor.alpha = 1
        }
        editor.completion = completion
        return editor
    }
}
