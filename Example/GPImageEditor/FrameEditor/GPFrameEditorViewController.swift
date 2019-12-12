//
//  GPFrameEditorViewController.swift
//  GPImageEditor_Example
//
//  Created by An Binh on 12/11/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DTMvvm
import GPImageEditor

public class GPFrameEditorViewController: BasePage {
    var viewModel: GPFrameEditorViewModel? = nil
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var frameImageView: UIImageView!
    @IBOutlet weak var frameWidth: NSLayoutConstraint!
    @IBOutlet weak var frameHeight: NSLayoutConstraint!
    
    override public func initialize() {
        super.initialize()
        viewModel?.react()
        addGesture()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.rxImageCenter.accept(frameImageView.center)
    }
    
    override public func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let viewModel = viewModel else { return }
        viewModel.rxImageCenter.accept(frameImageView.center)
        viewModel.rxImage ~> imageView.rx.image => disposeBag
        viewModel.rxImageTransform ~> imageView.rx.transform => disposeBag
        viewModel.rxImageCenter ~> imageView.rx.center => disposeBag
    }
    
    func addGesture() {
        let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchImage(_:)))
        imageView.addGestureRecognizer(scaleGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanImage(_:)))
        imageView.addGestureRecognizer(panGesture)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 0
        }) { (finished) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func applyAction(_ sender: UIButton) {
        guard let image = GPImageEditorBundle.imageFromBundle(imageName: "Frame 1")
        else { return }
        let imageViewSize = image.calcImageSize(toFitSize: imageView.frame.size)
        frameWidth.constant = imageViewSize.width
        frameHeight.constant = imageViewSize.height
        frameImageView.image = image
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
        if sender.state == .ended {
            //
        }
    }
}

extension GPFrameEditorViewController {
    
    public static func presentFrameEditor(from viewController: UIViewController, image: UIImage, animated: Bool, finished: @escaping ((UIImage) -> Void), completion: (() -> Void)? = nil) {
        let vm = GPFrameEditorViewModel(model: image)
        vm.finishedBlock = finished
        let vc = GPFrameEditorViewController.init(nibName: "GPFrameEditorViewController", bundle: nil)
        vc.viewModel = vm
        vc.modalPresentationStyle = .fullScreen
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
