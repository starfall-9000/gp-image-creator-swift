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
    
    let cellName = "EffectCell"
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var showEffectButton: UIButton!
    @IBOutlet var gradientTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    private var isShowingEffectsView: Bool = true
    var viewModel: EffectPageViewModel?
    
    public static func create(with viewModel: EffectPageViewModel?) -> EffectPage {
        let bundle = Bundle(for: EffectPage.self)
        let vc = EffectPage(nibName: "EffectPage", bundle: bundle)
        vc.viewModel = viewModel
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = viewModel?.sourceImage
        doneButton.cornerRadius = 16
        setupCollectionView()
    }
    
    @IBAction func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hideShowEffectsTapped() {
        isShowingEffectsView = !isShowingEffectsView
        self.gradientTopConstaint.constant = self.isShowingEffectsView ? 0 : 125
        let imageName = self.isShowingEffectsView ? "arrow-down-icon.png" : "arrow-top-icon.png"
        let bundle = Bundle(for: EffectPage.self)
        self.showEffectButton.setImage(UIImage(named: imageName, in: bundle, compatibleWith: nil),
                                  for: .normal)
        self.collectionView.isHidden = !self.isShowingEffectsView
    }
    
    private func setupCollectionView() {
        let bundle = Bundle(for: EffectPage.self)
        let nib = UINib(nibName: cellName, bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: cellName)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @IBAction func stickerTapped() {
        
    }
    
    @IBAction func textTapped() {
    
    }
    
    @IBAction func drawTapped() {
    
    }
    
    @IBAction func otherEditTapped() {
    
    }
    
    @IBAction func doneTapped() {
        dismiss(animated: true, completion: nil)
        doneBlock?(imageView.image!)
    }

    open func collectionViewLayout() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 75, height: 135)
    }
 
    // MARK: - Open picker
    class func presentImageEditor(from viewController: UIViewController, image: UIImage, animated: Bool, finished: @escaping ((UIImage) -> Void), completion: (() -> Void)? = nil) {
        let viewModel = EffectPageViewModel(image: image)
        let vc = EffectPage.create(with: viewModel)
        vc.doneBlock = finished
        viewController.present(vc, animated: animated, completion: completion)
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
        guard let filter = viewModel?.items[indexPath.row] else {
            return
        }
        viewModel?.rxSelectedFilter.accept(filter)
        guard let sourceImage = viewModel?.sourceImage else {
            return
        }
        let image = filter.applyFilter(image: sourceImage)
        imageView.image = image
    }

}
