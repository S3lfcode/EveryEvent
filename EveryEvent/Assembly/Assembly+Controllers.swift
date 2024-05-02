import Foundation
import UIKit

//MARK: Navigation
extension Assembly {
    
    var navigationController: UINavigationController {
        let controller = UINavigationController()
         
        return controller
    }
    
}

//MARK: Screens
extension Assembly {
    
    func regVC() -> RegVC<RegViewImp> {
        .init()
    }
    
    func authVC() -> AuthVC<AuthViewImp> {
        .init()
    }
    
    func catalogVC() -> CatalogVC<CatalogViewImp> {
        .init()
    }
    
    func eventVC(event: Event) -> EventVC<EventViewImp> {
        .init(event: event)
    }
    
    func menuVC() -> MenuVC<MenuViewImp> {
        .init()
    }
    
    func eventCreateVC() -> EventCreateVC<EventCreateViewImp> {
        .init()
    }
    
    func profileVC() -> ProfileVC<ProfileViewImp> {
        .init()
    }
    
    func reviewVC(eventId: String?) -> ReviewVC<ReviewViewImp> {
        .init(eventId: eventId)
    }
    
    func tabBarVC() -> TabBarController {
        .init()
    }
}
