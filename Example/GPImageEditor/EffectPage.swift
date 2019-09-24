//
//  EffectPage.swift
//  GPImageEditor
//
//  Created by Ngoc Thang on 9/12/19.
//

import UIKit
import FittedSheets

public class EffectPage: UIViewController, UICollectionViewDelegateFlowLayout {
    var doneBlock: ((UIImage) -> Void)?
    let cellSize = CGSize(width: 70, height: 130)
    let cellName = "EffectCell"
    
    @IBOutlet weak var sourceImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomMenuView: UIView!
    @IBOutlet weak var bottomGradient: UIImageView!
    @IBOutlet weak var showEffectButton: UIButton!
    @IBOutlet var gradientTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var stickerLayer: UIView!
    @IBOutlet var topViews: [UIView]!
    @IBOutlet var bottomViews: [UIView]!
    @IBOutlet weak var stickerLayerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stickerLayerBottomConstraint: NSLayoutConstraint!
    
    private var isShowingEffectsView: Bool = true
    var viewModel: EffectPageViewModel?
    var isDidAppear: Bool = false
    
    public static func create(with viewModel: EffectPageViewModel?) -> EffectPage {
        let bundle = Bundle(for: EffectPage.self)
        let vc = EffectPage(nibName: "EffectPage", bundle: bundle)
        vc.viewModel = viewModel
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = viewModel?.sourceImage
        sourceImageView.image = viewModel?.sourceImage
        doneButton.cornerRadius = 18
        setupCollectionView()
        addLongPressGesture()
        collectionView.isHidden = true
        bottomGradient.isHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isDidAppear {
            self.bottomGradient.top = self.bottomMenuView.top
            self.collectionView.top = self.view.height
            showEffectTool()
            isDidAppear = true
        }
    }
    
    private func addLongPressGesture() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longGesturePressed))
        longPressRecognizer.minimumPressDuration = 0.75
        stickerLayer.addGestureRecognizer(longPressRecognizer)
    }
    
    @IBAction func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hideShowEffectsTapped() {
        isShowingEffectsView = !isShowingEffectsView
        if isShowingEffectsView {
            showEffectTool()
        } else {
            hideEffectTool()
        }
    }
    
    @objc func longGesturePressed(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            imageView.isHidden = false
            sourceImageView.isHidden = true
        } else {
            imageView.isHidden = true
            sourceImageView.isHidden = false
        }
    }
    
    private func showEffectTool() {
        collectionView.isHidden = false
        bottomGradient.isHidden = false
        UIView.animate(withDuration: 0.25) {
            self.collectionView.bottom = self.bottomMenuView.top
            self.bottomGradient.top = self.collectionView.top
            let imageName = "arrow-down-icon.png"
            let bundle = Bundle(for: EffectPage.self)
            self.showEffectButton.setImage(UIImage(named: imageName, in: bundle, compatibleWith: nil), for: .normal)
        }
    }
    
    private func hideEffectTool() {
        UIView.animate(withDuration: 0.25) {
            self.bottomGradient.top = self.bottomMenuView.top
            self.collectionView.top = self.view.height
            let imageName = "arrow-top-icon.png"
            let bundle = Bundle(for: EffectPage.self)
            self.showEffectButton.setImage(UIImage(named: imageName, in: bundle, compatibleWith: nil), for: .normal)
        }
    }
    
    private func setupCollectionView() {
        let bundle = Bundle(for: EffectPage.self)
        let nib = UINib(nibName: cellName, bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: cellName)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @IBAction func stickerTapped() {
        let stickerVC = StickerPickerPage.addSticker(toView: stickerLayer, completion: { [weak self] (sticker) in
            sticker?.layerView?.delegate = self
        })
        let sheetController = SheetViewController(controller: stickerVC, sizes: [SheetSize.fullScreen])
        sheetController.topCornersRadius = 16
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false
        
        self.present(sheetController, animated: false, completion: nil)
    }
    
    @IBAction func textTapped() {
        GPTextEditorTool.show(inView: stickerLayer) { [weak self] (text) in
            text?.layerView?.delegate = self
        }
    }
    
    @IBAction func drawTapped() {
    
    }
    
    @IBAction func otherEditTapped() {
        guard let image = imageView.image else { return }
        let vm = GPCropViewModel(model: image)
        let vc = GPCropViewController(viewModel: vm)
        present(vc, animated: false, completion: nil)
    }
    
    @IBAction func doneTapped() {
        guard let image = imageView.image else {
            self.doneBlock?(viewModel!.sourceImage)
            return;
        }
        StickerPickerPage.mixedImage(originalImage: image, view: stickerLayer) { [weak self] (mixedImage) in
            if let mixed = mixedImage {
                self?.doneBlock?(mixed)
            } else {
                self?.doneBlock?(image)
            }
            self?.dismiss(animated: true, completion: nil)
        }
    }

    open func collectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

extension EffectPage: GPStickerPageDelegate {
    func hideBarViews() {
        UIView.animate(withDuration: 0.2, animations: {
            for view in self.topViews {
                view.alpha = 0
            }
            for view in self.bottomViews {
                view.alpha = 0
            }
        }) { (finished) in
            for view in self.topViews {
                view.isHidden = true
            }
            for view in self.bottomViews {
                view.isHidden = true
            }
        }
    }
    
    func showBarViews() {
        for view in self.topViews {
            view.isHidden = false
        }
        for view in self.bottomViews {
            view.isHidden = false
        }
        self.bottomMenuView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            for view in self.topViews {
                view.alpha = 1
            }
            for view in self.bottomViews {
                view.alpha = 1
            }
        }
    }
    
    public func stickerDidStartEditing(stickerView: UIView?) {
        hideBarViews()
    }
    
    public func stickerDidEndEditing(stickerView: UIView?) {
        showBarViews()
    }
    
    public func stickerEditingParentView() -> UIView? {
        return view
    }
}

extension EffectPage: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! EffectCell
        cell.bind(model: viewModel?.items[indexPath.row], viewModel: viewModel)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let filter = viewModel?.items[indexPath.row] else { return }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        viewModel?.rxSelectedFilter.accept(filter)
        guard let sourceImage = viewModel?.sourceImage else { return }
        imageView.image = filter.applyFilter(image: sourceImage)
    }
}
