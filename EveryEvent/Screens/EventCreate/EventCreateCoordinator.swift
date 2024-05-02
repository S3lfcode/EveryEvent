import UIKit

final class EventCreateCoordinator: Coordinator<Assembly, UINavigationController, Void> {
    
    override init(assembly: Assembly) {
        super.init(assembly: assembly)
        
    }
    
    override func make() -> UIViewController {
        let controller = assembly.eventCreateVC()
        
        controller.onCatalog = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.start(
                coordinator: self.assembly.catalogCoordinator(),
                on: self.root,
                animated: true
            )
        }
        
        return controller
    }
}
