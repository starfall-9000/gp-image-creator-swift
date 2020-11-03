//
//  StickerCell.swift
//  Action
//
//  Created by ToanDK on 9/10/19.
//

import Foundation
import DTMvvm
import RxSwift
import RxCocoa
import Action
import AlamofireImage
import SDWebImage

public class StickerCellViewModel: CellViewModel<StickerModel> {
    let rxImage = BehaviorRelay<URL?>(value: nil)
    
    override public func react() {
        super.react()
        guard let model = model else { return }
        rxImage.accept(URL(string: model.imageURL))
    }
}

public class StickerCell: CollectionCell<StickerCellViewModel> {
    
    var photoImg: UIImageView = {
        let photo = UIImageView()
        photo.contentMode = UIView.ContentMode.scaleAspectFit
        return photo
    }()
    
    override public func initialize() {
        super.initialize()
        backgroundColor = .clear
        contentView.addSubview(photoImg)
        photoImg.autoPinEdgesToSuperviewEdges()
    }
    
    override public func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let viewModel = viewModel else { return }
        viewModel.rxImage.subscribe(onNext: { [weak self] url in
            self?.photoImg.sd_setImage(with: url, completed: nil)
        }) => disposeBag
    }
}
