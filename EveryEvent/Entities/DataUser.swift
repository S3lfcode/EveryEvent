import Foundation

struct DataUser: Identifiable {
    let id: String?
    let name: String?
    let lastName: String?
    let email: String?
    let passw: String?
    
    var representation: [String: Any] {
        var repres = [String: Any]()
        
        repres["id"] = id
        repres["name"] = name
        repres["lastName"] = lastName
        repres["email"] = email
        repres["passw"] = passw
        
        return repres
    }

}

extension DataUser {
    var safeEmail: String {
        guard let email else {
            return ""
        }
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFilename: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
