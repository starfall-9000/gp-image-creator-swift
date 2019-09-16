//
//  EffectCell.swift
//  GPImageEditor
//
//  Created by Ngoc Thang on 9/13/19.
//

import UIKit
import RxSwift
import DTMvvm
import RxCocoa

public class EffectCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var disposeBag: DisposeBag? = DisposeBag()
    var model: GPImageFilter?
    var viewModel: EffectPageViewModel?
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        imageView.cornerRadius = 10
    }
    
    func bind(model: GPImageFilter?, viewModel: EffectPageViewModel?) {
        self.model = model
        self.viewModel = viewModel
        
        setup()
        bindViewModel()
    }

    func setup() {
        titleLabel.text = model?.name
        
        guard let filter = model, let thumb = viewModel?.thumbImage else { return }
        let image = filter.applyFilter(image: thumb)
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.rxSelectedFilter.subscribe(onNext: { [weak self] (filter) in
            guard let self = self else { return }
            let selected = filter == self.model
            let color = selected ? UIColor(hexString: "#6FBE49") : UIColor.white
            self.titleLabel.textColor = color
            self.titleLabel.font = selected ? UIFont.boldSystemFont(ofSize: 12) : UIFont.systemFont(ofSize: 12)
        }) => disposeBag
    }
    
    deinit {
        disposeBag = nil
    }
    
}
