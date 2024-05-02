import UIKit
import Firebase
import FirebaseFirestore
import YandexMapsMobile

final class CatalogVC<View: CatalogView>: BaseViewController<View>, YMKMapObjectTapListener, YMKClusterListener, YMKClusterTapListener {
    var onDisplayEvent: ((_ event: Event) -> Void)?
    var onMenu: (() -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)

        YMKMapKit.sharedInstance().onStart()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        rootView.onRefresh = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.loadData(force: true)
            }
        }
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            congfigurateNavigationBar()
    }
    
    //MARK: Yandex Map Kit
    private var events = [Event]()
    private var collection: YMKClusterizedPlacemarkCollection?
    private var pins = [YMKPlacemarkMapObject]()
    private var myPin: YMKPlacemarkMapObject?
    
    public func addEvents() {
        collection = rootView.map.mapObjects.addClusterizedPlacemarkCollection(with: self)
        guard let collection else {
            return
        }
        
        events.forEach { event in
            if let lat = event.lat, let lng = event.lng {
                
                let view = PinView(name: "EveryEvent", category: event.category, text: "")
                guard let pinView = YRTViewProvider(uiView: view) else {
                    return
                }
                
                let point = YMKPoint(latitude: lat, longitude: lng)
                let placemark = collection.addPlacemark()
                placemark.geometry = point
                placemark.addTapListener(with: self)
                placemark.setViewWithView(pinView)
                placemark.userData = event
                pins.append(placemark)
            }
            collection.clusterPlacemarks(withClusterRadius: 30, minZoom: 15)
            collection.zIndex = 10
        }
        
    }
    
    // MARK: YMKMapObjectTapListener
    @discardableResult
    public func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        deselectObject(object: selectedPlacemark)

        guard let pin = mapObject as? YMKPlacemarkMapObject else {
            return false
        }
        if let data = pin.userData as? Event {
            rootView.placeInfoView.show(.init(data) { [weak self] event in
                self?.onDisplayEvent?(event)
            })
        } else {
            return false
        }
        if rootView.map.cameraPosition.zoom <= 13 {
            moveCamera(to: pin.geometry, zoom: 13, duration: 0.7)
        }

        selectedPlacemark = pin
        return true
    }

    // MARK: YMKClusterListener
    public func onClusterAdded(with cluster: YMKCluster) {
        guard let view = YRTViewProvider(uiView: createClusterView(cluster.size)) else {
            return
        }

        cluster.appearance.setViewWithView(view, style: .init())
        cluster.addClusterTapListener(with: self)
    }

    private func deselectObject(object: YMKPlacemarkMapObject?) {
        selectedPlacemark = nil
    }
    
    private var selectedPlacemark: YMKPlacemarkMapObject? {
        didSet {
            rootView.didSelectPlacemark(isNil: selectedPlacemark == nil)
        }
    }

    private func createClusterView(_ clusterSize: UInt) -> UIView {
        let title = Label().ui
            .text("\(clusterSize)")
            .textStyle(.title3)
            .textColor(.white)
            .make()
        let view = UIView(frame: .init(x: 0, y: 0, width: 30, height: 30)).ui
            .backgroundColor(.gray)
            .cornerRadius(15)
            .clipsToBounds(true)
            .isOpaque(false)
            .addSubview(title)
            .make()
        let titleSize = title.systemLayoutSizeFitting(.zero)
        let titlePoint = CGPoint(x: (30 - titleSize.width) / 2, y: (30 - titleSize.height) / 2)
        title.frame = .init(origin: titlePoint, size: titleSize)
        return view
    }

    // MARK: YMKClusterTapListener

    public func onClusterTap(with cluster: YMKCluster) -> Bool {
        guard
            let southPoint = (cluster.placemarks.map { $0.geometry.latitude }).min(),
            let westPoint = (cluster.placemarks.map { $0.geometry.longitude }).min(),
            let northPoint = (cluster.placemarks.map { $0.geometry.latitude }).max(),
            let eastPoint = (cluster.placemarks.map { $0.geometry.longitude }).max()
        else {
            return false
        }

        let southWest = YMKPoint(latitude: southPoint, longitude: westPoint)
        let northEast = YMKPoint(latitude: northPoint, longitude: eastPoint)
        let clusterBounds = YMKBoundingBox(southWest: southWest, northEast: northEast)

        let newCameraPosition = rootView.map.cameraPosition(with: YMKGeometry(boundingBox: clusterBounds))
        rootView.map.move(
            with: .init(target: newCameraPosition.target, zoom: newCameraPosition.zoom - 0.8, azimuth: 0, tilt: 0),
            animation: .init(type: .linear, duration: 0.5)
        )
        return true
    }
    
    //MARK: Load data
    private func loadData(force: Bool = false) {
        DatabaseService.shared.getEvents { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let data):
                events = data
                self.rootView.displayLoading(enable: false)
                self.rootView.display(
                    cellData: self.makeEvents(events: data),
                    titleData: .init(title: "Саранск", quantity: data.count),
                    animated: true
                )
                
            case .failure(let error):
                print("Ошибка при получении данных \(error)")
            }
        }
    }
    
    private func moveCamera(to target: YMKPoint, zoom: Float, duration: Float) {
        let position = YMKCameraPosition(target: target, zoom: zoom, azimuth: 0, tilt: 0)
        rootView.map.move(with: position, animation: YMKAnimation(type: .smooth, duration: duration))
    }
    
    @objc
    private func toMenu(sender: UIBarButtonItem) {
        onMenu?()
    }

    @objc
    private func showMap(sender: UIBarButtonItem) {
        if rootView.mapView.isHidden {
            rootView.showMap(with: true)
            navigationItem.searchController = nil
            moveCamera(to: YMKPoint(latitude: 54.1871090, longitude: 45.1836350), zoom: 12, duration: 1)
            addEvents()
        } else {
            rootView.showMap(with: false)
            rootView.placeInfoView.isHidden = true
            congfigurateNavigationBar()
            
        }
    }
}

//MARK: Make data
private extension CatalogVC {
    func makeEvents(events: [Event]) -> [EventCellData] {
        return events.enumerated().map { item in
            let (item, value) = item
            
            return EventCellData(
                address: value.address,
                category: value.category,
                date: value.date,
                desc: value.desc,
                name: value.name,
                urlImage: value.urlImage,
                onSelect: { [weak self] in
                    print("Select \(item) item")
                    
                    self?.onDisplayEvent?(value)
                }
            )
        }
    }
    
    func makeTitle() -> EventTitleData{
        .init(title: "Мероприятия", quantity: 20)
    }
}

//MARK: Configurate nav bar
private extension CatalogVC {
    func congfigurateNavigationBar() {
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.standardAppearance = appearance
        }
        
        let menuButton = UIBarButtonItem(
            image: A.Images.Catalog.menu.image,
            style: .done,
            target: self,
            action: #selector(toMenu(sender:))
        )
        
        let mapButton = UIBarButtonItem(
            image: A.Images.Catalog.mapIcon.image,
            style: .plain,
            target: self,
            action: #selector(showMap(sender:))
        )
        
        mapButton.tintColor = A.Colors.Grayscale.black.color
        menuButton.tintColor = A.Colors.Grayscale.black.color
        navigationItem.rightBarButtonItems = [menuButton, mapButton]
        
        navigationItem.title = "Каталог мероприятий"
        
        navigationItem.searchController = rootView.mapView.isHidden ? rootView.search : nil
        navigationItem.searchController?.searchBar.backgroundColor = .white
        
        navigationItem.hidesSearchBarWhenScrolling = true
        
        
        definesPresentationContext = true
    }

}
