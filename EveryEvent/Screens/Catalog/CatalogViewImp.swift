import UIKit
import YandexMapsMobile

final class CatalogViewImp: UIView, CatalogView {
    
    public let placeInfoView = PlaceInfoView().ui.alpha(0).forAutoLayout()
    
    private var placeInfoBottomConstraint: NSLayoutConstraint?
    
    private var bottomViewTopConstraint: NSLayoutConstraint?
    
    private var bottomViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = A.Colors.white.color
        
        setup()
        
        displayLoading(enable: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: MAP
    public var map: YMKMap {
        mapView.mapWindow.map
    }
    
    private(set) lazy var mapView: YMKMapView = {
        let isM1Silulator = (TARGET_IPHONE_SIMULATOR & TARGET_CPU_ARM64) != 0
        let map = YMKMapView(frame: .zero, vulkanPreferred: isM1Silulator )
        map?.translatesAutoresizingMaskIntoConstraints = false
        
        return map!
    }()
    
    func showMap(with show: Bool) {
        subviews.forEach { view in
            view.isHidden = show
        }
        filterStackView.isHidden = true
        mapView.isHidden = !show
    }
    
    public func didSelectPlacemark(isNil: Bool) {
        placeInfoView.alpha = isNil ? 0 : 1
        placeInfoView.isHidden = false
        placeInfoView.setNeedsLayout()
        placeInfoView.layoutIfNeeded()
    }
    
    //MARK: Properties
    private var defaultCellData: [EventCellData] = []
    private var cellData: [EventCellData] = []
    private var filteredCellData = [EventCellData]()
    private var searchBarIsEmpty: Bool {
        guard let text = search.searchBar.text else {
            return false
        }
        
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return search.isActive && !searchBarIsEmpty
    }
    
    var willDisplayProduct: ((Int) -> Void)?
    var onRefresh: (() -> Void)?
    
    //MARK: Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        catalogCollectionView.contentInset.top = headerStackView.frame.height
    }
    
    //MARK: Setup
    private func setup() {
        map.mapType = .vectorMap
        mapView.mapWindow.map.logo.setAlignmentWith(YMKLogoAlignment(
            horizontalAlignment: .right,
            verticalAlignment: YMKLogoVerticalAlignment.top
        ))
        
        mapView.isHidden = true
        addSubview(mapView)
        addSubview(catalogCollectionView)
        addSubview(headerStackView)
        addSubview(loadingImageView)
        addSubview(filterStackView)
        addSubview(placeInfoView)
        bringSubviewToFront(filterStackView)
        
        headerStackView.backgroundColor = .white
        
        NSLayoutConstraint.activate(
            [
                mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
                mapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
                bottomAnchor.constraint(equalTo: mapView.bottomAnchor),
                
                placeInfoView.heightAnchor.constraint(equalToConstant: 400),
                placeInfoView.leadingAnchor.constraint(equalTo: leadingAnchor),
                trailingAnchor.constraint(equalTo: placeInfoView.trailingAnchor),
                placeInfoView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                headerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: -10),
                headerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
                headerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
                
                filterStackView.topAnchor.constraint(equalTo: listFilterTitleButton.topAnchor),
                filterStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 33),
                filterStackView.widthAnchor.constraint(equalToConstant: 200),
                
                catalogCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                catalogCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                catalogCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                catalogCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                loadingImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                loadingImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        )
    }
    
    enum Constants {
        static let padding: CGFloat = 16
    }
    
    //MARK: Refresh Catalog
    private lazy var RefreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        
        refresh.tintColor = A.Colors.Primary.blue.color
        refresh.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        return refresh
    }()
    
    @objc
    private func refresh(sender: UIRefreshControl) {
        listFilterTitleButton.setTitle(defaultFilterButton.currentTitle, for: .normal)
        onRefresh?()
    }
    
    //MARK: Title block
    private lazy var titleProducdsLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 20, weight: .init(500))
        label.textColor = A.Colors.Grayscale.black.color
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        return label
    }()
    
    private lazy var numberProductsLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 20, weight: .init(500))
        label.textColor = A.Colors.Grayscale.midGray.color
        label.textAlignment = .right
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                titleProducdsLabel,
                numberProductsLabel
            ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        
        return stackView
    }()
    
    //MARK: Display settings block
    private lazy var listFilterTitleButton: UIButton = {
        let button = UIButton()
        
        button.setImage(A.Images.Catalog.listFilter.image, for: .normal)
        button.setTitle(" По умолчанию", for: .normal)
        button.setTitleColor(A.Colors.Grayscale.black.color, for: .normal)
        button.backgroundColor = A.Colors.white.color
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont(name: "GothamSSm-Medium", size: 14)
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(filterAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func filterAction() {
        if filterStackView.isHidden {
            filterStackView.isHidden = false
            
        } else {
            filterStackView.isHidden = true
        }
        
    }
    
    private lazy var defaultFilterButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(" По умолчанию", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamSSm-Medium", size: 14)
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.addTarget(self, action: #selector(defaultAction), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var bestEventsFilterButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(" Лучшие мероприятия", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamSSm-Medium", size: 14)
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.addTarget(self, action: #selector(bestEventsFilterAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func bestEventsFilterAction() {
        let data = defaultCellData.sorted(by: { $0.promotionCount > $1.promotionCount })
        self.cellData = data
        catalogCollectionView.reloadData()
        filterStackView.isHidden = true
        listFilterTitleButton.setTitle(bestEventsFilterButton.currentTitle, for: .normal)
    }
    
    @objc
    private func defaultAction() {
        self.cellData = self.defaultCellData
        catalogCollectionView.reloadData()
        filterStackView.isHidden = true
        listFilterTitleButton.setTitle(defaultFilterButton.currentTitle, for: .normal)
    }
    
    private lazy var nameAZFilterButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(" По имени ↑", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamSSm-Medium", size: 14)
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.addTarget(self, action: #selector(aZAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func aZAction() {
        let data = defaultCellData.sorted(by: { $0.name ?? "a" < $1.name ?? "b" })
        self.cellData = data
        catalogCollectionView.reloadData()
        filterStackView.isHidden = true
        listFilterTitleButton.setTitle(nameAZFilterButton.currentTitle, for: .normal)
    }
    
    private lazy var nameZAFilterButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(" По имени ↓", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamSSm-Medium", size: 14)
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.addTarget(self, action: #selector(zAAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func zAAction() {
        let data = defaultCellData.sorted(by: { $0.name ?? "a" > $1.name ?? "b" })
        self.cellData = data
        catalogCollectionView.reloadData()
        filterStackView.isHidden = true
        listFilterTitleButton.setTitle(nameZAFilterButton.currentTitle, for: .normal)
    }

    private lazy var categoryFilterButton: UIButton = {
        let button = UIButton()
        
        button.setTitle(" По категории", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "GothamSSm-Medium", size: 14)
        button.contentHorizontalAlignment = .left
        button.heightAnchor.constraint(equalToConstant: 25).isActive = true
        button.addTarget(self, action: #selector(categoryAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func categoryAction() {
        let data = defaultCellData.sorted(by: { $0.category ?? "a" > $1.category ?? "b" })
        self.cellData = data
        catalogCollectionView.reloadData()
        filterStackView.isHidden = true
        listFilterTitleButton.setTitle(categoryFilterButton.currentTitle, for: .normal)
    }

    
    private lazy var filterStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    defaultFilterButton,
                    nameAZFilterButton,
                    nameZAFilterButton,
                    categoryFilterButton,
                    bestEventsFilterButton
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.backgroundColor = .white
        stackView.isHidden = true
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.gray.cgColor
        
        return stackView
    }()

    private lazy var settingsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                listFilterTitleButton
            ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
       
        return stackView
    }()
    
    //MARK: Header stackView
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                titleStackView,
                settingsStackView
            ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = A.Colors.white.color
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        
        return stackView
    }()
    
    //MARK: Loading image
    private lazy var loadingImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = A.Images.System.loading.image
        imageView.alpha = 0
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        return imageView
    }()
    
    //MARK: CollectionView
    private lazy var catalogCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewCompositionalLayout { _, _ in
            EventCell.layout()
        }
        
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(EventCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = RefreshControl
        
        return collectionView
    }()
    
    //MARK: SearchController
    lazy var search: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Найти мероприятие"
        
        return search
    }()
    
    //MARK: Display data
    func display(
        cellData: [EventCellData],
        titleData: EventTitleData,
        animated: Bool
    ) {
        self.cellData = cellData
        self.defaultCellData = cellData
        
        titleProducdsLabel.text = titleData.title
        
        numberProductsLabel.text = String(titleData.quantity)
        
        catalogCollectionView.refreshControl?.endRefreshing()
        catalogCollectionView.reloadData()
    }
}

//MARK: Calalog view settings
extension CatalogViewImp: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if isFiltering {
            numberProductsLabel.text = String(filteredCellData.count)
            return filteredCellData.count
        }
        numberProductsLabel.text = String(cellData.count)
        return cellData.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let cell = cell as? EventCell {
            if isFiltering {
                cell.update(with: filteredCellData[indexPath.item])
            } else {
                cell.update(with: cellData[indexPath.item])
            }
        }
        
        return cell
    }
}

//MARK: Collection view logic
extension CatalogViewImp: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if isFiltering {
            filteredCellData[indexPath.item].onSelect()
        } else {
            cellData[indexPath.item].onSelect()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        filterStackView.isHidden = true
        let diff = scrollView.contentInset.top + scrollView.contentOffset.y

        if scrollView.contentOffset.y > -headerStackView.frame.height-search.searchBar.frame.height-400 {
            headerStackView.transform = .init(translationX: 0, y: -min(diff, titleStackView.frame.height))
            filterStackView.transform = .init(translationX: 0, y: -min(diff, titleStackView.frame.height))
        } else {
            headerStackView.transform = .init(translationX: 0, y: 0)
        }
    }
}

//MARK: SearchResultUpdating
extension CatalogViewImp: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredCellData = cellData.filter({ event in
            return containsString(text: event.name, searchText: searchText) || containsString(text: event.address, searchText: searchText) || containsString(text: event.category, searchText: searchText) || containsString(text: event.date, searchText: searchText)
        })
        
        catalogCollectionView.reloadData()
    }
    
    private func containsString(text: String?, searchText: String) -> Bool {
        guard let text = text else {
            return false
        }
        
        return text.lowercased().contains(searchText.lowercased())
    }
    
}

//MARK: Screen loading animation
extension CatalogViewImp {
    func displayLoading(enable: Bool) {
        if !enable {
            catalogCollectionView.isHidden = false
            catalogCollectionView.isUserInteractionEnabled = true
            headerStackView.isUserInteractionEnabled = true
            headerStackView.isHidden = false
            
            UIView.animate(withDuration: 0.2) {
                self.loadingImageView.alpha = 0
            }
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.loadingImageView.alpha = 1
        }
        
        catalogCollectionView.isHidden = true
        catalogCollectionView.isUserInteractionEnabled = false
        headerStackView.isUserInteractionEnabled = false
        headerStackView.isHidden = true
        
        UIView.animateKeyframes(
            withDuration: 1,
            delay: 0,
            options: [.repeat],
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                    self.loadingImageView.transform = .init(rotationAngle: Double.pi/2)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                    self.loadingImageView.transform = .init(rotationAngle: Double.pi)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                    self.loadingImageView.transform = .init(rotationAngle: Double.pi*1.5)
                }
                
                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                    self.loadingImageView.transform = .init(rotationAngle: Double.pi*2)
                }
            }
        )
    }
}
