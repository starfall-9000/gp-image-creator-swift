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

class GPFrameEditorViewController: BasePage {
    var viewModel: GPFrameEditorViewModel? = nil
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var frameImageView: UIImageView!
    
    override func initialize() {
        super.initialize()
        viewModel?.react()
    }
    
    override func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let viewModel = viewModel else { return }
        viewModel.rxImage ~> imageView.rx.image => disposeBag
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 0
        }) { (finished) in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func applyAction(_ sender: UIButton) {
        let image = GPImageEditorBundle.imageFromBundle(imageName: "Frame 1")
        frameImageView.image = image
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
