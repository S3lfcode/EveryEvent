import FirebaseFirestore

struct Request {
    var id: String = UUID().uuidString
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
    
    var representation: [String: Any] {
        var repres = [String: Any]()
        
        repres["id"] = id
        repres["status"] = status
        repres["userID"] = userID
        repres["eventID"] = eventID
        repres["eventOwnerID"] = eventOwnerID
        repres["eventName"] = eventName
        repres["eventDate"] = eventDate
        repres["eventImage"] = eventImage
        repres["userName"] = userName
        repres["userLastName"] = userLastName
        repres["userImage"] = userImage
        
        return repres
    }
    
    init(id: String, status: String?, userID: String?, eventID: String?, eventOwnerID: String?, eventName: String?, eventDate: String?, eventImage: String?, userName: String?, userLastName: String?, userImage: String?) {
        self.id = id
        self.status = status
        self.userID = userID
        self.eventID = eventID
        self.eventOwnerID = eventOwnerID
        self.eventName = eventName
        self.eventDate = eventDate
        self.eventImage = eventImage
        self.userName = userName
        self.userLastName = userLastName
        self.userImage = userImage
    }
    
    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()
        
        guard let id = data["id"] as? String else { return nil }
        self.id = id
        self.status = data["status"] as? String
        self.userID = data["userID"] as? String
        self.eventID = data["eventID"] as? String
        self.eventOwnerID = data["eventOwnerID"] as? String
        self.eventName = data["eventName"] as? String
        self.eventDate = data["eventDate"] as? String
        self.eventImage = data["eventImage"] as? String
        self.userName = data["userName"] as? String
        self.userLastName = data["userLastName"] as? String
        self.userImage = data["userImage"] as? String
    }
}
