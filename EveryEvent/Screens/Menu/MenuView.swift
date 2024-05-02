import UIKit

protocol MenuView: UIView {
    var onProfile: (() -> Void)? { get set }
    var onCatalog: (() -> Void)? { get set }
    var onMyEvent: (() -> Void)? { get set }
    var onCreateEvent: (() -> Void)? { get set }
    var onSettings: (() -> Void)? { get set }
    var onLogOut: (() -> Void)? { get set }
}
