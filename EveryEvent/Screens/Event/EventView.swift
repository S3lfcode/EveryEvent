import UIKit

protocol EventView: UIView {
    var onRequest: (() -> Void)? { get set }
    
    func display(cellData: [ReviewCellData])
    func updateInfo(event: Event, requests: [Request])
    func updateOwnerInfo(owner: DataUser)
}
