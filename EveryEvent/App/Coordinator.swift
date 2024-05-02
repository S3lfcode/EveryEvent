import UIKit

class Coordinator<
    AssemblyType: Assembly,
    NavigationControllerType: UIViewController,
    ContextType: Any
>: RootableCoordinator {
    
    init(assembly: AssemblyType) {
        self.assembly = assembly
        self.context = nil
    }
    
    init(assembly: AssemblyType, context: ContextType) {
        self.assembly = assembly
        self.context = context
    }
    
    let assembly: AssemblyType
    let context: ContextType?
    
    weak var parentCoordinator: BaseCoordinator?
    var childs: [BaseCoordinator] = []
    
    var root: NavigationControllerType?
    
    
    func make() -> UIViewController? {
        return nil
    }

}
