import UIKit
import YandexMapsMobile

protocol EventCreateView: UIView {
    var onCreateAction: ((_ name: String, _ url: String, _ category: String, _ address: String, _ date: String, _ desc: String) -> Void)? { get set }
    var myLocationButton: Button { get }
//    var deliveryButton: Button { get }
    var collectionManager: CollectionManager { get }
    var map: YMKMap { get }
    var onPresent: ((UIViewController, Bool) -> Void)? { get set }

    func locationChanged(_ locationChanged: @escaping((Coordinates, Bool) -> Void))
    func addressChanged(_ addressChanged: @escaping((String?) -> Void))
    func mapTap(_ mapTapHandler: @escaping () -> Void)
    func setLocation(coordinates: Coordinates, zoom: Float)
    func updateAddress(address: String, close: Bool)
    func currentCoordinates() -> Coordinates
    func currentAddress() -> String
//    func showLoading()
//    func hideLoading()
    func showEmptyAddressError()
    func showNoAddressError()
    func showEmptySuggestionsState()
    func hideEmptySuggestionsState()
}
