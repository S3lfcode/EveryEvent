import UIKit
import Firebase

final class AppCoordinator: BaseCoordinator {
    
    init(assembly: Assembly) {
        self.assembly = assembly
    }

    private let assembly: Assembly
    
    weak var parentCoordinator: BaseCoordinator?
    var childs: [BaseCoordinator] = []
    
    
    func make() -> UIViewController? {
        let navigationController = assembly.navigationController
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else {
                return
            }
            
            guard user != nil else {
                navigationController.viewControllers.removeAll()
                
                self.start(
                    coordinator: self.assembly.regCoordinator(),
                    on: navigationController,
                    animated: false
                )
                
                return
            }
            
            start(
                coordinator: self.assembly.catalogCoordinator(),
                on: navigationController,
                animated: false
            )
        }
        
        return navigationController
    }
    

    
}
