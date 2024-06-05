
//
//import UIKit
//import YandexMapsMobile
//
//public protocol EventAddressView: UIView {
//    var myLocationButton: Button { get }
//    var deliveryButton: Button { get }
//    var collectionManager: CollectionManager { get }
//    var map: YMKMap { get }
//
//    func locationChanged(_ locationChanged: @escaping((Coordinates, Bool) -> Void))
//    func addressChanged(_ addressChanged: @escaping((String?) -> Void))
//    func mapTap(_ mapTapHandler: @escaping () -> Void)
//    func setLocation(coordinates: Coordinates, zoom: Float)
//    func updateAddress(address: String, close: Bool)
//    func currentCoordinates() -> Coordinates
//    func currentAddress() -> String
//    func showLoading()
//    func hideLoading()
//    func showEmptyAddressError()
//    func showNoAddressError()
//    func showEmptySuggestionsState()
//    func hideEmptySuggestionsState()
//}
//
//// MARK: -
//
//public final class EventAddressViewImp: UIView {
//    private let myLocationShadowView = ShadowView(style: .control).ui.forAutoLayout()
//    public let myLocationButton = Button(style: .white(.medium)).ui
//        .image(A.Images.Menu.profile.image)
//        .forAutoLayout()
//    public let myPin = ImageView(image: A.Images.Catalog.mapPoint.image).ui
//        .forAutoLayout()
//    public var deliveryButton: Button {
//        detailedAddressView.deliveryButton
//    }
//    public var heightVisibleMap: CGFloat = 0 {
//        didSet {
//            if heightVisibleMap == .zero {
//                deselectObject(object: selectedShop)
//            }
//
//            let stretchFactor = Float((mapView.bounds.height - heightVisibleMap) / mapView.bounds.height)
//            mapView.mapWindow.focusRect = YMKScreenRect(
//                topLeft: .init(x: 0, y: 0),
//                bottomRight: .init(
//                    x: Float(mapView.mapWindow.width()),
//                    y: stretchFactor * Float(mapView.mapWindow.height())
//                )
//            )
//        }
//    }
//    public var maxHeightInfoView: CGFloat {
//        mapView.bounds.height - 76
//    }
//    public var collectionManager: CollectionManager {
//        detailedAddressView.collectionManager
//    }
//
//    private let mapView = YMKMapView(frame: .zero, vulkanPreferred: false).ui.forAutoLayout()
//    public var map: YMKMap {
//        mapView.mapWindow.map
//    }
//
//    private var detailedAddressView = DetailedAddressView().ui.forAutoLayout()
//
//    private var collection: YMKClusterizedPlacemarkCollection?
//    private var selectedShop: YMKPlacemarkMapObject? {
//        didSet {
//            UIView.animate(withDuration: 0.2) { [unowned self] in
//                myButtonBottomConstraint.constant = selectedShop == nil ? 16 + safeAreaInsets.bottom : 16
//                layoutIfNeeded()
//            }
//        }
//    }
//
//    private var myButtonBottomConstraint: NSLayoutConstraint = .init()
//    private var detailedAddressViewTopConstraint: NSLayoutConstraint = .init()
//
//    private var onLocationChanged: ((Coordinates, Bool) -> Void)?
//    private var onAddressChanged: ((String?) -> Void)?
//    private var onMapTap: (() -> Void)?
//
//    // MARK: Initialization
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configure()
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: Configuration
//
//    private func configure() {
//        backgroundColor = .white
//
//        map.mapType = .vectorMap
//        mapView.mapWindow.map.addCameraListener(with: self)
//        mapView.mapWindow.map.addInputListener(with: self)
//        mapView.mapWindow.map.logo.setAlignmentWith(YMKLogoAlignment(
//            horizontalAlignment: .right,
//            verticalAlignment: YMKLogoVerticalAlignment.top
//        ))
//
//        detailedAddressView.addressField.delegate = self
////        detailedAddressView.addressField.addAction { [unowned self] in
////            textFieldDidChange($0)
////        }
//
//        myLocationShadowView.addSubview(myLocationButton)
//        ui.addSubviews([mapView, myPin, detailedAddressView, myLocationShadowView])
//        myButtonBottomConstraint = detailedAddressView.topAnchor.constraint(
//            equalTo: myLocationShadowView.bottomAnchor,
//            constant: 16
//        )
//        detailedAddressViewTopConstraint = detailedAddressView.topAnchor.constraint(
//            equalTo: safeAreaLayoutGuide.topAnchor,
//            constant: 56
//        )
//
//        let issueBottom = keyboardGuide.topAnchor.constraint(equalTo: detailedAddressView.bottomAnchor)
//        issueBottom.priority(.defaultHigh)
//
//        NSLayoutConstraint.activate([
//            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            mapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
//            trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
//            safeAreaLayoutGuide.bottomAnchor.constraint(
//                equalTo: mapView.bottomAnchor,
//                constant: 155
//            ),
//
//            myPin.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
//            mapView.centerYAnchor.constraint(equalTo: myPin.centerYAnchor, constant: 19),
//
//            myLocationShadowView.widthAnchor.constraint(equalToConstant: 44),
//            myLocationShadowView.heightAnchor.constraint(equalTo: myLocationShadowView.widthAnchor),
//            mapView.trailingAnchor.constraint(equalTo: myLocationShadowView.trailingAnchor, constant: 16),
//            myButtonBottomConstraint,
//
//            detailedAddressView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            trailingAnchor.constraint(equalTo: detailedAddressView.trailingAnchor),
//            issueBottom
//        ])
//
////        registerDefaultStates()
//    }
//
//    // MARK: Private
//
//    private func moveCamera(to target: YMKPoint, zoom: Float, duration: Float) {
//        let position = YMKCameraPosition(target: target, zoom: zoom, azimuth: 0, tilt: 0)
//        map.move(with: position, animation: YMKAnimation(type: .smooth, duration: duration))
//    }
//
//    private func deselectObject(object: YMKPlacemarkMapObject?) {
//        guard let object, object.userData != nil else {
//            return
//        }
//        selectedShop = nil
//    }
//
//    @objc
//    private func textFieldDidChange(_ textField: UITextField) {
//        onAddressChanged?(textField.text)
//    }
//}
//
//// MARK: - DeliveryAddressRootView
//
//extension EventAddressViewImp: EventAddressView {
//    public func locationChanged(_ locationChanged: @escaping((Coordinates, Bool) -> Void)) {
//        onLocationChanged = locationChanged
//    }
//
//    public func addressChanged(_ addressChanged: @escaping((String?) -> Void)) {
//        onAddressChanged = addressChanged
//    }
//
//    public func mapTap(_ mapTapHandler: @escaping () -> Void) {
//        onMapTap = mapTapHandler
//    }
//
//    public func setLocation(coordinates: Coordinates, zoom: Float) {
//        moveCamera(
//            to: YMKPoint(latitude: coordinates.latitude, longitude: coordinates.longitude),
//            zoom: zoom,
//            duration: 0
//        )
//    }
//
//    public func updateAddress(address: String, close: Bool) {
//        detailedAddressView.addressField.text = address
//        if close {
//            detailedAddressView.addressField.resignFirstResponder()
//        } else {
//            onAddressChanged?(address)
//        }
//    }
//
//    public func currentCoordinates() -> Coordinates {
//        Coordinates(
//            longitude: map.cameraPosition.target.longitude,
//            latitude: map.cameraPosition.target.latitude
//        )
//    }
//
//    public func currentAddress() -> String {
//        detailedAddressView.addressField.text ?? ""
//    }
//
//    public func showLoading() {
//        detailedAddressView.addressField.errorMessage = nil
//        detailedAddressView.deliveryButton.isLoading = true
//    }
//
//    public func hideLoading() {
//        detailedAddressView.deliveryButton.isLoading = false
//    }
//
//    public func showEmptyAddressError() {
//        detailedAddressView.addressField.errorMessage = "Поле адреса должно быть заполнено"
//    }
//
//    public func showNoAddressError() {
//        detailedAddressView.addressField.text = nil
//        detailedAddressView.addressField.errorMessage = "Адрес не найден"
//    }
//
//    public func showEmptySuggestionsState() {
//        detailedAddressView.collectionView.isHidden = true
//        detailedAddressView.emptyView.isHidden = false
//    }
//
//    public func hideEmptySuggestionsState() {
//        detailedAddressView.collectionView.isHidden = false
//        detailedAddressView.emptyView.isHidden = true
//    }
//}
//
//// MARK: - YMKMapCameraListener
//
//extension EventAddressViewImp: YMKMapCameraListener {
//    public func onCameraPositionChanged(
//        with map: YMKMap,
//        cameraPosition: YMKCameraPosition,
//        cameraUpdateReason: YMKCameraUpdateReason,
//        finished: Bool
//    ) {
//        onLocationChanged?(
//            Coordinates(
//                longitude: cameraPosition.target.longitude,
//                latitude: cameraPosition.target.latitude
//            ),
//            finished
//        )
//    }
//}
//
//// MARK: - YMKMapInputListener
//
//extension EventAddressViewImp: YMKMapInputListener {
//    // swiftlint:disable:next empty_method
//    public func onMapLongTap(with map: YMKMap, point: YMKPoint) {}
//
//    public func onMapTap(with map: YMKMap, point: YMKPoint) {
//        if detailedAddressView.addressField.isFirstResponder {
//            detailedAddressView.addressField.resignFirstResponder()
//            onMapTap?()
//        } else {
//            moveCamera(to: point, zoom: map.cameraPosition.zoom, duration: .zero)
//            onLocationChanged?(
//                Coordinates(
//                    longitude: point.longitude,
//                    latitude: point.latitude
//                ),
//                true
//            )
//        }
//    }
//}
//
//// MARK: - UITextFieldDelegate
//
//extension EventAddressViewImp: UITextFieldDelegate {
//    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        map.setInteractionEnabled(false)
//
//        DispatchQueue.main.async {
//            textField.selectedTextRange = textField.textRange(
//                from: textField.endOfDocument,
//                to: textField.endOfDocument
//            )
//        }
//
//        UIView.animate(withDuration: 0.25) {
//            self.detailedAddressViewTopConstraint.isActive = true
//            self.myLocationShadowView.alpha = 0
//            self.detailedAddressView.detailsView.alpha = 0
//            self.detailedAddressView.collectionView.alpha = 1
//            self.detailedAddressView.emptyView.alpha = 1
//            self.layoutIfNeeded()
//        }
//        onAddressChanged?(textField.text)
//        return true
//    }
//
//    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        map.setInteractionEnabled(true)
//
//        UIView.animate(withDuration: 0.25) {
//            self.detailedAddressViewTopConstraint.isActive = false
//            self.myLocationShadowView.alpha = 1
//            self.detailedAddressView.detailsView.alpha = 1
//            self.detailedAddressView.collectionView.alpha = 0
//            self.detailedAddressView.emptyView.alpha = 0
//            self.layoutIfNeeded()
//        }
//        return true
//    }
//}
////
////extension YMKMap {
////    func setInteractionEnabled(_ isEnabled: Bool) {
////        isScrollGesturesEnabled = isEnabled
////        isTiltGesturesEnabled = isEnabled
////        isRotateGesturesEnabled = isEnabled
////        isZoomGesturesEnabled = isEnabled
////    }
////}
