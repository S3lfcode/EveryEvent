import Foundation
import UIKit

protocol ReviewView: UIView {
    var onProfile: (() -> Void)? { get set }
    var onReviewCreate: ((_ reviewText: String) -> Void)? { get set }
    
    func update(eventName: String) 
}
