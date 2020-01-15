//
//  EffectPage.swift
//  GPImageEditor
//
//  Created by Ngoc Thang on 9/12/19.
//

import UIKit
import FittedSheets
import DTMvvm
import RxSwift

public class EffectPage: UIViewController, UICollectionViewDelegateFlowLayout {
    var doneBlock: ((UIImage) -> Void)?
    var didDismissScreen: ((Bool) -> Void)? = nil
    var handlePrivacyAction: (() -> Void)? = nil
    let cellSize = CGSize(width: 70, height: 130)
    let cellName = "EffectCell"
    var tutorialView: GPTutorialView? = nil
    var disposeBag: DisposeBag? = nil
    var fromStory: Bool = false
    public var validInternet: (() -> Bool)? = nil
    
    @IBOutlet weak var sourceImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var frameBlurView: UIView!
    @IBOutlet weak var frameImageView: UIImageView!
    @IBOutlet weak var frameWidth: NSLayoutConstraint!
    @IBOutlet weak var frameHeight: NSLayoutConstraint!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var topEffectButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var bottomGradient: UIImageView!
    @IBOutlet weak var showEffectButton: UIButton!
    @IBOutlet var gradientTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stickerLayer: UIView!
    @IBOutlet var topViews: [UIView]!
    @IBOutlet var bottomViews: [UIView]!
    @IBOutlet weak var bottomMenuHeightConstraint: NSLayoutConstraint!
    var tutorialTopConstraint: NSLayoutConstraint? = nil
    
    private var isShowingEffectsView: Bool = true
    var viewModel: EffectPageViewModel?
    var isDidAppear: Bool = false
    
    public static func create(with viewModel: EffectPageViewModel?) -> EffectPage {
        let vc = EffectPage(nibName: "EffectPage", bundle: GPImageEditorBundle.getBundle())
        vc.viewModel = viewModel
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        disposeBag = DisposeBag()
        let bottomHeight = viewModel?.kBottomMenuHeight ?? 60
        bottomMenuHeightConstraint.constant = bottomHeight + 8
        imageView.image = viewModel?.sourceImage
        sourceImageView.image = viewModel?.sourceImage
        doneButton.cornerRadius = 18
        setupStoryView()
        setupCollectionView()
        setupTutorial()
        addGestures()
        collectionView.isHidden = true
        bottomGradient.isHidden = true
        bindViewAndViewModel()
        viewModel?.react()
    }
    
    func setupStoryView() {
        let doneText = fromStory ? "Đăng" : "Xong"
        doneButton.setTitle(doneText, for: .normal)
        showEffectButton.isHidden = fromStory
        privacyView.isHidden = !fromStory
        topEffectButton.isHidden = !fromStory
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isDidAppear {
            self.bottomGradient.top = self.bottomMenuView.top
            self.collectionView.top = self.view.height
            if fromStory {
                hideEffectTool()
            } else {
                showEffectTool()
            }
            isDidAppear = true
            viewModel?.rxImageCenter.accept(frameImageView.center)
            viewModel?.recordEditorShown()
        }
    }
    
    func bindViewAndViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.rxImageCenter.accept(frameImageView.center)
        viewModel.rxImageTransform ~> imageView.rx.transform => disposeBag
        viewModel.rxImageCenter ~> imageView.rx.center => disposeBag
        viewModel.rxSelectedFilter.map({ return !($0?.allowGesture ?? true) })
            ~> frameImageView.rx.isHidden => disposeBag
        viewModel.rxSelectedFilter.map({ return !($0?.allowGesture ?? true) })
            ~> frameBlurView.rx.isHidden => disposeBag
        viewModel.rxSelectedFilter
            .map({ return $0?.defaultForegroundSize })
            .subscribe(onNext: { [weak self] size in
                guard let self = self else { return }
                let imageSize = viewModel.maxImageSizeForEditing()
                self.imageWidth.constant = size?.width ?? imageSize.width
                self.imageHeight.constant = size?.height ?? imageSize.height
            }) => disposeBag
        viewModel.rxListItem
            .observeOn(Scheduler.shared.mainScheduler)
            .subscribe(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            }) => disposeBag
    }
    
    private func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapGesture(gesture:)))
        stickerLayer.addGestureRecognizer(tapGesture)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longGesturePressed))
        longPressRecognizer.minimumPressDuration = 0.75
        stickerLayer.addGestureRecognizer(longPressRecognizer)
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchImage(_:)))
        stickerLayer.addGestureRecognizer(scaleGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanImage(_:)))
        stickerLayer.addGestureRecognizer(panGesture)
    }
    
    @IBAction func backAction() {
        UIAlertController
            .showAlertController(in: self,
                                 title: "Thông báo",
                                 message: "Bạn sẽ mất mọi thay đổi đã thực hiện cho ảnh này.",
                                 cancelButtonTitle: "Hủy",
                                 otherButtonTitles: ["Tiếp tục chỉnh sửa"]) { [weak self] (alert, index) in
                                    guard let self = self else { return }
                                    if index == 0 {
                                        self.viewModel?.recordEditorCancel()
                                        self.dismiss(animated: true, completion: { [weak self] in
                                            guard let self = self else { return }
                                            self.didDismissScreen?(false)
                                        })
                                    }
        }
    }
    
    @IBAction func hideShowEffectsTapped() {
        isShowingEffectsView = !isShowingEffectsView
        if isShowingEffectsView {
            showEffectTool()
        } else {
            hideEffectTool()
        }
    }
    
    @IBAction func privacyAction() {
        handlePrivacyAction?()
    }
    
    @objc func viewTapGesture(gesture: UITapGestureRecognizer) {
        textTapped()
    }
    
    @objc func longGesturePressed(gesture: UILongPressGestureRecognizer) {
        if (viewModel?.rxSelectedFilter.value?.allowGesture ?? false) {
            // not enable this feature with image frame has gesture
            return
        }
        if gesture.state == .ended {
            imageView.isHidden = false
            sourceImageView.isHidden = true
        } else {
            imageView.isHidden = true
            sourceImageView.isHidden = false
        }
    }
    
    @objc func handlePinchImage(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            viewModel?.handleZoom(sender.scale)
            sender.scale = 1
        }
    }
    
    @objc func handlePanImage(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            viewModel?.handlePan(sender.translation(in: sender.view?.superview))
            sender.setTranslation(.zero, in: sender.view?.superview)
        }
    }
    
    private func showEffectTool() {
        collectionView.isHidden = false
        bottomGradient.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.collectionView.bottom = self.bottomMenuView.top
            self.bottomGradient.top = self.collectionView.top
            let imageName = "arrow-down-icon.png"
            let bundle = GPImageEditorBundle.getBundle()
            self.showEffectButton.setImage(UIImage(named: imageName, in: bundle, compatibleWith: nil), for: .normal)
            self.topEffectButton.setImage(UIImage(named: "ic_editor_effect_active", in: bundle, compatibleWith: nil), for: .normal)
        }
    }
    
    private func hideEffectTool() {
        UIView.animate(withDuration: 0.25) {
            self.bottomGradient.top = self.bottomMenuView.top
            self.collectionView.top = self.view.height
            let imageName = "arrow-top-icon.png"
            let bundle = GPImageEditorBundle.getBundle()
            self.showEffectButton.setImage(UIImage(named: imageName, in: bundle, compatibleWith: nil), for: .normal)
            self.topEffectButton.setImage(UIImage(named: "ic_editor_effect", in: bundle, compatibleWith: nil), for: .normal)
        }
    }
    
    private func setupCollectionView() {
        let bundle = GPImageEditorBundle.getBundle()
        let nib = UINib(nibName: cellName, bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: cellName)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupTutorial() {
        guard let viewModel = viewModel else { return }
        viewModel.rxHideTutorial
            .observeOn(Scheduler.shared.mainScheduler)
            .subscribe(onNext: { [weak self] isHidden in
                self?.tutorialView?.isHidden = isHidden
            }) => disposeBag
        viewModel.rxHideTutorial.accept(true)
    }
    
    private func handleAddNewSticker(_ stickerView: StickerView,
                                     tutorial: GPTutorialType) {
        guard let viewModel = self.viewModel else { return }
        stickerView.layerView?.delegate = self
        let shouldShowTutorial = GPTutorialView.shouldShowTutorial(tutorial)
        if (shouldShowTutorial) {
            self.tutorialView?.removeFromSuperview()
            let tutorialView = GPTutorialView.tutorialWithType(tutorial)
            stickerLayer.addSubview(tutorialView)
            tutorialView.isUserInteractionEnabled = false
            tutorialView.autoAlignAxis(toSuperviewAxis: .vertical)
            tutorialTopConstraint?.autoRemove()
            let offset: CGFloat = tutorial == .GPStickerTutorial ? 10 : -10
            tutorialTopConstraint = tutorialView.autoPinEdge(.top, to: .bottom, of: stickerView.imageView, withOffset: offset)
            self.tutorialView = tutorialView
            viewModel.rxHideTutorial.accept(false)
        }
    }
    
    @IBAction func stickerTapped() {
        let stickerVC = StickerPickerPage.addSticker(toView: stickerLayer,
                                                     completion: { [weak self] (sticker) in
            guard let self = self, let sticker = sticker else { return }
            self.viewModel?.stickerInfos.append(sticker.info)
            self.handleAddNewSticker(sticker, tutorial: .GPStickerTutorial)
        })
        let sheetController = SheetViewController(controller: stickerVC, sizes: [SheetSize.fullScreen])
        sheetController.topCornersRadius = 16
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false
        
        self.present(sheetController, animated: false, completion: nil)
    }
    
    @IBAction func textTapped() {
        GPTextEditorTool.show(inView: stickerLayer) { [weak self] (text) in
            guard let self = self, let text = text else { return }
            self.viewModel?.stickerInfos.append(text.info)
            self.handleAddNewSticker(text, tutorial: .GPTextEditTutorial)
        }
    }
    
    @IBAction func drawTapped() {
    
    }
    
    @IBAction func cropTapped() {
        guard let image = imageView.image else { return }
        
        GPImageEditor.presentEditPage(from: self, image: image, animated: true, finished: { [weak self] (image) in
            self?.viewModel?.sourceImage = image
            self?.viewModel?.thumbImage = image.thumbImage()
            self?.imageView.image = image
            self?.sourceImageView.image = image
            self?.collectionView.reloadData()
        })
    }
    
    @IBAction func doneTapped() {
        guard let viewModel = viewModel else { return }
        if let validInternet = validInternet {
            let isReachable = validInternet()
            if (!isReachable) { return }
        }
        if (viewModel.rxSelectedFilter.value?.allowGesture ?? false) {
            let filterFrame
                = imageView.calcMaskInImage(imageMask: frameImageView,
                                            imageScale: viewModel.rxImageScale.value)
            imageView.image = viewModel.handleMergeGestureFrame(filterFrame: filterFrame)
            viewModel.resetImageTransform()
            viewModel.rxImageCenter.accept(frameImageView.center)
        }
        guard let image = imageView.image else {
            self.doneBlock?(viewModel.sourceImage)
            return
        }
        StickerPickerPage.mixedImage(originalImage: image, view: stickerLayer) { [weak self] (mixedImage) in
            guard let self = self else { return }
            if let mixed = mixedImage {
                self.doneBlock?(mixed)
            } else {
                self.doneBlock?(image)
            }
            self.viewModel?.recordEditorFinished()
            self.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                self.didDismissScreen?(true)
            })
        }
    }

    open func collectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    deinit {
        disposeBag = nil
    }
}

extension EffectPage: GPStickerPageDelegate {
    func hideBarViews() {
        UIView.animate(withDuration: 0.2, animations: {
            for view in self.topViews {
                view.alpha = 0
            }
            self.topEffectButton.alpha = 0
            for view in self.bottomViews {
                view.alpha = 0
            }
        }) { (finished) in
            for view in self.topViews {
                view.isHidden = true
            }
            self.topEffectButton.isHidden = true
            for view in self.bottomViews {
                view.isHidden = true
            }
        }
    }
    
    func showBarViews() {
        for view in self.topViews {
            view.isHidden = false
        }
        topEffectButton.isHidden = !fromStory
        for view in self.bottomViews {
            view.isHidden = false
        }
        self.bottomMenuView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            for view in self.topViews {
                view.alpha = 1
            }
            self.topEffectButton.alpha = 1
            for view in self.bottomViews {
                view.alpha = 1
            }
        }
    }
    
    public func stickerDidStartEditing(stickerView: UIView?) {
        hideBarViews()
        viewModel?.rxHideTutorial.accept(true)
    }
    
    public func stickerDidEndEditing(stickerView: UIView?) {
        showBarViews()
    }
    
    public func stickerEditingParentView() -> UIView? {
        return view
    }
    
    public func stickerDidTapStickerView(_ sender: UITapGestureRecognizer) {
        viewModel?.rxHideTutorial.accept(true)
    }
    
    public func stickerDidPanBackground(_ sender: UIPanGestureRecognizer) {
        handlePanImage(sender)
    }
    
    public func stickerDidScaleBackground(_ sender: UIPinchGestureRecognizer) {
        handlePinchImage(sender)
    }
    
    public func stickerDidRotateBackground(_ sender: UIRotationGestureRecognizer) {
        //
    }
}

extension EffectPage: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let listItem = viewModel?.rxListItem.value else { return 0 }
        return listItem.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! EffectCell
        cell.bind(model: viewModel?.getImageFilter(indexPath.row), viewModel: viewModel)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let filter = viewModel?.getImageFilter(indexPath.row) else { return }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        viewModel?.rxSelectedFilter.accept(filter)
        viewModel?.rxImageCenter.accept(stickerLayer.center)
        viewModel?.resetImageTransform()
        if filter.allowGesture {
            didSelectGestureFilter(filter: filter)
        } else {
            didSelectNormalFilter(filter: filter)
        }
    }
    
    public func didSelectNormalFilter(filter: GPImageFilter) {
        guard let sourceImage = viewModel?.sourceImage else { return }
        imageView.image = filter.applyFilter(image: sourceImage)
    }
    
    public func didSelectGestureFilter(filter: GPImageFilter) {
        imageView.image = viewModel?.sourceImage
        filter.frameImageObserve()
            .observeOn(Scheduler.shared.mainScheduler)
            .subscribe(onNext: { [weak self] frameImage in
                guard let self = self else { return }
                if let imageViewSize = frameImage?
                    .calcImageSize(toFitSize: self.stickerLayer.frame.size) {
                    self.frameWidth.constant = imageViewSize.width
                    self.frameHeight.constant = imageViewSize.height
                    self.frameImageView.image = frameImage
                }
            }) => disposeBag
    }
}
