import UIKit

protocol EventView: UIView {
    var onRequest: (() -> Void)? { get set }
    var onLike: (() -> Void)? { get set }
    
    func display(cellData: [ReviewCellData])
    func updateInfo(event: Event, requests: [Request])
    func updateOwnerInfo(owner: DataUser)
    func displayLikeButton(show: Bool, enable: Bool)
}
