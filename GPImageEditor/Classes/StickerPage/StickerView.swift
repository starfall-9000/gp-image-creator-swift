//
//  DraggableImageView.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/11/19.
//

import Foundation
import CoreGraphics

public class StickersLayerView: UIView {
    
    var offSet: CGPoint!
    var viewTransform: CGAffineTransform!
    var viewSize: CGSize!
    var isDragging = false
    var isOverlap = false
    
    var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(GPImageEditorBundle.imageFromBundle(imageName: "ic_delete"), for: .normal)
        button.setImage(GPImageEditorBundle.imageFromBundle(imageName: "ie_ic_delete_active"), for: .selected)
        return button
    }()
    
    var activeView: StickerView? = nil {
        didSet {
            if let activeView = activeView {
                activeView.superview?.bringSubview(toFront: activeView)
            }
        }
    }
    
    @discardableResult
    public static func addSticker(stickerInfo: StickerInfo, toView: UIView) -> StickerView {
        let stickerView = StickerView(stickerInfo: stickerInfo)
        var stickersLayer = toView.subviews.first{ $0 is StickersLayerView } as? StickersLayerView
        if stickersLayer == nil {
            stickersLayer = StickersLayerView(frame: .zero)
            toView.addSubview(stickersLayer!)
            stickersLayer?.autoPinEdgesToSuperviewEdges()
        }
        stickerView.add(toView: stickersLayer!)
        
        stickersLayer?.activeView = stickerView
        
        stickerView.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            stickerView.alpha = 1.0
        })
        return stickerView
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        addSubview(deleteButton)
        deleteButton.autoAlignAxis(.vertical, toSameAxisOf: self)
        deleteButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 26)
        deleteButton.autoSetDimensions(to: CGSize(width: 48, height: 48))
        deleteButton.isUserInteractionEnabled = false
        deleteButton.isHidden = true
        
        addGestures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addGestures() {
        self.isUserInteractionEnabled = true
        let taps = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.addGestureRecognizer(taps)
        let drags = UIPanGestureRecognizer(target: self, action: #selector(drag))
        self.addGestureRecognizer(drags)
        let pinches = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        self.addGestureRecognizer(pinches)
        let rotates = UIRotationGestureRecognizer(target: self, action: #selector(rotate))
        self.addGestureRecognizer(rotates)
    }
    
    func showDeleteButton() {
        deleteButton.alpha = 0
        deleteButton.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.deleteButton.alpha = 1.0
        }
    }
    
    func hideDeleteButton() {
        UIView.animate(withDuration: 0.3) {
            self.deleteButton.alpha = 0
        }
    }
    
    func deleteSticker(stickerView: StickerView) {
        var nextTarget: StickerView? = nil
        guard
            let index = subviews.index(of: stickerView)
            else { return }
        
        
        for i in (index+1)..<subviews.count {
            let view = subviews[i]
            if view is StickerView {
                nextTarget = view as? StickerView
                break
            }
        }
        if nextTarget == nil {
            for i in (0..<index).reversed() {
                let view = subviews[i]
                if view is StickerView {
                    nextTarget = view as? StickerView
                    break
                }
            }
        }
        activeView = nextTarget
        
        UIView.animate(withDuration: 0.3, animations: {
            stickerView.alpha = 0
        }) { _ in
            stickerView.removeFromSuperview()
        }
    }
    
    @objc func rotate(gest: UIRotationGestureRecognizer) {
        let rotation = gest.rotation
        if let viewToTransform = activeView {
            switch (gest.state) {
            case .began:
                viewTransform = viewToTransform.transform
                break;
                
            case .changed:
                viewToTransform.transform = transform.concatenating(CGAffineTransform(rotationAngle: rotation))
                break;
                
            case .ended:
                break;
                
            default:
                break;
            }
            
        }
    }
    
    @objc func drag(gest: UIPanGestureRecognizer) {
        guard let stickerView = activeView else { return }
        layoutIfNeeded()
        
        let translation = gest.translation(in: self)
        switch (gest.state) {
        case .began:
            if let stickerView = findActiveStickerView(location: gest.location(in: self)) {
                activeView = stickerView
                showDeleteButton()
                isDragging = true
                offSet = CGPoint(x: stickerView.horizontalConstraint.constant, y: stickerView.verticalConstraint.constant)
            }
            break;
            
        case .changed:
            if isDragging {
                stickerView.horizontalConstraint.constant = offSet.x + translation.x
                stickerView.verticalConstraint.constant = offSet.y + translation.y
                
                deleteButton.isSelected = stickerView.frame.intersects(deleteButton.frame)
                
                layoutIfNeeded()
            }
            break
            
        case .ended:
            isDragging = false
            hideDeleteButton()
            if stickerView.frame.intersects(deleteButton.frame) {
                deleteSticker(stickerView: stickerView)
            }
            break
            
        default:
            break;
        }
    }
    
    @objc func pinch(gest:UIPinchGestureRecognizer) {
        guard let stickerView = activeView else { return }
        layoutIfNeeded()
        let scale = gest.scale
        switch (gest.state) {
        case .began:
            viewSize = CGSize(width: stickerView.widthConstraint.constant, height: stickerView.heightConstraint.constant)
            break
            
        case .changed:
            stickerView.widthConstraint.constant = viewSize.width * scale
            stickerView.heightConstraint.constant = viewSize.height * scale
            stickerView.layoutIfNeeded()
            layoutIfNeeded()
            break
            
        case .ended:
            break
            
        default:
            break;
        }
        
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        if let view = findActiveStickerView(location: location) {
            activeView = view
        }
    }
    
    func findActiveStickerView(location: CGPoint) -> StickerView? {
        let subviews = self.subviews.sorted { (view1, view2) -> Bool in
            view1.layer.zPosition > view2.layer.zPosition
        }
        
        for view in subviews {
            if view is StickerView {
                if view.frame.contains(location) {
                    return view as? StickerView
                }
            }
        }
        return nil
    }
}

extension StickersLayerView {
    func buildImage(image: UIImage) -> UIImage? {
        var layer: CALayer? = nil
        var scale: CGFloat = 1
        DispatchQueue.main.async {
            layer = self.layer
            scale = image.size.width / self.frame.width
        }
    
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(at: .zero)
        if let context = UIGraphicsGetCurrentContext() {
            context.scaleBy(x: scale, y: scale)
            layer?.render(in: context)
            let tmpImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return tmpImage
        }
        return nil
    }
}

public enum StickerType {
    case sticker
    case emoji
    case text
    case unknown
}

public class StickerInfo {
    public var image: UIImage
    public var text: String? = nil
    public var type: StickerType = .sticker
    public var fontIndex: Int = 0
    public var colorIndex: Int = 0
    public var alignmentIndex: Int = 0
    public var size: CGSize = .zero
    
    public init(image: UIImage, text: String? = nil, type: StickerType = .sticker, fontIndex: Int = 0, colorIndex: Int = 0, alignmentIndex: Int = 0, size: CGSize) {
        self.image = image
        self.text = text
        self.fontIndex = fontIndex
        self.type = type
        self.colorIndex = colorIndex
        self.alignmentIndex = alignmentIndex
        self.size = size
    }
}

public class StickerView: UIView {
    
    var imageView: UIImageView!
    var info: StickerInfo!
    
    var verticalConstraint: NSLayoutConstraint!
    var horizontalConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    
    var offSet: CGPoint!
    var viewTransform: CGAffineTransform!
    var viewSize: CGSize!
    
    public func add(toView view: UIView) {
        view.addSubview(self)
        
        verticalConstraint = autoAlignAxis(.horizontal, toSameAxisOf: view)
        horizontalConstraint = autoAlignAxis(.vertical, toSameAxisOf: view)
    }
    
    public convenience init(stickerInfo: StickerInfo) {
        self.init(image: stickerInfo.image, size: stickerInfo.size)
        self.info = stickerInfo
    }
    
    init(image: UIImage, size: CGSize) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
        
        widthConstraint = autoSetDimension(.width, toSize: size.width)
        heightConstraint = autoSetDimension(.height, toSize: image.size.height/image.size.width * size.width)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

