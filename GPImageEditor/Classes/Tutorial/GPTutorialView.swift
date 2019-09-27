//
//  GPTutorialView.swift
//
//  Created by ToanDK on 7/10/19.
//

import Foundation
import DTMvvm
import RxSwift
import RxCocoa
import Action

extension Reactive where Base: GPTutorialView {
    
    var number: Binder<Int> {
        return Binder(base) { $0.number = $1 }
    }
    
    var title: Binder<String> {
        return Binder(base) { $0.title = $1 }
    }
    
    var isSelected: Binder<Bool> {
        return Binder(base) { $0.isSelected = $1 }
    }
}


class GPTutorialView: AbstractView {
    var activeColor: UIColor = .clear {
        didSet {
            guard let bottomLine = bottomLine,
                let arrow = arrowView,
                let overlayBg = overlayBg else { return }
            bottomLine.backgroundColor = activeColor
            overlayBg.backgroundColor = activeColor
            arrow.color = activeColor
        }
    }
    var inactiveColor: UIColor = .clear {
        didSet {
            guard let contentView = contentView else { return }
            contentView.backgroundColor = inactiveColor
        }
    }
    var number: Int = 0 {
        didSet {
            guard let numberLabel = numberLabel else { return }
            numberLabel.text = "\(number)"
        }
    }
    
    var title: String = "" {
        didSet {
            guard let titleLabel = titleLabel else { return }
            titleLabel.text = title
        }
    }
    
    var textColor: UIColor = .white {
        didSet {
            guard let titleLabel = titleLabel else { return }
            titleLabel.textColor = textColor
        }
    }
    
    var icon: UIImage? = nil {
        didSet {
            guard let alertIcon = alertIcon else { return }
            alertIcon.image = icon
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            guard let overlayBg = overlayBg, let arrowView = arrowView else { return }
            overlayBg.isHidden = !isSelected
            arrowView.isHidden = !isSelected
        }
    }
    
    var reversed: Bool = false {
        didSet {
            guard
                let contentView = contentView
            else { return }
            var newTransform: CGAffineTransform;
            if reversed {
                newTransform = CGAffineTransform(rotationAngle: CGFloat.pi)
            } else {
                newTransform = .identity
            }
            transform = newTransform
            contentView.transform = newTransform
        }
    }
    
    var didSelect: ((Int) -> ())?
    
    fileprivate var numberLabel: UILabel!
    fileprivate var titleLabel: UILabel!
    fileprivate var bottomLine: UIImageView!
    fileprivate var alertIcon: UIImageView!
    fileprivate var overlayBg: UIImageView!
    fileprivate var contentView: UIView!
    fileprivate var arrowView: GPTriangleView!
    let overlayButton = UIButton()
    
    override func setupView() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        contentView = UIView()
        contentView.cornerRadius = 4
        contentView.clipsToBounds = true
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges(with: .only(top: 9, bottom: 0, left: 0, right: 0))
        
        overlayBg = UIImageView()
        contentView.addSubview(overlayBg)
        overlayBg.autoPinEdgesToSuperviewEdges()
        
        alertIcon = UIImageView()
        contentView.addSubview(alertIcon)
        alertIcon.autoPinEdgesToSuperviewEdges(with: .only(top: 8, bottom: 8, left: 12), excludingEdge: .right)
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textColor = UIColor.white
        contentView.addSubview(titleLabel)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        titleLabel.autoPinEdge(.left, to: .right, of: alertIcon, withOffset: 8)
        titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 13)
        
        numberLabel = UILabel()
        numberLabel.numberOfLines = 0
        numberLabel.textAlignment = .center
        numberLabel.font = UIFont.systemFont(ofSize: 20)
        numberLabel.textColor = UIColor.white
        contentView.addSubview(numberLabel)
        numberLabel.autoPinEdgesToSuperviewEdges(with: .only(bottom: 10, left: 5, right: 5), excludingEdge: .top)
        
        bottomLine = UIImageView()
        contentView.addSubview(bottomLine)
        bottomLine.autoPinEdgesToSuperviewEdges(with: .only(bottom: 0, left: 0, right: 0), excludingEdge: .top)
        bottomLine.autoSetDimension(.height, toSize: 0)
        
        arrowView = GPTriangleView(frame: CGRect(x: 0, y: 0, width: 24, height: 9))
        arrowView.backgroundColor = .clear
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowView)
        arrowView.autoPinEdge(.top, to: .top, of: self)
        arrowView.autoSetDimensions(to: arrowView.frame.size)
        arrowView.autoAlignAxis(toSuperviewAxis: .vertical)
        arrowView.reversed = true
        arrowView.setNeedsDisplay()
        
        addSubview(overlayButton)
        overlayButton.autoPinEdgesToSuperviewEdges()
    }
}

public enum GPTutorialType: String {
    case GPStickerTutorial = "GPStickerTutorial"
    case GPTextEditTutorial = "GPTextEditTutorial"
    case GPFontEditTutorial = "GPFontEditTutorial"
}

extension GPTutorialView {
    public static func shouldShowTutorial(_ type: GPTutorialType) -> Bool {
        let storageService:IStorageService = DependencyManager.shared.getService()
        let alreadyShowTutorial:Bool = storageService.get(forKey: type.rawValue) ?? false
        if !alreadyShowTutorial {
            storageService.save(true, forKey: type.rawValue)
        }
        return !alreadyShowTutorial
    }
    
    public static var stickerTutorial: GPTutorialView {
        return tutorialWithType(.GPStickerTutorial)
    }
    
    public static var textEditTutorial: GPTutorialView {
        return tutorialWithType(.GPTextEditTutorial)
    }
    
    public static var fontEditTutorial: GPTutorialView {
        return tutorialWithType(.GPFontEditTutorial)
    }
    
    public static func tutorialWithType(_ type: GPTutorialType) -> GPTutorialView {
        let tutorialView = GPTutorialView()
        let bundle = GPImageEditorBundle.getBundle()
        var activeColor: UIColor = .clear
        var title: String = ""
        var size: CGSize = .zero
        var icon: UIImage? = nil
        var textColor: UIColor = .white
        var reversed: Bool = false
        switch type {
        case .GPStickerTutorial:
            activeColor = .init(r: 0, g: 0, b: 0, a: 0.8)
            title = "Ấn hoặc giữ nhãn dán để tuỳ chỉnh"
            size = CGSize(width: 260, height: 41)
            icon = UIImage(named: "ic_tutorial_alert", in: bundle, compatibleWith: nil)
            break
        case .GPTextEditTutorial:
            activeColor = .init(r: 0, g: 0, b: 0, a: 0.8)
            title = "Ấn hoặc giữ Text để tuỳ chỉnh"
            size = CGSize(width: 230, height: 41)
            icon = UIImage(named: "ic_tutorial_alert", in: bundle, compatibleWith: nil)
            break
        case .GPFontEditTutorial:
            activeColor = .init(r: 255, g: 255, b: 255, a: 0.9)
            title = "Tuỳ chỉnh font chữ"
            size = CGSize(width: 162, height: 41)
            icon = UIImage(named: "ic_tutorial_alert_gray", in: bundle, compatibleWith: nil)
            textColor = .fromHex("#1A1A1A")
            reversed = true
            break
        }
        tutorialView.activeColor = activeColor
        tutorialView.title = title
        tutorialView.autoSetDimensions(to: size)
        tutorialView.icon = icon
        tutorialView.textColor = textColor
        tutorialView.reversed = reversed
        return tutorialView
    }
}
