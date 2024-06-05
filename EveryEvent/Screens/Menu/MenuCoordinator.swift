import UIKit
import Firebase

final class MenuCoordinator: Coordinator<Assembly, UINavigationController, Void> {
    
    override init(assembly: Assembly) {
        super.init(assembly: assembly)
    }
    
    override func make() -> UIViewController? {
        let controller = assembly.menuVC()
        
        //MARK: On catalog screen
        controller.onCatalog = { [weak self] in
            self?.backTo(coordinator: self?.assembly.catalogCoordinator(), animated: true)
        }
        
        //MARK: On create evet screen
        controller.onCreateEvent = { [weak self] in
            guard let self = self else {
                return
            }
            
            let coordinator = self.assembly.eventCreateCoordinator()
            
            self.start(
                coordinator: coordinator,
                on: self.root,
                animated: true
            )
        }
        
        //MARK: On logOut
        controller.onLogOut = {
            do {
                try Auth.auth().signOut()
            } catch {
                print("MenuCoordinator(onLogOut): Ошибка: \(error)")
            }
        }
        
        //MARK: On profile
        controller.onProfile = { [weak self] in
            guard let self = self else {
                return
            }
            
            start(
                coordinator: self.assembly.profileCoordinator(),
                on: self.root,
                animated: true
            )
        }
        
        controller.onConversations = { [weak self] in
            guard let self = self else {
                return
            }
            
            start(
                coordinator: self.assembly.conversationsCoordinator(),
                on: self.root,
                animated: true
            )
        }
        
        
        return controller
    }
    
}
