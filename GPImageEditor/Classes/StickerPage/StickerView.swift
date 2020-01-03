//
//  DraggableImageView.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/11/19.
//

import Foundation
import CoreGraphics
import UIKit
import AudioToolbox

public protocol GPStickerPageDelegate: AnyObject {
    func stickerDidStartEditing(stickerView: UIView?)
    func stickerDidEndEditing(stickerView: UIView?)
    func stickerEditingParentView() -> UIView?
    func stickerDidTapStickerView(_ sender: UITapGestureRecognizer)
    func stickerDidPanBackground(_ sender: UIPanGestureRecognizer)
    func stickerDidScaleBackground(_ sender: UIPinchGestureRecognizer)
    func stickerDidRotateBackground(_ sender: UIRotationGestureRecognizer)
}

public class StickersLayerView: UIView {
    public weak var delegate: GPStickerPageDelegate?
    
    var offSet: CGPoint!
    var viewTransform: CGAffineTransform!
    var viewSize: CGSize!
    var isDragging = false
    var isOverlap = false
    var lastRotation: CGFloat = 0
    
    var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(GPImageEditorBundle.imageFromBundle(imageName: "ic_delete"), for: .normal)
        button.setImage(GPImageEditorBundle.imageFromBundle(imageName: "ie_ic_delete_active"), for: .selected)
        return button
    }()
    
    var activeView: StickerView? = nil {
        didSet {
            if let activeView = activeView {
                activeView.superview?.bringSubviewToFront(activeView)
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
        stickerView.layerView = stickersLayer
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
        
        addGestures()
    }
    
    func addDeleteButton() {
        if deleteButton.superview != nil {
            return
        }
        guard let view = delegate?.stickerEditingParentView() else {
            return
        }
        view.insertSubview(deleteButton, belowSubview: self.superview!)
        deleteButton.autoAlignAxis(.vertical, toSameAxisOf: self)
        deleteButton.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 26)
        deleteButton.autoSetDimensions(to: CGSize(width: 48, height: 48))
        deleteButton.isUserInteractionEnabled = false
        deleteButton.isHidden = true
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
        addDeleteButton()
        deleteButton.superview?.bringSubviewToFront(deleteButton)
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
    
    func startEditing() {
        if let delegate = self.delegate {
            delegate.stickerDidStartEditing(stickerView: activeView)
        }
    }
    
    func endEditing() {
        if let delegate = self.delegate {
            delegate.stickerDidEndEditing(stickerView: activeView)
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
        var originalRotation = CGFloat()
        guard let _ = findActiveStickerView(location: gest.location(in: self))
        else {
            delegate?.stickerDidRotateBackground(gest)
            return
        }
        if let viewToTransform = activeView {
            switch (gest.state) {
            case .began:
                gest.rotation = lastRotation
                originalRotation = gest.rotation
                startEditing()
                viewTransform = viewToTransform.transform
                break
                
            case .changed:
                let newRotation = gest.rotation + originalRotation
                viewToTransform.transform = CGAffineTransform(rotationAngle: newRotation)
                break;
                
            case .ended:
                lastRotation = gest.rotation
                endEditing()
                break;
                
            default:
                break;
            }
        }
    }
    
    func shouldDelete(_ touchPoint: CGPoint) -> Bool {
        var deleteButtonFrame = deleteButton.convert(deleteButton.bounds, to: self)
        deleteButtonFrame.origin = CGPoint(x: deleteButtonFrame.origin.x - deleteButtonFrame.width/2, y: deleteButtonFrame.origin.y - deleteButtonFrame.height/2)
        deleteButtonFrame.size = CGSize(width: deleteButtonFrame.size.width*2, height: deleteButtonFrame.size.height*2)
        return deleteButtonFrame.contains(touchPoint)
    }
    
    @objc func drag(gest: UIPanGestureRecognizer) {
        guard let stickerView = activeView else { return }
        layoutIfNeeded()
        
        let translation = gest.translation(in: self)
        let touchPoint = gest.location(in: self)
        switch (gest.state) {
        case .began:
            if let stickerView = findActiveStickerView(location: gest.location(in: self)) {
                startEditing()
                activeView = stickerView
                showDeleteButton()
                isDragging = true
                offSet = CGPoint(x: stickerView.horizontalConstraint.constant, y: stickerView.verticalConstraint.constant)
            } else {
                delegate?.stickerDidPanBackground(gest)
            }
            break;
            
        case .changed:
            if isDragging {
                stickerView.horizontalConstraint.constant = offSet.x + translation.x
                stickerView.verticalConstraint.constant = offSet.y + translation.y
                if deleteButton.isSelected != shouldDelete(touchPoint) && !deleteButton.isSelected {
                    if #available(iOS 10.0, *) {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                }
                deleteButton.isSelected = shouldDelete(touchPoint)
                layoutIfNeeded()
            } else {
                delegate?.stickerDidPanBackground(gest)
            }
            break
            
        case .ended:
            isDragging = false
            hideDeleteButton()
            if shouldDelete(touchPoint) {
                deleteSticker(stickerView: stickerView)
            }
            endEditing()
            break
            
        default:
            break;
        }
    }
    
    @objc func pinch(gest:UIPinchGestureRecognizer) {
        guard let _ = findActiveStickerView(location: gest.location(in: self))
        else {
            delegate?.stickerDidScaleBackground(gest)
            return
        }
        guard let stickerView = activeView else { return }
        layoutIfNeeded()
        let scale = gest.scale
        switch (gest.state) {
        case .began:
            startEditing()
            viewSize = CGSize(width: stickerView.widthConstraint.constant, height: stickerView.heightConstraint.constant)
            stickerView.updateZoomBegan()
            break
            
        case .changed:
            stickerView.widthConstraint.constant = viewSize.width * scale
            stickerView.heightConstraint.constant = viewSize.height * scale
            stickerView.layoutIfNeeded()
            layoutIfNeeded()
            break
            
        case .ended:
            endEditing()
            stickerView.updateZoomEnded(scale: scale)
            break
            
        default:
            break;
        }
        
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        delegate?.stickerDidTapStickerView(sender)
        let location = sender.location(in: self)
        if let view = findActiveStickerView(location: location) {
            activeView = view
            if view.info.type == .text {
                let editor = GPTextEditorTool.show(inView: self.superview!, completion: nil)
                editor?.viewModel?.model = view.info
                deleteSticker(stickerView: view)
            }
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
    func buildImage(image: UIImage, size: CGSize, imgSize: CGSize, imgScale: CGFloat, layer: CALayer?, scale: CGFloat) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(CGSize(width: imgSize.width, height: scale * size.height), false, imgScale)
        let imageDrawPoint = CGPoint(x: 0, y: (scale * size.height - imgSize.height)/2)
        image.draw(at: imageDrawPoint)
        if let context = UIGraphicsGetCurrentContext() {
            context.scaleBy(x: scale, y: scale)
            layer?.render(in: context)
            let tmpImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let maskFrame = CGRect(x: imageDrawPoint.x * imgScale,
                                   y: imageDrawPoint.y * imgScale,
                                   width: imgSize.width * imgScale,
                                   height: imgSize.height * imgScale)
            let cropImage = tmpImage?.cropImage(maskFrame)
            return cropImage
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
    public var stickerId: String = ""
    public var image: UIImage
    public var text: String? = nil
    public var type: StickerType = .sticker
    public var fontIndex: Int = 0
    public var bgColorHidden: Bool = true
    public var colorIndex: Int = 0
    public var alignmentIndex: Int = 0
    public var size: CGSize = .zero
    public var scale: CGFloat = 1
    public var position: CGPoint = .zero
    
    public init(image: UIImage, text: String? = nil, type: StickerType = .sticker, fontIndex: Int = 0, bgColorHidden: Bool = true, colorIndex: Int = 0, alignmentIndex: Int = 0, size: CGSize, stickerId: String = "", scale: CGFloat = 1, position: CGPoint = .zero) {
        self.image = image
        self.text = text
        self.fontIndex = fontIndex
        self.bgColorHidden = bgColorHidden
        self.type = type
        self.colorIndex = colorIndex
        self.alignmentIndex = alignmentIndex
        self.size = size
        self.scale = scale
        self.position = position
    }
}

public class StickerView: UIView {
    public weak var layerView: StickersLayerView?
    var imageView: UIImageView!
    var textView: UITextView!
    var info: StickerInfo!
    
    var verticalConstraint: NSLayoutConstraint!
    var horizontalConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    
    var currentSize: CGFloat = 0
    var currentCornerRadius: CGFloat = 4
    var currentInsets: UIEdgeInsets = .zero
    
    public func add(toView view: UIView) {
        view.addSubview(self)

        verticalConstraint = autoAlignAxis(.horizontal, toSameAxisOf: view)
        horizontalConstraint = autoAlignAxis(.vertical, toSameAxisOf: view)
    }
    
    public convenience init(stickerInfo: StickerInfo) {
        self.init(stickerInfo: stickerInfo, image: stickerInfo.image, size: stickerInfo.size)
    }
    
    init(stickerInfo: StickerInfo, image: UIImage, size: CGSize) {
        super.init(frame: .zero)
        self.info = stickerInfo
        translatesAutoresizingMaskIntoConstraints = false
        
        if info.type == .text {
            setupTextView()
        }
        
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleToFill
        addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
        
        widthConstraint = autoSetDimension(.width, toSize: size.width)
        heightConstraint = autoSetDimension(.height, toSize: image.size.height/image.size.width * size.width)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTextView() {
        textView = UITextView()
        addSubview(textView)
        textView.autoPinEdgesToSuperviewEdges()
        textView.isHidden = true
        textView.isUserInteractionEnabled = false
        
        textView.textAlignment = [NSTextAlignment.left, NSTextAlignment.center, NSTextAlignment.right][info.alignmentIndex]
        let colorSet = GPImageEditorConfigs.colorSet[info.colorIndex]
        if info.bgColorHidden {
            textView.backgroundColor = .clear
            textView.textColor = UIColor.fromHex(colorSet.bgColor)
        }
        else {
            textView.backgroundColor = UIColor.fromHex(colorSet.bgColor)
            textView.textColor = UIColor.fromHex(colorSet.textColor)
        }
        textView.text = info.text
        let fontConfig = GPImageEditorConfigs.fontSet[info.fontIndex]
        textView.font = UIFont(name: fontConfig.font, size: CGFloat(fontConfig.size))
        textView.buildEditorTextView()
    }
    
    func updateZoomBegan() {
        if let textView = self.textView, GPImageEditorConfigs.enableZoomText {
            currentSize = textView.font?.pointSize ?? 0
            currentCornerRadius = textView.layer.cornerRadius
            currentInsets = textView.textContainerInset
            textView.isHidden = true
            imageView.isHidden = false
        }
    }
    
    func updateZoomEnded(scale: CGFloat) {
        if let textView = self.textView, GPImageEditorConfigs.enableZoomText {
            textView.isHidden = false
            imageView.isHidden = true
            currentSize = currentSize * scale
            textView.font = UIFont(name: textView.font?.fontName ?? "", size: currentSize)
            currentCornerRadius = currentCornerRadius * scale
            textView.layer.cornerRadius = currentCornerRadius
            layoutIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.imageView.image = UIImage.imageWithView(view: textView, size: textView.frame.size)
            }
        }
    }
}

