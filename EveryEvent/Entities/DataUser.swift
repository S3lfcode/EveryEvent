import Foundation

struct DataUser: Identifiable {
    let id: String?
    let name: String?
    let phone: String?
    let email: String?
    let passw: String?
    
    var representation: [String: Any] {
        var repres = [String: Any]()
        
        repres["id"] = id
        repres["name"] = name
        repres["phone"] = phone
        repres["email"] = email
        repres["passw"] = passw
        
        return repres
    }

}
