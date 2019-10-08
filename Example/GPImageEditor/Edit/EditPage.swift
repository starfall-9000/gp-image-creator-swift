//
//  EditPage.swift
//  GPImageEditor_Example
//
//  Created by Ngoc Thang on 10/7/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import  RxSwift
import DTMvvm

public class EditPage: UIViewController {

    var doneBlock: ((UIImage) -> Void)?
    
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var contrastSlider: UISlider!
    @IBOutlet weak var saturationSlider: UISlider!
    @IBOutlet weak var tempSlider: UISlider!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var sliders: [UISlider]!
    
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
                    button.isSelected = button.tag != NSInteger(type.rawValue)
                }
        }) => disposeBag
        
        viewModel.rxOutputImage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (image) in
                guard let self = self else { return }
                guard let image = image else { return }
                
                self.imageView.image = image.toUIImage()
        }) => disposeBag
    }
    
    @IBAction func buttonDidTap(button: UIButton) {
        viewModel?.rxSelectedEditing.accept(EditPageType(rawValue: button.tag) ?? EditPageType.brightness)
    }
    
    @IBAction func closeButtonTapped(button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Static
    public static func create(with viewModel: EditPageViewModel?) -> EditPage {
        let vc = EditPage(nibName: "EditPage", bundle: nil)
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
