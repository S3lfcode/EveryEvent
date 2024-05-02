import UIKit
import YandexMapsMobile

protocol CatalogView: UIView {
    var search: UISearchController { get }
    var onRefresh: (() -> Void)? { get set }
    var willDisplayProduct: ((_ item: Int) -> Void)? { get set }
    var map: YMKMap { get }
    var mapView: YMKMapView { get }
    var placeInfoView: PlaceInfoView { get }
    
    func didSelectPlacemark(isNil: Bool)
    
    func display(
        cellData: [EventCellData],
        titleData: EventTitleData,
        animated: Bool
    )
    func displayLoading(enable: Bool)
    
    func showMap(with show: Bool)
}
