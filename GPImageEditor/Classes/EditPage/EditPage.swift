//
//  EditPage.swift
//  GPImageEditor_Example
//
//  Created by Ngoc Thang on 10/7/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import DTMvvm
import RxCocoa

public class EditPage: UIViewController {

    var doneBlock: ((UIImage) -> Void)?
    
    @IBOutlet weak var brightnessSlider: EditPageSlider!
    @IBOutlet weak var contrastSlider: EditPageSlider!
    @IBOutlet weak var saturationSlider: EditPageSlider!
    @IBOutlet weak var tempSlider: EditPageSlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var smallTitleLabels: [UILabel]!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var sliders: [EditPageSlider]!
    
    var viewModel: EditPageViewModel?
    public var disposeBag: DisposeBag? = DisposeBag()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = viewModel?.model
        bindViewAndViewModel()
        viewModel?.react()
    }
    
    deinit {
        disposeBag = nil
    }
    
    func bindViewAndViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.rxBrightness <~> brightnessSlider.rx.value => disposeBag
        viewModel.rxSaturation <~> saturationSlider.rx.value => disposeBag
        viewModel.rxContrast <~> contrastSlider.rx.value => disposeBag
        viewModel.rxTemperature <~> tempSlider.rx.value => disposeBag
        
        viewModel.rxSelectedEditing
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (type) in
                guard let self = self else { return }
                
                for slider in self.sliders {
                    slider.isHidden = slider.tag != NSInteger(type.rawValue)
                }
                for button in self.buttons {
                    button.isSelected = button.tag == NSInteger(type.rawValue)
                }
        }) => disposeBag
        
        viewModel.rxOutputImage
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (image) in
                guard let self = self else { return }
                guard let image = image else { return }
                
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
        }) => disposeBag
    }
    
    @IBAction func buttonDidTap(button: UIButton) {
        if button.tag == EditPageType.cropAndRotate.rawValue {
            guard let image = imageView.image else { return }
            
            GPCropViewController.presentCropEditor(from: self, image: image, animated: false, finished: { [weak self] (image) in
                guard let self = self else { return }
                self.viewModel?.model = image
                self.viewModel?.image = image.toCIImage()
                self.imageView.image = image
            })
            return
        }
        
        viewModel?.rxSelectedEditing.accept(EditPageType(rawValue: button.tag) ?? EditPageType.brightness)
        
        let index = buttons.index(of: button)
        let label = smallTitleLabels[index ?? 0]
        titleLabel.text = label.text
    }
    
    @IBAction func closeButtonTapped(button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneTapped(button: UIButton) {
        if let image = imageView.image ?? viewModel?.image {
            self.doneBlock?(image as! UIImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Static
    public static func create(with viewModel: EditPageViewModel?) -> EditPage {
        let vc = EditPage(nibName: "EditPage", bundle: GPImageEditorBundle.getBundle())
        vc.viewModel = viewModel
        return vc
    }

    public static func present(from viewController: UIViewController, image: UIImage, animated: Bool, finished: @escaping ((UIImage) -> Void), completion: (() -> Void)? = nil) {
        let viewModel = EditPageViewModel(model: image)
        let vc = EditPage.create(with: viewModel)
        vc.modalPresentationStyle = .fullScreen
        vc.doneBlock = finished
        viewController.present(vc, animated: animated, completion: completion)
    }
    
}
