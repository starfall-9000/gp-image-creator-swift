//
//  GPCropViewController.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 9/10/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm
import RxSwift
import RxCocoa
import PureLayout

class GPCropViewController: Page<GPCropViewModel> {
    let contentView = UIView()
    let imageView = UIImageView()
    let imageMask = GPCropMask()
    let sliderView = GPCropSlider()
    let closeButton = UIButton.init(type: .custom)
    let doneButton = UIButton.init(type: .custom)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageMask.changeMaskType(.free)
        imageMask.isHidden = false
        updateImageView(with: .free)
    }
    
    override func initialize() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        view.backgroundColor = UIColor.init(hexString: "#000000")
        
        // content view
        view.addSubview(contentView)
        contentView.autoPinEdge(toSuperviewSafeArea: .top, withInset: 44)
        contentView.autoPinEdge(toSuperviewSafeArea: .left, withInset: 16)
        contentView.autoPinEdge(toSuperviewSafeArea: .right, withInset: 16)
        
        // image
        imageView.image = viewModel?.model
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        imageView.isUserInteractionEnabled = true
        
        // image gesture
        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.addTarget(self, action: #selector(handleDoubleTapImage(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
        
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchImage(_:)))
        imageView.addGestureRecognizer(scaleGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanImage(_:)))
        imageView.addGestureRecognizer(panGesture)
        
        // blur bottom
        let blurView = UIView()
        contentView.addSubview(blurView)
        blurView.backgroundColor = .init(r: 0, g: 0, b: 0, a: 0.5)
        blurView.autoPinEdge(.top, to: .top, of: view)
        blurView.autoPinEdge(.left, to: .left, of: view)
        blurView.autoPinEdge(.right, to: .right, of: view)
        blurView.autoPinEdge(.bottom, to: .bottom, of: view)
        blurView.isUserInteractionEnabled = false
        
        // image mask
        contentView.addSubview(imageMask)
        imageMask.imageView = imageView
        imageMask.displayImageView.image = viewModel?.model
        imageMask.displayContent.autoPinEdge(.top, to: .top, of: contentView)
        imageMask.displayContent.autoPinEdge(.left, to: .left, of: contentView)
        imageMask.displayContent.autoPinEdge(.right, to: .right, of: contentView)
        imageMask.displayContent.autoPinEdge(.bottom, to: .bottom, of: contentView)
        imageMask.isUserInteractionEnabled = false
        imageMask.isHidden = true
        
        // image mask corner
        let corners = GPCropMaskCorner.createAndAddCorner(to: imageMask)
        corners.forEach { [weak self] corner in
            guard let self = self else { return }
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanCorner(_:)))
            corner.addGestureRecognizer(panGesture)
        }
        
        // crop tool view
        let cropToolView = UIView()
        view.addSubview(cropToolView)
        cropToolView.autoPinEdgesToSuperviewSafeArea(with: .all(0), excludingEdge: .top)
        cropToolView.autoPinEdge(.top, to: .bottom, of: contentView, withOffset: 16)
        cropToolView.backgroundColor = .init(r: 0, g: 0, b: 0, a: 0.8)
        
        // bottom bar
        let bottomView = UIView()
        cropToolView.addSubview(bottomView)
        bottomView.backgroundColor = .clear
        bottomView.autoPinEdgesToSuperviewEdges(with: .all(0), excludingEdge: .top)
        bottomView.autoSetDimension(.height, toSize: 48)
        
        let divider = UIView()
        bottomView.addSubview(divider)
        divider.backgroundColor = UIColor.init(r: 231, g: 231, b: 231, a: 0.2)
        divider.autoPinEdgesToSuperviewEdges(with: .all(0), excludingEdge: .bottom)
        divider.autoSetDimension(.height, toSize: 0.5)
        
        bottomView.addSubview(closeButton)
        closeButton.setImage(UIImage.init(named: "ic_crop_close.png"), for: .normal)
        closeButton.autoPinEdge(toSuperviewEdge: .left, withInset: 12)
        closeButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        closeButton.autoSetDimensions(to: .init(width: 16, height: 16))
        
        bottomView.addSubview(doneButton)
        doneButton.setImage(UIImage.init(named: "ic_crop_done.png"), for: .normal)
        doneButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        doneButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        doneButton.autoSetDimensions(to: .init(width: 24, height: 24))
        
        let titleLabel = UILabel()
        bottomView.addSubview(titleLabel)
        titleLabel.text = "Cắt & Xoay"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.autoCenterInSuperview()
        
        // slider
        cropToolView.addSubview(sliderView)
        sliderView.autoPinEdge(toSuperviewEdge: .left, withInset: 24)
        sliderView.autoPinEdge(toSuperviewEdge: .right, withInset: 24)
        sliderView.autoPinEdge(.bottom, to: .top, of: bottomView, withOffset: -14)
        sliderView.autoSetDimension(.height, toSize: 17)
        
        // tool bar
        let toolBar = StackLayout()
        cropToolView.addSubview(toolBar)
        toolBar.autoPinEdge(.top, to: .top, of: cropToolView, withOffset: 16)
        toolBar.autoPinEdge(.bottom, to: .top, of: sliderView, withOffset: -12)
        toolBar.autoAlignAxis(toSuperviewAxis: .vertical)
        toolBar.autoSetDimension(.height, toSize: 52)
        let toolBarItems = GPCropItem.gapo.all
        toolBarItems.forEach({
            let tapCropItem = UITapGestureRecognizer(target: self, action: #selector(selectCropItem(_:)))
            $0.addGestureRecognizer(tapCropItem)
        })
        toolBar.children(toolBarItems).justifyContent(.fillEqually).spacing(20)
    }
    
    override func bindViewAndViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.rxImageTransform ~> imageView.rx.transform => disposeBag
        viewModel.rxImageCenter ~> imageView.rx.center => disposeBag
        viewModel.rxImageTransform ~> imageMask.displayImageView.rx.transform => disposeBag
        viewModel.rxImageCenter ~> imageMask.displayImageView.rx.center => disposeBag
        viewModel.rxSliderValue <~> sliderView.slider.rx.value => disposeBag
        
        viewModel.rxImageRotateAngle.subscribe(onNext: { (rotateAngle) in
            guard let viewModel = self.viewModel,
                let image = viewModel.model,
                rotateAngle != 0 else { return }

            let a = self.imageMask.height * abs(sin(rotateAngle))
            let b = self.imageMask.width * abs(cos(rotateAngle))
            let c = self.imageMask.width * abs(sin(rotateAngle))
            let d = self.imageMask.height * abs(cos(rotateAngle))
            
            let scaleX = (a + b) / self.imageMask.width
            let scaleY = (c + d) / self.imageMask.height
            var scale = max(scaleX, scaleY)
            if image.size.isLandscape() != self.imageMask.frame.size.isLandscape() {
                scale = min(scaleX, scaleY)
            }
            
            viewModel.rxImageScale.accept(scale)
        }) => disposeBag
        
        viewModel.rxSliderValue.subscribe(onNext: { [weak self] (value) in
            guard let self = self else { return }
            self.sliderView.updateSliderUI(value)
        }) => disposeBag
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.dismissScreen()
        }) => disposeBag
        doneButton.rx.tap
            .throttle(.milliseconds(3000), scheduler: Scheduler.shared.mainScheduler)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.handleClickDone()
            }) => disposeBag
    }
    
    private func dismissScreen() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 0
        }) { (finished) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func handleClickDone() {
        guard let viewModel = viewModel else { return }
        let maskFrame = imageView.calcMaskInImage(imageMask: imageMask,
                                                  imageScale: viewModel.rxImageScale.value)
        viewModel.doneAction.execute(maskFrame)
        dismissScreen()
    }
    
    @objc func handleDoubleTapImage(_ sender: UITapGestureRecognizer) {
        viewModel?.doubleTapAction.execute(sender.location(in: imageView))
    }
    
    @objc func handlePinchImage(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            viewModel?.zoomAction.execute(sender.scale)
            sender.scale = 1
        }
    }
    
    func fixIamgeFrame() {
        var imageFrame = imageView.frame
        if imageView.left > imageMask.left {
            imageFrame.origin.x = imageMask.left
        }
        if imageView.top > imageMask.top {
            imageFrame.origin.y = imageMask.top
        }
        if imageView.bottom < imageMask.bottom {
            imageFrame.origin.y = imageMask.bottom - imageView.height
        }
        if imageView.right < imageMask.right {
            imageFrame.origin.x = imageMask.right - imageView.width
        }
        let center = CGPoint(x: imageFrame.midX, y: imageFrame.midY)
        UIView.animate(withDuration: 0.25) {
            self.viewModel?.rxImageCenter.accept(center)
        }
    }
    
    @objc func handlePanImage(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            viewModel?.panAction.execute(sender.translation(in: contentView))
            sender.setTranslation(.zero, in: imageView.superview)
        }
        if sender.state == .ended {
            fixIamgeFrame()
        }
    }
    
    @objc func handlePanCorner(_ sender: UIPanGestureRecognizer) {
        guard
            let corner = sender.view,
            let cornerType = GPCropCorner(rawValue: corner.tag)
            else { return }
        if (sender.state == .began || sender.state == .changed) {
            imageMask.dragMaskCorner(cornerType, translation: sender.translation(in: contentView))
            sender.setTranslation(.zero, in: corner.superview)
        }
    }
    
    @objc func selectCropItem(_ sender: UITapGestureRecognizer) {
        let cropItem = sender.view as! GPCropItem
        if let cropType = cropItem.type {
            switch cropType {
            case .flip:
                let isFlipped = viewModel?.rxIsFlippedImage.value ?? false
                viewModel?.rxIsFlippedImage.accept(!isFlipped)
                break
            case .free, .ratioOneOne, .ratioFourThree, .ratioThreeFour:
                viewModel?.resetImageTransform()
                imageMask.changeMaskType(cropType)
                updateImageView(with: cropType)
                break
            }
        }
    }
    
    private func updateImageView(with type: GPCropType) {
        imageView.frame =  imageView.calcRectCoverMask(imageMask: imageMask)
        imageMask.displayImageView.frame = imageView.frame
        let center = CGPoint(x: 0.5 * contentView.width, y: 0.5 * contentView.height)
        viewModel?.rxImageCenter.accept(center)
    }
}

extension GPCropViewController {
    
    public static func presentCropEditor(from viewController: UIViewController, image: UIImage, animated: Bool, finished: @escaping ((UIImage) -> Void), completion: (() -> Void)? = nil) {
        let vm = GPCropViewModel(model: image)
        vm.finishedBlock = finished
        let vc = GPCropViewController(viewModel: vm)
        viewController.present(vc, animated: animated) {
            vc.view.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                vc.view.alpha = 1
            }, completion: { (finished) in
                if finished {
                    completion?()
                }
            })
        }
    }
}

extension CGSize {
    
    func isLandscape() -> Bool {
        return width >= height
    }
}
