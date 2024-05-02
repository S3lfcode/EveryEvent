import Foundation
import FirebaseFirestore

struct Event {
    let id: String
    let userId: String?
    let address: String?
    let category: String?
    let date: String?
    let desc: String?
    let lat: Double?
    let lng: Double?
    let name: String?
    let urlImage: String?
    
    var representation: [String: Any] {
        var repres = [String: Any]()
        
        repres["id"] = id
        repres["userId"] = userId
        repres["address"] = address
        repres["category"] = category
        repres["date"] = date
        repres["desc"] = desc
        repres["lat"] = lat
        repres["lng"] = lng
        repres["name"] = name
        repres["urlImage"] = urlImage
        
        return repres
    }
    
    init(
        userId: String,
        address: String?,
        category: String?,
        date: String?,
        desc: String?,
        lat: Double?,
        lng: Double?,
        name: String?,
        urlImage: String?
    ) {
        self.id = UUID().uuidString
        self.userId = userId
        self.address = address
        self.category = category
        self.date = date
        self.desc = desc
        self.lat = lat
        self.lng = lng
        self.name = name
        self.urlImage = urlImage
    }
    
    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()
        
        guard let id = data["id"] as? String else { return nil }
        self.id = id
        self.userId = data["userId"] as? String
        self.address = data["address"] as? String
        self.category = data["category"] as? String
        self.date = data["date"] as? String
        self.desc = data["desc"] as? String
        self.lat = data["lat"] as? Double
        self.lng = data["lng"] as? Double
        self.name = data["name"] as? String
        self.urlImage = data["urlImage"] as? String
        
    }
}
