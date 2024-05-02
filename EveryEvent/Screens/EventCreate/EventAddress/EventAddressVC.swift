////
////  petrovich
////  Copyright © 2023 Heads and Hands. All rights reserved.
////
//
//import UIKit
//import YandexMapsMobile
//
//final class EventAddressViewController<View: EventAddressView>: BaseViewController<View> {
//
//    private let throttler = Throttler(delay: 0.5)
//    private var request: CancellableTask? {
//        didSet {
//            oldValue?.cancel()
//        }
//    }
//
//    private lazy var locationManager = LocationManager()
//
//    private var currentAddress: String?
//
//    var suggestResults: [YMKSuggestItem] = []
//    var searchManager: YMKSearchManager!
//    var suggestSession: YMKSearchSuggestSession!
//    var mapBoundingBox: YMKBoundingBox!
//    let opts = YMKSuggestOptions()
//
//    // MARK: Initialization
//    public let cancellables = CancellableTaskStorage()
//
//    init() {
//        super.init(nibName: nil, bundle: nil)
//
//        YMKMapKit.sharedInstance().onStart()
//        searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: Life cycle
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//
//        suggestSession = searchManager.createSuggestSession()
//
//        rootView.deliveryButton.addAction { [unowned self] in
//            guard rootView.currentAddress().isNotEmpty else {
//                rootView.showEmptyAddressError()
//                return
//            }
//            
//        }
//
//        rootView.addressChanged { [unowned self] address in
//            guard let address, address.isNotEmpty else {
//                return
//            }
//
//            request?.cancel()
//            throttler.debounce { [weak self] in
//                self?.loadSuggestion(address: address)
//            }
//        }
//    }
//
//    // MARK: Load Data
//
//    private func loadData() {
//        Task {
//            do {
//                if locationManager.authorizationStatus == .notDetermined {
//                    await locationManager.requestTemporaryFullAccuracyAuthorization(purpose: .user)
//                }
//
//                var location = await locationManager.requestLastLocation()
//                if location == nil {
//                    location = await locationManager.requestLocation()
//                }
//
//                if let location {
//                    let coordinates = Coordinates(
//                        longitude: location.coordinate.longitude,
//                        latitude: location.coordinate.latitude
//                    )
//                    rootView.setLocation(coordinates: coordinates, zoom: 16)
//                } 
//            } catch {
////                router.showSnackbar(for: error)
////                if let mapData {
////                    rootView.setLocation(
////                        coordinates: mapData.centerCoords,
////                        zoom: mapData.zoom
////                    )
////                }
//            }
////            rootView.hideIndication(animated: false)
//        }.store(in: cancellables)
//    }
//
//    private func loadSuggestion(address: String) {
//        request = Task {
//            do {
//                let suggestItems = try await suggestForAddress(address: address)
//                showSuggestedItems(
//                    items: suggestItems?.filter { $0.center != nil },
//                    address: address
//                )
//            }
//        }.store(in: cancellables)
//    }
//
//    private func requestGeoAccess() {
//        rootView.myLocationButton.isLoading = true
//        Task {
//            var location = await locationManager.requestLastLocation()
//            if location == nil {
//                location = await locationManager.requestLocation()
//            }
//            if let location {
//                let coordinates = Coordinates(
//                    longitude: location.coordinate.longitude,
//                    latitude: location.coordinate.latitude
//                )
//                rootView.setLocation(coordinates: coordinates, zoom: 16)
//            } else {
//            }
//            rootView.myLocationButton.isLoading = false
//        }
//    }
//
//    private func showSuggestedItems(items: [YMKSuggestItem]?, address: String) {
//        rootView.collectionManager.clear()
//        guard let items, items.isNotEmpty else {
//            rootView.showEmptySuggestionsState()
//            return
//        }
//
//        if let first = items.first, first.type == .unknown {
//            rootView.showEmptySuggestionsState()
//            return
//        }
//
//        rootView.hideEmptySuggestionsState()
//        var sections: [CollectionManager.NewSection] = []
//        items.forEach { address in
//            let items = [
//                AddressSuggestionVM(title: address.title.text, suggestItem: address, type: .search) { [unowned self] item in
//                    self.currentAddress = item.title
//                    self.rootView.updateAddress(address: item.title, close: item.action == .search)
//                    if item.action == .search {
//                        self.rootView.setLocation(coordinates: item.coordinates, zoom: 16)
//                    }
//                }
//            ]
//            sections.append(CollectionManager.NewSection(AddressSuggestioSection(), items: items))
//        }
//        rootView.collectionManager.reload(sections: sections)
//    }
//
//    private func suggestForAddress(address: String) async throws -> [YMKSuggestItem]? {
//        try await withCheckedThrowingContinuation { continuation in
//            let visibleRegion = rootView.map.visibleRegion
//            suggestSession.suggest(
//                withText: address,
//                window: mapBoundingBox ?? .init(southWest: visibleRegion.bottomLeft, northEast: visibleRegion.bottomRight),
//                suggestOptions: opts
//            ) { response, error in
//                if let error {
//                    continuation.resume(throwing: error)
//                    return
//                }
//                continuation.resume(returning: response?.items)
//            }
//        }
//    }
//
//    private func saveAddress(coordinates: Coordinates) {
//        //todo with coords
//    }
//}
//
////
////  petrovich
////  Copyright © 2022 Heads and Hands. All rights reserved.
////
