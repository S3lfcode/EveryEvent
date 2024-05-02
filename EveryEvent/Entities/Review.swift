import Foundation
import FirebaseFirestore

struct Review {
    let id: String
    let userId: String?
    let eventId: String?
    let name: String?
    let review: String?
    
    var representation: [String: Any] {
        var repres = [String: Any]()
        
        repres["id"] = id
        repres["userId"] = userId
        repres["eventId"] = eventId
        repres["name"] = name
        repres["review"] = review
        
        return repres
    }
    
    init(
        userId: String?,
        eventId: String?,
        name: String?,
        review: String?
    ) {
        self.id = UUID().uuidString
        self.userId = userId
        self.eventId = eventId
        self.name = name
        self.review = review
    }
    
    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()
        
        guard let id = data["id"] as? String else { return nil }
        self.id = id
        self.userId = data["userId"] as? String
        self.eventId = data["eventId"] as? String
        self.name = data["name"] as? String
        self.review = data["review"] as? String
    }
}
