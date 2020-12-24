//
//  StickerPickerPage.swift
//  Action
//
//  Created by ToanDK on 9/10/19.
//

import Foundation
import RxCocoa
import RxSwift
import DTMvvm

public class StickerPickerPage: Page<StickerPickerViewModel> {
    private var completion: ((UIImage?, CGSize, String) -> Void)? = nil
    
    var indicatorLineOffset: NSLayoutConstraint!
    
    var scrollView: ScrollLayout = {
        let scrollView = ScrollLayout(axis: .horizontal)
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.1)
        return view
    }()
    
    var indicatorLine: UIImageView = {
        let line = UIImageView()
        line.backgroundColor = .white
        line.autoSetDimensions(to: CGSize(width: 32, height: 2))
        return line
    }()
    
    let buttonStack = StackLayout().direction(.horizontal).alignItems(.fill).justifyContent(.fillEqually).spacing(16)
    var stickerButton: UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic_stickers", in: GPImageEditorBundle.getBundle(), compatibleWith: nil), for: .normal)
        button.tintColor = .white
        button.tag = 0
        button.addTarget(self, action: #selector(selectTab), for: .touchUpInside)
        return button
    }
    
    var emojiButton: UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ic_emoji", in: GPImageEditorBundle.getBundle(), compatibleWith: nil), for: .normal)
        button.tintColor = .white
        button.tag = 1
        button.addTarget(self, action: #selector(selectTab), for: .touchUpInside)
        return button
    }
    
    var stickerListView: StickerListView!
    var emojiListView: EmojiListView!
    
    init(viewModel: StickerPickerViewModel? = nil, completion: ((UIImage?, CGSize, String) -> Void)?) {
        super.init(viewModel: viewModel)
        self.completion = completion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectTab(sender: UIButton) {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.width * CGFloat(sender.tag), y: 0), animated: true)
        indicatorLineOffset.constant = sender.tag == 0 ? 4 : 60
    }
    
    override public func initialize() {
        super.initialize()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurEffectView)
        blurEffectView.autoPinEdgesToSuperviewEdges()
        
        view.backgroundColor = .clear
       
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        headerView.autoSetDimension(.height, toSize: 48)
        headerView.addSubview(buttonStack)
        buttonStack.children([stickerButton, emojiButton])
        buttonStack.autoSetDimensions(to: CGSize(width: 96, height: 40))
        buttonStack.autoCenterInSuperview()
        
        headerView.addSubview(indicatorLine)
        indicatorLine.autoPinEdge(.bottom, to: .bottom, of: headerView, withOffset: -6)
        indicatorLineOffset = indicatorLine.autoPinEdge(.left, to: .left, of: buttonStack, withOffset: 4)
        
        view.addSubview(scrollView)
        scrollView.autoPinEdge(.top, to: .bottom, of: headerView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        
        let stickerType = self.viewModel?.stickerGroupType ?? .imageCreator
        stickerListView = StickerListView(viewModel: StickerListViewModel(stickerGroupType: stickerType), completion: { [weak self] (image, size, stickerId) in
            self?.finishedPickImage(image: image, size: size, stickerId: stickerId)
        })
        
        emojiListView = EmojiListView(viewModel: EmojiListViewModel(), completion: { [weak self] (image, size, emoji) in
            self?.finishedPickImage(image: image, size: size, stickerId: emoji)
        })
        
        scrollView.appendChildren([stickerListView, emojiListView])
        
        stickerListView.autoMatch(.width, to: .width, of: scrollView)
        stickerListView.autoMatch(.height, to: .height, of: scrollView)
        emojiListView.autoMatch(.width, to: .width, of: scrollView)
        emojiListView.autoMatch(.height, to: .height, of: scrollView)
        
        scrollView.rx.contentOffset
            .subscribe(onNext: { offset in
                let width = self.scrollView.frame.width
                let index = width > 0 ? Int((offset.x + (0.5 * width)) / width) : 0
                self.indicatorLineOffset.constant = index == 0 ? 4 : 60
            }) => disposeBag
    }
    
    func finishedPickImage(image: UIImage?, size: CGSize, stickerId: String) {
        completion?(image, size, stickerId)
        dismiss(animated: true, completion: { [weak self] in
            self?.destroy()
        })
    }
}

public class StickerPickerViewModel: ViewModel<Model> {
    var stickerGroupType: StickerGroupType = .imageCreator
    
    convenience init(type: StickerGroupType = .imageCreator) {
        self.init(model: nil)
        self.stickerGroupType = type
    }
}

extension StickerPickerPage {
    public static func addSticker(type: StickerGroupType = .imageCreator, toView view: UIView, completion: ((StickerView?) -> Void)?) -> StickerPickerPage {
        let vm = StickerPickerViewModel(type: type)
        return StickerPickerPage(viewModel: vm, completion: { (image, size, stickerId) in
            if let image = image {
                let info = StickerInfo(image: image, type: .sticker, size: size, stickerId: stickerId)
                let stickerView = StickersLayerView.addSticker(stickerInfo: info, toView: view)
                completion?(stickerView)
            }
        })
    }
    
    public static func mixedImage(originalImage: UIImage, view: UIView, fromStory: Bool = false, completion: @escaping ((UIImage?) -> Void)) {
            guard let stickersLayer = view.subviews.first(where: { (subView) -> Bool in
                    subView is StickersLayerView
                }) as? StickersLayerView
                else {
                    completion(nil)
                    return
            }
            let size = view.frame.size
            let layer = stickersLayer.layer
            let scale = originalImage.size.width / stickersLayer.frame.width
            let imgSize = originalImage.size
            let imgScale = originalImage.scale
            let finalCropRect = stickersLayer.getFinalCropRectWith(image: originalImage)
            
            DispatchQueue.global(qos: .background).async {
                let image = stickersLayer.buildImage(image: originalImage, size: size, imgSize: imgSize, imgScale: imgScale, layer: layer, scale: scale, finalCropRect: fromStory ? finalCropRect : nil)
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
}
