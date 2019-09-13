//
//  EmojiCell.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/12/19.
//

import Foundation
import DTMvvm
import RxSwift
import RxCocoa

public class EmojiCellViewModel: CellViewModel<String> {
    let rxEmoji = BehaviorRelay<String?>(value: nil)
    
    override public func react() {
        super.react()
        guard let model = model else { return }
        rxEmoji.accept(model)
    }
}

public class EmojiCell: CollectionCell<EmojiCellViewModel> {
    
    var emojiLabel: UILabel = {
        let label = UILabel()
        let widthRatio = UIScreen.main.bounds.width/375
        label.font = UIFont.systemFont(ofSize: 30 * widthRatio)
        return label
    }()
    
    override public func initialize() {
        super.initialize()
        backgroundColor = .clear
        contentView.addSubview(emojiLabel)
        emojiLabel.autoPinEdgesToSuperviewEdges()
    }
    
    override public func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let viewModel = viewModel else { return }
        viewModel.rxEmoji ~> emojiLabel.rx.text => disposeBag
    }
}
