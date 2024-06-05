import Foundation

struct ProfileRequestData {
    let status: String?
    let userID: String?
    let eventID: String?
    let eventOwnerID: String?
    let eventName: String?
    let eventDate: String?
    let eventImage: String?
    let userName: String?
    let userLastName: String?
    let userImage: String?
    
    var onApply: () -> Void
    var onReject: () -> Void
    var onReview: (_ eventId: String?) -> Void
}
