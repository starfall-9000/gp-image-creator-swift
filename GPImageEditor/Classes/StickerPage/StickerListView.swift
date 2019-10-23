//
//  StickerListView.swift
//  GPImageEditor
//
//  Created by ToanDK on 9/12/19.
//

import Foundation
import RxCocoa
import RxSwift
import DTMvvm

private let padding: CGFloat = 20

public class StickerListView: CollectionView<StickerListViewModel> {
    
    private var completion: ((UIImage?, CGSize, String) -> Void)? = nil
    private var loadingView = UIActivityIndicatorView(style: .white)
    
    init(viewModel: StickerListViewModel? = nil, completion: ((UIImage?, CGSize, String) -> Void)?) {
        super.init(viewModel: viewModel)
        self.completion = completion
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func initialize() {
        super.initialize()
        
        backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.register(StickerCell.self, forCellWithReuseIdentifier: StickerCell.identifier)
        
        addSubview(loadingView)
        loadingView.autoCenterInSuperview()
    }
    
    override public func bindViewAndViewModel() {
        super.bindViewAndViewModel()
        guard let viewModel = viewModel else { return }
        viewModel.rxLoading ~> loadingView.rx.isAnimating => disposeBag
        viewModel.rxLoading.map{ !$0 } ~> loadingView.rx.isHidden => disposeBag
        
//        collectionView.rx.endReach.subscribe(onNext: {
//            viewModel.loadMore()
//        }) => disposeBag
    }
    
    override public func cellIdentifier(_ cellViewModel: StickerCellViewModel) -> String {
        return StickerCell.identifier
    }
    
    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewWidth = collectionView.frame.width
        
        let numOfCols: CGFloat = 3
        
        let contentWidth = viewWidth - ((numOfCols + 1) * padding)
        let width = contentWidth / numOfCols
        return CGSize(width: width, height: width)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    override public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .all(padding)
    }
    
    override public func selectedItemDidChange(_ cellViewModel: StickerCellViewModel) {
        guard let indexPath = cellViewModel.indexPath,
            let cell = collectionView(collectionView, cellForItemAt: indexPath) as? StickerCell
            else { return }
        let newSize = CGSize(width: cell.bounds.size.width*1.5, height: cell.bounds.size.height*1.5)
        completion?(cell.photoImg.image, newSize, cellViewModel.model?.id ?? "")
    }
}

extension StickerListView {
    
    static func getInstance(completion: ((UIImage?, CGSize, String) -> Void)?) -> StickerListView {
        let vm = StickerListViewModel(model: nil)
        return StickerListView(viewModel: vm, completion: completion)
    }
}

public class StickerListViewModel: ListViewModel<Model, StickerCellViewModel> {
    let rxLoading = BehaviorRelay<Bool>(value: false)
    let rxIsLoadingMore = BehaviorRelay<Bool>(value: false)
    let rxCanLoadMore = BehaviorRelay<Bool>(value: true)
    let stickerService: StickerAPIService? = GPImageEditorConfigs.dependencyManager?.getService()
    var page: Int = 0
    var tmpBag: DisposeBag?
    
    override public func react() {
        rxLoading.accept(true)
        
        getStickers(page: 0)
    }
    
    func getStickers(page: Int) {
        let bag = page != 0 ? tmpBag : disposeBag
        self.page = page
        if page == 0 {
            itemsSource.reset([[]], animated: false)
        }
        stickerService?.getStickerList(page: page)
            .subscribe(onSuccess: { [weak self] (response) in
                guard let self = self else { return }
                self.rxLoading.accept(false)
                self.rxIsLoadingMore.accept(false)
                if response.code == .success {
                    let stickers = response.stickers.map{ StickerCellViewModel(model: $0) }
                    self.itemsSource.append(stickers, animated: false)
                    self.rxCanLoadMore.accept(stickers.count > 0)
                }
                else {
                    self.rxCanLoadMore.accept(false)
                }
                }, onError: { [weak self] (error) in
                    self?.rxLoading.accept(false)
                    self?.rxIsLoadingMore.accept(false)
                    self?.rxCanLoadMore.accept(false)
            }) => bag
    }
    
    func loadMore() {
        if itemsSource.countElements() <= 0 || rxIsLoadingMore.value || !rxCanLoadMore.value { return }
        
        tmpBag = DisposeBag()
        
        rxIsLoadingMore.accept(true)
        page += 1
        
        getStickers(page: page)
    }
}
