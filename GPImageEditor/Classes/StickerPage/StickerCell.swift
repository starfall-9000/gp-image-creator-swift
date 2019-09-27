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

public class StickerCellViewModel: CellViewModel<StickerModel> {
    let rxImage = BehaviorRelay<NetworkImage>(value: NetworkImage())
    
    override public func react() {
        super.react()
        guard let model = model else { return }
        rxImage.accept(NetworkImage(withURL: URL(string: model.imageURL), placeholder: nil, completion: nil))
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
        viewModel.rxImage ~> photoImg.rx.networkImage => disposeBag
    }
}
