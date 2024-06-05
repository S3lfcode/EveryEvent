import Foundation

struct EventCellData {
    let address: String?
    let category: String?
    let date: String?
    let desc: String?
    let name: String?
    let urlImage: String?
    let promotionCount: Int
    
    var onSelect: () -> Void
}
