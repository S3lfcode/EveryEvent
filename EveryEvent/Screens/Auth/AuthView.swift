import UIKit

protocol AuthView: UIView {
    var onAuthAction: ((_ email: String, _ passw: String) -> Void)? { get set }
    var onRegAction: (() -> Void)? { get set }
}
