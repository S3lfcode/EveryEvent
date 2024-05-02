import UIKit
import Firebase
import YandexMapsMobile

final class EventCreateVC<View: EventCreateView>: BaseViewController<View> {
    
    //MARK: Properties
    var onCatalog: (() -> Void)?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        navigationController?.navigationBar.topItem?.title = ""
        
        createEvent()
        
        suggestSession = searchManager.createSuggestSession()
        rootView.addressChanged { [unowned self] address in
            guard let address, address.isNotEmpty else {
                return
            }

            request?.cancel()
            throttler.debounce { [weak self] in
                self?.loadSuggestion(address: address)
            }
        }
    }
    
    private func createEvent() {
        rootView.onCreateAction = { [weak self] name, url, category, address, date, desc in
            guard let currentUser = Auth.auth().currentUser else {
                print("Для создания меропритяия нужно войти в аккаунт")
                return
            }
            
            guard let currentCoordinates = self?.currentCoordinates, let currentAddress = self?.currentAddress else { return }
            
            let event = Event(
                userId: currentUser.uid,
                address: currentAddress,
                category: category,
                date: date,
                desc: desc,
                lat: currentCoordinates.latitude,
                lng: currentCoordinates.longitude,
                name: name,
                urlImage: url
            )
            
            DatabaseService.shared.setEvent(event: event) { result in
                switch result {
                case .success(let event):
                    print("Мероприятие успешно создано: \n\(event)")
                case .failure(let error):
                    print("Возникла ошибка при создании мероприятия: \n\(error)")
                }
            }
            
            self?.onCatalog?()
        }
    }
    
    private let throttler = Throttler(delay: 0.5)
    private var request: CancellableTask? {
        didSet {
            oldValue?.cancel()
        }
    }

    private lazy var locationManager = LocationManager()

    private var currentAddress: String?
    private var currentCoordinates: Coordinates?

    var suggestResults: [YMKSuggestItem] = []
    var searchManager: YMKSearchManager!
    var suggestSession: YMKSearchSuggestSession!
    var mapBoundingBox: YMKBoundingBox!
    let opts = YMKSuggestOptions()

    // MARK: Initialization
    public let cancellables = CancellableTaskStorage()

    init() {
        super.init(nibName: nil, bundle: nil)

        YMKMapKit.sharedInstance().onStart()
        searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Load Data

    private func loadData() {
        Task {
            do {
                if locationManager.authorizationStatus == .notDetermined {
                    await locationManager.requestTemporaryFullAccuracyAuthorization(purpose: .user)
                }

                var location = await locationManager.requestLastLocation()
                if location == nil {
                    location = await locationManager.requestLocation()
                }

                if let location {
                    let coordinates = Coordinates(
                        longitude: location.coordinate.longitude,
                        latitude: location.coordinate.latitude
                    )
                    rootView.setLocation(coordinates: coordinates, zoom: 16)
                }
            }
        }.store(in: cancellables)
    }

    private func requestGeoAccess() {
        rootView.myLocationButton.isLoading = true
        Task {
            var location = await locationManager.requestLastLocation()
            if location == nil {
                location = await locationManager.requestLocation()
            }
            if let location {
                let coordinates = Coordinates(
                    longitude: location.coordinate.longitude,
                    latitude: location.coordinate.latitude
                )
                rootView.setLocation(coordinates: coordinates, zoom: 16)
            } else {
            }
            rootView.myLocationButton.isLoading = false
        }
    }
    
    private func loadSuggestion(address: String) {
        request = Task {
            do {
                let suggestItems = try await suggestForAddress(address: address)
                showSuggestedItems(
                    items: suggestItems?.filter { $0.center != nil },
                    address: address
                )
            }
        }.store(in: cancellables)
    }

    private func showSuggestedItems(items: [YMKSuggestItem]?, address: String) {
        rootView.collectionManager.clear()
        guard let items, items.isNotEmpty else {
            rootView.showEmptySuggestionsState()
            return
        }

        if let first = items.first, first.type == .unknown {
            rootView.showEmptySuggestionsState()
            return
        }

        rootView.hideEmptySuggestionsState()
        var sections: [CollectionManager.NewSection] = []
        items.forEach { address in
            let items = [
                AddressSuggestionVM(title: address.title.text, suggestItem: address, type: .search) { [unowned self] item in
                    self.currentAddress = item.title
                    self.currentCoordinates = item.coordinates
                    self.rootView.updateAddress(address: " \"\(item.title)\" " + (item.subtitle ?? ""), close: item.action == .search)
                }
            ]
            sections.append(CollectionManager.NewSection(AddressSuggestioSection(), items: items))
        }
        rootView.collectionManager.reload(sections: sections)
        rootView.collectionManager.collectionView.reloadData()
    }

    private func suggestForAddress(address: String) async throws -> [YMKSuggestItem]? {
        try await withCheckedThrowingContinuation { continuation in
            let visibleRegion = rootView.map.visibleRegion
            suggestSession.suggest(
                withText: address,
                window: mapBoundingBox ?? .init(southWest: visibleRegion.bottomLeft, northEast: visibleRegion.bottomRight),
                suggestOptions: opts
            ) { response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: response?.items)
            }
        }
    }

    private func saveAddress(coordinates: Coordinates) {
        //todo with coords
    }

}


extension UIButton: PrimaryActionControl {
    public var primaryAction: UIControl.Event { .touchUpInside }
}
