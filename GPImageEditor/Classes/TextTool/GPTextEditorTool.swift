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
        contentView.autoPinEdgesToSuperviewEdges(with: .all(0), excludingEdge: .top)
        contentView.autoPinEdge(toSuperviewEdge: .top, withInset: 100)
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
        viewModel.rxTextColor ~> contentView.textView.rx.textColor => disposeBag
        viewModel.rxAlignment ~> contentView.textView.rx.textAlignment => disposeBag
        viewModel.rxStackAlignment ~> contentView.stackView.rx.alignment => disposeBag
        viewModel.rxFont ~> contentView.textView.rx.font => disposeBag
        viewModel.rxFont ~> contentView.placeholderLabel.rx.font => disposeBag
        viewModel.rxFontName ~> contentView.fontButton.rx.title(for: .normal) => disposeBag
//        viewModel.rxFontButtonWidth ~> contentView.fontButtonWidth.rx.constant => disposeBag
        viewModel.rxAlignmentIcon ~> contentView.alignButton.rx.image(for: .normal) => disposeBag
        viewModel.rxText.map{ $0 != nil && $0!.count > 0 } ~> contentView.placeholderLabel.rx.isHidden => disposeBag
        
        Observable.combineLatest(viewModel.rxAlignmentIndex, viewModel.rxFont).subscribe(onNext: { [weak self] _ in
            self?.setupPlaceholderOffset()
        }) => disposeBag
        
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
        contentView.doneOverlayButton.rx.tap
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
    
    func setupPlaceholderOffset() {
        let index = viewModel?.rxAlignmentIndex.value ?? 0
        contentView.layoutIfNeeded()
        self.contentView.textViewDidChange(self.contentView.textView)
        if index == 0 {
            self.contentView.placeholderOffsetConstraint.constant = 10
        }
        else if index == 1 {
            self.contentView.placeholderOffsetConstraint.constant = self.contentView.placeholderLabel.frame.width/2
        }
        else {
            self.contentView.placeholderOffsetConstraint.constant = -10
        }
    }
    
    func doneAction() {
        guard let containerView = containerView,
            let viewModel = viewModel,
            let textView = contentView.textView
            else { return }
        let trimText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.rxText.accept(trimText)
        contentView.textView.resignFirstResponder()
        contentView.textView.isHidden = true
        contentView.resetView()
        if textView.text.count > 0 {
            let size = textView.frame.size
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                if let image = self.contentView
                    .captureTextView(scale: GPImageEditorConfigs.textScaleFactor) {
                    let info = viewModel.getStickerInfo(image: image, size: size)
                    let stickerView
                        = StickersLayerView.addSticker(stickerInfo: info, toView: containerView)
                    self.completion?(stickerView)
                }
            }
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
        editor.viewModel?.rxText.accept(nil)
        editor.isHidden = false
        editor.alpha = 0
        editor.contentView.textView.isHidden = false
        editor.contentView.textView.becomeFirstResponder()
        UIView.animate(withDuration: 0.3) {
            editor.alpha = 1
        }
        editor.completion = completion
        return editor
    }
}
