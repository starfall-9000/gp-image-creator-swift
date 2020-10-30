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

private struct Constants {
    static let DEFAULT_PACKAGE_ID = "1"
}

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
    var packageIds: [String] = [Constants.DEFAULT_PACKAGE_ID]
    var tmpBag: DisposeBag?
    var stickerGroupType: StickerGroupType = .imageCreator
    
    convenience init(stickerGroupType: StickerGroupType) {
        self.init()
        self.stickerGroupType = stickerGroupType
    }
    
    override public func react() {
        rxLoading.accept(true)
        getPackages(fromCache: true)
        getPackages(fromCache: false)
    }
    
    func getStickers(page: Int, fromCache: Bool) {
        guard let apiService = stickerService else {return}
        let bag = page != 0 ? tmpBag : disposeBag
        self.page = page
        if page == 0 {
            itemsSource.reset([[]], animated: false)
        }
        
        let collection = packageIds.map { (id) in
            return apiService.getStickerList(page: 0, packageId: id, fromCache: fromCache).asObservable()
        }
        Observable.zip(collection).subscribe {[weak self] (stickerEvent) in
            guard let self = self, let responses = stickerEvent.element else { return }
            self.rxLoading.accept(false)
            self.rxIsLoadingMore.accept(false)
            var stickers: [StickerCellViewModel] = []
            responses.forEach { (response) in
                if response.code == .success {
                    let stickerMap = response.stickers.map({StickerCellViewModel(model: $0)})
                    stickers += stickerMap
                }
            }
            self.itemsSource.append(stickers, animated: false)
            self.rxCanLoadMore.accept(stickers.count > 0)
        } => bag
    }
    
    func getPackages(fromCache: Bool) {
        stickerService?.getPackages(group: self.stickerGroupType, fromCache: fromCache)
            .subscribe(onSuccess: { [weak self] (response) in
                guard let self = self else { return }
                self.rxLoading.accept(false)
                if response.code == .success {
                    let groupIds = response.groups.map { (group) -> String in
                        return "\(group.id)"
                    }
                    let packageIds: [String] = !response.groups.isEmpty ? groupIds : [Constants.DEFAULT_PACKAGE_ID]
                    self.packageIds = packageIds
                    self.getStickers(page: 0, fromCache: fromCache)
                }
                else {
                    self.rxCanLoadMore.accept(false)
                }
            }, onError: { [weak self] (error) in
                    self?.rxLoading.accept(false)
            }) => disposeBag
    }
    
    func loadMore() {
        if itemsSource.countElements() <= 0 || rxIsLoadingMore.value || !rxCanLoadMore.value { return }
        
        tmpBag = DisposeBag()
        
        rxIsLoadingMore.accept(true)
        page += 1
        
        getStickers(page: page, fromCache: true)
        getStickers(page: page, fromCache: false)
    }
}
