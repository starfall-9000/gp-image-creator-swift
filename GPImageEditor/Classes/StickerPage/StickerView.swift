//
//  DraggableImageView.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/11/19.
//

import Foundation
import CoreGraphics

private let kStickerWidth: CGFloat = 100

public class StickersLayerView: UIView {
    
    var offSet: CGPoint!
    var viewTransform: CGAffineTransform!
    var viewSize: CGSize!
    
    var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic_delete", in: GPImageEditorBundle.getBundle(), compatibleWith: nil), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    var activeView: StickerView? = nil {
        didSet {
            if let activeView = activeView {
                activeView.superview?.bringSubview(toFront: activeView)
            }
        }
    }
    
    public static func addSticker(image: UIImage, toView: UIView) -> StickerView {
        let stickerView = StickerView(image: image)
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
            showDeleteButton()
            offSet = CGPoint(x: stickerView.horizontalConstraint.constant, y: stickerView.verticalConstraint.constant)
            break;
            
        case .changed:
            stickerView.horizontalConstraint.constant = offSet.x + translation.x
            stickerView.verticalConstraint.constant = offSet.y + translation.y
            
            deleteButton.tintColor = stickerView.frame.intersects(deleteButton.frame) ? .black : .white
            
            layoutIfNeeded()
            break
            
        case .ended:
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
        let subviews = self.subviews.sorted { (view1, view2) -> Bool in
            view1.layer.zPosition > view2.layer.zPosition
        }
        let location = sender.location(in: self)
        for view in subviews {
            if view is StickerView {
                if view.frame.contains(location) {
                    activeView = view as? StickerView
                    return
                }
            }
        }
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

public class StickerView: UIView {
    var imageView: UIImageView!
    
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
    
    public init(image: UIImage) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
        
        widthConstraint = autoSetDimension(.width, toSize: kStickerWidth)
        heightConstraint = autoSetDimension(.height, toSize: image.size.height/image.size.width * kStickerWidth)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

