import Foundation
import UIKit

protocol ConversationsView: UIView {
    var onPresent: ((UIViewController, Bool) -> Void)? { get set }
}
