//
//  EffectPage.swift
//  GPImageEditor
//
//  Created by Ngoc Thang on 9/12/19.
//

import UIKit
import FittedSheets

public class EffectPage: UIViewController {

    var sourceImage: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var showEffectButton: UIButton!
    @IBOutlet var gradientTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    private var isShowingEffectsView: Bool = true
    
    public static func create(with image: UIImage?) -> EffectPage? {
        let bundle = Bundle(for: EffectPage.self)
        let vc = EffectPage(nibName: "EffectPage", bundle: bundle)
        vc.sourceImage = image
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = sourceImage
    }
    
    @IBAction func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hideShowEffectsTapped() {
        isShowingEffectsView = !isShowingEffectsView
        gradientTopConstaint.constant = isShowingEffectsView ? 0 : 125
        let imageName = isShowingEffectsView ? "arrow-down-icon.png" : "arrow-top-icon.png"
        let bundle = Bundle(for: EffectPage.self)
        showEffectButton.setImage(UIImage(named: imageName, in: bundle, compatibleWith: nil),
                                  for: .normal)
    }
    
    @IBAction func stickerTapped() {
        
    }
    
    @IBAction func textTapped() {
    
    }
    
    @IBAction func drawTapped() {
    
    }
    
    @IBAction func otherEditTapped() {
    
    }

}
