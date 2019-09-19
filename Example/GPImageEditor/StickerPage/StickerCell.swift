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
//    let rxImageUrl = BehaviorRelay<String?>(value: nil)
    let rxImage = BehaviorRelay<UIImage?>(value: nil)
    let rxLoading = BehaviorRelay<Bool>(value: false)
    
    let downloader = ImageDownloader(configuration: ImageDownloader.defaultURLSessionConfiguration(),
                                     downloadPrioritization: .fifo,
                                     maximumActiveDownloads: 4,
                                     imageCache: AutoPurgingImageCache())
    
    override public func react() {
        super.react()
        guard let model = model else { return }
        if !model.localFileName.isEmpty {
            rxLoading.accept(true)
            DispatchQueue.global(qos: .background).async {
                let image = UIImage(named: model.localFileName, in: GPImageEditorBundle.getBundle(), compatibleWith: nil)
                self.rxImage.accept(image)
                DispatchQueue.main.async {
                    self.rxLoading.accept(false)
                }
            }
        }
        else {
            if let url = URL(string: model.imageURL) {
                rxLoading.accept(true)
                downloader.download(URLRequest(url: url)) { [weak self] response in
                    self?.rxLoading.accept(false)
                    if let image = response.result.value {
                        self?.rxImage.accept(image)
                    }
                }
            }
        }
    }
}

public class StickerCell: CollectionCell<StickerCellViewModel> {
    
    var photoImg: UIImageView = {
        let photo = UIImageView()
        photo.contentMode = UIView.ContentMode.scaleAspectFit
        return photo
    }()
    
    var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .white)
        return view
    }()
    
    override public func initialize() {
        super.initialize()
        backgroundColor = .clear
        contentView.addSubview(photoImg)
        photoImg.autoPinEdgesToSuperviewEdges()
        contentView.addSubview(loadingView)
        loadingView.autoCenterInSuperview()
    }
    
    override public func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let viewModel = viewModel else { return }
        
        viewModel.rxImage.observeOn(Scheduler.shared.mainScheduler).subscribe(onNext: { [weak self] image in
            self?.photoImg.image = image
        }) => disposeBag
        
        viewModel.rxLoading.subscribe(onNext: { [weak self] (loading) in
            self?.loadingView.isHidden = !loading
            loading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }) => disposeBag
    }
}
