import UIKit

class EventCoordinator: Coordinator<Assembly, UINavigationController, EventContext> {
    
    override init(assembly: Assembly, context: EventContext) {
        super.init(assembly: assembly, context: context)
    }
    
    override func make() -> UIViewController? {
        guard let context = context else {
            return nil
        }
        
        let controller = assembly.eventVC(
            event: context.event
        )
        
        controller.onCatalog = { [weak self] in
            self?.backTo(coordinator: self?.assembly.catalogCoordinator(), animated: true)
        }
        
        return controller
    }
}
