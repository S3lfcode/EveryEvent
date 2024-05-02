import UIKit

final class CatalogCoordinator: Coordinator<Assembly, UINavigationController, Void> {
    
    override init(assembly: Assembly) {
        super.init(assembly: assembly)
    }
    
    override func make() -> UIViewController {
        let controller = assembly.catalogVC()
        
        controller.onDisplayEvent = { [weak self] value in
            guard let self = self else {
                return
            }
            
            let coordinator = self.assembly.eventCoordinator(
                context: .init(event: value)
            )
            
            self.start(
                coordinator: coordinator,
                on: self.root,
                animated: true
            )
        }
        
        controller.onMenu = { [weak self] in
            guard let self = self else {
                return
            }
            
            let coordinator = self.assembly.menuCoordinator()
            
            self.start(
                coordinator: coordinator,
                on: self.root,
                animated: true
            )
        }
        
        return controller
    }
}
