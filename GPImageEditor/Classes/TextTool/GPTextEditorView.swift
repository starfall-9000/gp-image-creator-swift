//
//  GPTextEditorView.swift
//  GPImageEditor_Example
//
//  Created by ToanDK on 9/17/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import DTMvvm

private let kAnimationTime = 0.3
private let kColorButtonWidth: CGFloat = 40

class ColorButton: UIView {
    let button = UIButton()
    let circle = UIImageView()
    var circleWidth: NSLayoutConstraint!
    
    var isSelected: Bool = false {
        didSet {
            circleWidth.constant = isSelected ? frame.width * 0.7 : frame.width * 0.5
        }
    }
    
    var bgColor: UIColor = .clear {
        didSet {
            circle.backgroundColor = bgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circle.layer.masksToBounds = true
        circle.layer.cornerRadius = circle.frame.width/2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(button)
        button.autoPinEdgesToSuperviewEdges()
        
        addSubview(circle)
        circle.autoMatch(.width, to: .height, of: circle)
        circleWidth = circle.autoSetDimension(.width, toSize: kColorButtonWidth * 0.5)
        circle.autoCenterInSuperview()
        circle.layer.borderColor = UIColor.white.cgColor
        circle.layer.borderWidth = 1
        circle.layer.masksToBounds = true
        circle.layer.cornerRadius = circle.frame.size.width/2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: ColorButton {
    var isSelected: Binder<Bool> {
        return Binder(base) { $0.isSelected = $1 }
    }
}

class GPTextEditorView: UIView {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneOverlayButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var alignButton: UIButton!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var changeColorButton: UIButton!
    @IBOutlet var bottomView: UIView!
    @IBOutlet weak var menuBottomView: UIView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorScrollView: ScrollLayout!
    @IBOutlet weak var fontButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var placeholderOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    var showBgButton: UIButton!
    let hideButton = UIButton(type: .custom)
    let tutorialView = GPTutorialView.fontEditTutorial
    
    var colorButtons: [ColorButton] = []
    private var disposeBag: DisposeBag? = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.buildEditorTextView()
        textView.isScrollEnabled = true
        textView.delegate = self
        
        fontButton.layer.masksToBounds = true
        fontButton.layer.cornerRadius = fontButton.frame.height/2
        fontButton.layer.borderColor = UIColor.fromHex("#B2B2B2").cgColor
        fontButton.layer.borderWidth = 0.5
        
        let shouldShowTutorial = GPTutorialView.shouldShowTutorial(.GPFontEditTutorial)
        if (shouldShowTutorial) {
            addSubview(hideButton)
            bringSubviewToFront(hideButton)
            hideButton.autoPinEdgesToSuperviewEdges()
            hideButton.addSubview(tutorialView)
            tutorialView.autoAlignAxis(toSuperviewAxis: .vertical)
            
            tutorialView.autoPinEdge(.bottom, to: .bottom, of: stackView.superview!, withOffset: -10)
            hideButton.addTarget(self, action: #selector(handleHide(_:)), for: .touchUpInside)
        }
        
        colorPickerView.isHidden = true
        addColorPicker()
        showKeyboard()
        bottomView.removeFromSuperview()
        textView.inputAccessoryView = bottomView
    }
    
    @objc func handleHide(_ sender: UIButton) {
        hideButton.isHidden = true
    }
    
    func showKeyboard() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let self = self else { return }
                let keyboardHeight = notification.getKeyboardHeight()
                self.contentViewHeight.constant = UIScreen.main.bounds.height - keyboardHeight
                self.disposeBag = nil
            }) => disposeBag
        textView.becomeFirstResponder()
    }
    
    func addColorPicker() {
        showBgButton = UIButton(frame: .zero)
        showBgButton.autoSetDimensions(to: CGSize(width: kColorButtonWidth, height: colorPickerView.frame.height))
        showBgButton.setImage(GPImageEditorBundle.imageFromBundle(imageName: "ie_ic_text_border_active"), for: .selected)
        showBgButton.setImage(GPImageEditorBundle.imageFromBundle(imageName: "ie_ic_text_border"), for: .normal)
        colorScrollView.appendChild(showBgButton)
        
        for i in 0..<GPImageEditorConfigs.colorSet.count {
            let colorInfo = GPImageEditorConfigs.colorSet[i]
            let button = ColorButton(frame: .zero)
            button.autoSetDimensions(to: CGSize(width: kColorButtonWidth, height: colorPickerView.frame.height))
            button.tag = i
            button.bgColor = UIColor.fromHex(colorInfo.bgColor)
            colorButtons.append(button)
            colorScrollView.appendChild(button)            
        }
    }
}

extension GPTextEditorView: UITextViewDelegate, NSLayoutManagerDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if (textView.text.count > 0) {
            handleHide(hideButton)
        }
        let maxWidth = frame.width - 60
        var newSize = textView.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        if textView.text.count == 0 {
            newSize.width = placeholderLabel.frame.width
        }
        textViewHeight.constant = newSize.height
        textViewWidthConstraint.constant = min(newSize.width, maxWidth)
        textView.superview?.layoutIfNeeded()
        textView.scrollToBottom()
    }
}

extension GPTextEditorView {
    
    // MARK: Actions
    
    @IBAction func cancelAction() {
        textView.resignFirstResponder()
        UIView.animate(withDuration: kAnimationTime, animations: {
            self.superview?.alpha = 0
        }) { _ in
            self.superview?.isHidden = true
        }
    }
    
    @IBAction func hideColorPickerAction() {
        menuBottomView.alpha = 0
        menuBottomView.isHidden = false
        UIView.animate(withDuration: kAnimationTime, animations: {
            self.colorPickerView.alpha = 0
            self.menuBottomView.alpha = 1
        }) { _ in
            self.colorPickerView.isHidden = true
        }
    }
    
    @IBAction func showColorPickerAction() {
        colorPickerView.alpha = 0
        colorPickerView.isHidden = false
        UIView.animate(withDuration: kAnimationTime, animations: {
            self.colorPickerView.alpha = 1
            self.menuBottomView.alpha = 0
        }) { _ in
            self.menuBottomView.isHidden = true
        }
    }
}

extension GPTextEditorView {
    func captureTextView(scale: CGFloat) -> UIImage? {
        let originalWidth = textViewWidthConstraint.constant
        let originalHeight = textViewHeight.constant
        let originalFontSize = textView.font?.pointSize ?? 0
        let originalStackOffset = stackOffsetConstraint.constant
        stackOffsetConstraint.constant = -originalWidth * scale
        textViewHeight.constant = originalHeight * scale
        textViewWidthConstraint.constant = originalWidth * scale
        textView.font = UIFont(name: textView.font?.fontName ?? "", size: originalFontSize * scale)
        textView.layer.cornerRadius = 4 * scale
        textView.textContainerInset = .only(top: 10 * scale, bottom: 10 * scale, left: 10 * scale, right: 10 * scale)
        stackView.layoutIfNeeded()
        textView.layoutIfNeeded()
        
        let image = UIImage.imageWithView(view: textView, size: textView.frame.size)
        
        stackOffsetConstraint.constant = originalStackOffset
        textViewHeight.constant = originalHeight
        textViewWidthConstraint.constant = originalWidth
        textView.font = UIFont(name: textView.font?.fontName ?? "", size: originalFontSize)
        textView.layer.cornerRadius = 4
        textView.textContainerInset = .only(top: 10, bottom: 10, left: 10, right: 10)
        stackView.layoutIfNeeded()
        textView.layoutIfNeeded()
        return image
    }
}
