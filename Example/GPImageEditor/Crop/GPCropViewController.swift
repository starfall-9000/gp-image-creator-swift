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

class GPCropViewController: Page<GPCropViewModel> {
    let contentView = UIView()
    let imageView = UIImageView()
    let imageMask = GPCropMask()
    let slider = UISlider()
    let leftHiddenSlider = UIView()
    let rightHiddenSlider = UIView()
    var leftSliderConstraint: NSLayoutConstraint? = nil
    var rightSliderConstraint: NSLayoutConstraint? = nil
    var imageMaskRatioWidth: NSLayoutConstraint? = nil
    var imageMaskRatioHeight: NSLayoutConstraint? = nil
    var imageMaskWidthConstraint: NSLayoutConstraint? = nil
    var imageMaskHeightConstraint: NSLayoutConstraint? = nil
    
    let GP_MIN_CROP_SCALE: CGFloat = 1
    let GP_MAX_CROP_SCALE: CGFloat = 5
    let GP_SLIDER_CROP_VALUE: Float = 360
    let GP_SLIDER_COLOR = UIColor(r: 115, g: 115, b: 115)
    let GP_SLIDER_HIGH_LIGHT_COLOR = UIColor(hexString: "#6FBE49")
    
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
        imageView.frame = CGRect(origin: .zero, size: contentView.frame.size)
        viewModel?.rxImageCenter.accept(imageView.center)
    }
    
    override func initialize() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        view.backgroundColor = UIColor.init(hexString: "#000000")
        
        // content view
        view.addSubview(contentView)
        contentView.autoPinEdge(toSuperviewEdge: .top, withInset: 44)
        contentView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        contentView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        
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
        
        // image mask
        contentView.addSubview(imageMask)
        imageMask.autoAlignAxis(toSuperviewAxis: .vertical)
        imageMask.autoAlignAxis(toSuperviewAxis: .horizontal)
        imageMaskRatioWidth = imageMask.autoMatch(.width, to: .width, of: contentView)
        imageMaskRatioHeight = imageMask.autoMatch(.height, to: .height, of: contentView)
        imageMaskWidthConstraint = imageMask.autoSetDimension(.width, toSize: contentView.frame.width)
        imageMaskHeightConstraint = imageMask.autoSetDimension(.height, toSize: contentView.frame.height)
        imageMaskWidthConstraint?.isActive = false
        imageMaskHeightConstraint?.isActive = false
        imageMask.isUserInteractionEnabled = false
        
        // crop tool view
        let cropToolView = UIView()
        view.addSubview(cropToolView)
        cropToolView.autoPinEdgesToSuperviewEdges(with: .all(0), excludingEdge: .top)
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
        
        let closeButton = UIButton.init(type: .custom)
        bottomView.addSubview(closeButton)
        closeButton.setImage(UIImage.init(named: "ic_crop_close.png"), for: .normal)
        closeButton.autoPinEdge(toSuperviewEdge: .left, withInset: 12)
        closeButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        closeButton.autoSetDimensions(to: .init(width: 16, height: 16))
        closeButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.dismissScreen()
        }) => disposeBag
        
        let doneButton = UIButton.init(type: .custom)
        bottomView.addSubview(doneButton)
        doneButton.setImage(UIImage.init(named: "ic_crop_done.png"), for: .normal)
        doneButton.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        doneButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        doneButton.autoSetDimensions(to: .init(width: 24, height: 24))
        doneButton.rx.tap
            .throttle(.milliseconds(3000), scheduler: Scheduler.shared.mainScheduler)
            .subscribe(onNext: { [weak self] in
                guard
                    let self = self,
                    let viewModel = self.viewModel
                else { return }
                let maskFrame = self.imageView.calcMaskInImage(imageMask: self.imageMask,
                                                               imageScale: viewModel.rxImageScale.value)
                viewModel.doneAction.execute(maskFrame)
                self.dismissScreen()
            }) => disposeBag
        
        let titleLabel = UILabel()
        bottomView.addSubview(titleLabel)
        titleLabel.text = "Cắt & Xoay"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.autoCenterInSuperview()
        
        // slider
        let sliderView = UIView()
        cropToolView.addSubview(sliderView)
        sliderView.autoPinEdge(toSuperviewEdge: .left, withInset: 24)
        sliderView.autoPinEdge(toSuperviewEdge: .right, withInset: 24)
        sliderView.autoPinEdge(.bottom, to: .top, of: bottomView, withOffset: -14)
        sliderView.autoSetDimension(.height, toSize: 17)
        
        slider.maximumTrackTintColor = GP_SLIDER_COLOR
        slider.minimumTrackTintColor = GP_SLIDER_COLOR
        slider.setThumbImage(UIImage.init(named: "ic_crop_slider_thumb.png"), for: .normal)
        slider.minimumValue = -GP_SLIDER_CROP_VALUE
        slider.maximumValue = GP_SLIDER_CROP_VALUE
        slider.value = 0
        
        let sliderCenter = UIView()
        sliderCenter.backgroundColor = GP_SLIDER_HIGH_LIGHT_COLOR
        
        leftHiddenSlider.backgroundColor = GP_SLIDER_COLOR
        leftHiddenSlider.isHidden = true
        rightHiddenSlider.backgroundColor = GP_SLIDER_COLOR
        rightHiddenSlider.isHidden = true
        
        sliderView.addSubview(sliderCenter)
        sliderView.addSubview(slider)
        sliderView.addSubview(leftHiddenSlider)
        sliderView.addSubview(rightHiddenSlider)

        slider.autoPinEdgesToSuperviewEdges()
        
        sliderCenter.autoAlignAxis(.horizontal, toSameAxisOf: slider)
        sliderCenter.autoAlignAxis(.vertical, toSameAxisOf: slider)
        sliderCenter.autoSetDimensions(to: .init(width: 3, height: 9))
        
        leftHiddenSlider.autoPinEdge(.left, to: .left, of: slider)
        leftSliderConstraint = leftHiddenSlider.autoPinEdge(.right, to: .left, of: sliderCenter)
        leftHiddenSlider.autoAlignAxis(.horizontal, toSameAxisOf: slider)
        leftHiddenSlider.autoSetDimension(.height, toSize: 2)
        
        rightSliderConstraint = rightHiddenSlider.autoPinEdge(.left, to: .right, of: sliderCenter)
        rightHiddenSlider.autoPinEdge(.right, to: .right, of: slider)
        rightHiddenSlider.autoAlignAxis(.horizontal, toSameAxisOf: slider)
        rightHiddenSlider.autoSetDimension(.height, toSize: 2)
        
        // tool bar
        let toolBar = StackLayout()
        cropToolView.addSubview(toolBar)
        toolBar.autoPinEdge(.top, to: .top, of: cropToolView, withOffset: 16)
        toolBar.autoPinEdge(.bottom, to: .top, of: slider, withOffset: -12)
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
        viewModel.rxSliderValue <~> slider.rx.value => disposeBag
        viewModel.rxSliderValue.subscribe(onNext: { [weak self] (value) in
            guard let self = self else { return }
            self.updateSliderUI(value)
            self.imageView.image = viewModel.model
        }) => disposeBag
    }
    
    func dismissScreen() {
        dismiss(animated: false, completion: nil)
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
    
    @objc func handlePanImage(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            viewModel?.panAction.execute(sender.translation(in: contentView))
            sender.setTranslation(.zero, in: imageView.superview)
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
            case .free:
                updateImageMaskConstraint(usingRatio: false)
                break
            case .ratioOneOne:
                updateImageMaskSize(widthRatio: 1, heightRatio: 1)
                updateImageMaskConstraint(usingRatio: true)
                break
            case .ratioFourThree:
                updateImageMaskSize(widthRatio: 4, heightRatio: 3)
                updateImageMaskConstraint(usingRatio: true)
                break
            case .ratioThreeFour:
                updateImageMaskSize(widthRatio: 3, heightRatio: 4)
                updateImageMaskConstraint(usingRatio: true)
                break
            }
        }
    }
    
    private func updateSliderUI(_ value: Float) {
        updateSliderConstraint(value)
        // update hightlight in slider
        let isNegativeValue = value < 0
        slider.maximumTrackTintColor = isNegativeValue ? GP_SLIDER_HIGH_LIGHT_COLOR : GP_SLIDER_COLOR
        slider.minimumTrackTintColor = isNegativeValue ? GP_SLIDER_COLOR : GP_SLIDER_HIGH_LIGHT_COLOR
        leftHiddenSlider.isHidden = isNegativeValue
        rightHiddenSlider.isHidden = !isNegativeValue
    }
    
    private func updateSliderConstraint(_ value: Float) {
        // set constraint in case of thumb image in safe area,
        // unless hiddenSlider view will cover thumb image
        let safeValue = GP_SLIDER_CROP_VALUE * 5 / 100
        let safeConstraint = CGFloat(6.5 - 6.5 * fabs(value) / safeValue)
        let constraint: CGFloat = (value < safeValue && value > -safeValue) ? safeConstraint : 0
        leftSliderConstraint?.constant = -constraint
        rightSliderConstraint?.constant = constraint
    }
    
    private func updateImageMaskSize(widthRatio: CGFloat, heightRatio: CGFloat) {
        let contentWidth = contentView.frame.width
        let contentHeight = contentView.frame.height
        if contentHeight * widthRatio / heightRatio > contentWidth {
            imageMaskWidthConstraint?.constant = contentWidth
            imageMaskHeightConstraint?.constant = contentWidth * heightRatio / widthRatio
        } else {
            imageMaskWidthConstraint?.constant = contentHeight * widthRatio / heightRatio
            imageMaskHeightConstraint?.constant = contentHeight
        }
    }
    
    private func updateImageMaskConstraint(usingRatio: Bool) {
        imageMaskRatioWidth?.isActive = false
        imageMaskRatioHeight?.isActive = false
        imageMaskWidthConstraint?.isActive = false
        imageMaskHeightConstraint?.isActive = false
        imageMaskWidthConstraint?.isActive = usingRatio
        imageMaskHeightConstraint?.isActive = usingRatio
        imageMaskRatioWidth?.isActive = !usingRatio
        imageMaskRatioHeight?.isActive = !usingRatio
    }
}
