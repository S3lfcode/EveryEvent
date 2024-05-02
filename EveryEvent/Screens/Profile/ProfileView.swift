import Foundation
import UIKit

protocol ProfileView: UIView {
    var onRefresh: (() -> Void)? { get set }
    var onPresent: ((UIViewController, Bool) -> Void)? { get set }
    
    func display(cellData: [ProfileRequestData])
    func updateProfile(user: DataUser)
}
