import UIKit

protocol RegView: UIView {
    var onRegAction: ((_ name: String, _ lastName: String, _ email: String, _ passw: String) -> Void)? { get set }
    var onLoginAction: (() -> Void)? { get set }
    
    func showError(text: String, _ show: Bool)
}
