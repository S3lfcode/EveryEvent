import UIKit

protocol BaseCoordinator: AnyObject {
    var parentCoordinator: BaseCoordinator? { get set }
    var childs: [BaseCoordinator] { get set }
    
    func make() -> UIViewController?
}

extension BaseCoordinator {
    func addChild(coordinator: BaseCoordinator) {
        coordinator.parentCoordinator = self
        childs.append(coordinator)
    }
}

protocol RootableCoordinator: BaseCoordinator, AnyRootableCoordinator {
    associatedtype Root
    
    var root: Root? { get set }
}
//-----
protocol AnyRootableCoordinator {
    var anyRoot: Any? { get }
}

extension RootableCoordinator {
    var anyRoot: Any? {
        root
    }
}
//------
extension BaseCoordinator {
    func start<Coordinate: RootableCoordinator>(
        coordinator: Coordinate?,
        on navigationController: UINavigationController?,
        animated: Bool
    ) where Coordinate.Root == UINavigationController {
        guard
            let coordinator = coordinator,
            let navigationController = navigationController,
            let controller = coordinator.make()
        else {
            return
        }
        
        addChild(coordinator: coordinator)
        
        coordinator.root = navigationController
        
        let animated = !navigationController.viewControllers.isEmpty && animated
        navigationController.pushViewController(controller, animated: animated)
    }
    
}

extension RootableCoordinator where Root == UINavigationController {
    func backTo(coordinator: BaseCoordinator?, animated: Bool) {
        guard
            let coordinator = coordinator,
            let root = root
        else {
            return
        }

        let depth = coordinator.depth() {
            ($0 as? AnyRootableCoordinator)?.anyRoot is UINavigationController
        }
        let newStack = root.viewControllers.prefix(max(root.viewControllers.count - depth, 1))
        
        root.setViewControllers(Array(newStack), animated: animated)
    }
}

extension BaseCoordinator {
    func depth(where closure: (BaseCoordinator) -> Bool) -> Int {

        let maxDepth = childs
            .filter(closure)
            .compactMap{ $0.depth(where: closure) }
            .max(by: >) ?? 0

        return maxDepth + 1
    }
}

extension BaseCoordinator {
    
    func setContent<ViewController: ContainerViewController> (
        coordinator: BaseCoordinator?,
        on containerController: ViewController,
        containerId: ViewController.View.ContainerID
    ) {
        guard
            let coordinator = coordinator,
            let controller = coordinator.make()
        else {
            return
        }
        controller.willMove(toParent: containerController)
        containerController.addChild(controller)
        controller.didMove(toParent: containerController)
        
        addChild(coordinator: coordinator)
        containerController.hostView.addSubview(view: controller.view, by: containerId)
    }
    
    func removeContent<ViewController: ContainerViewController> (
        coordinator: BaseCoordinator?,
        on containerController: ViewController,
        containerId: ViewController.View.ContainerID
    ) {
        guard
            let coordinator = coordinator,
            let controller = coordinator.make()
        else {
            return
        }
        controller.willMove(toParent: nil)
        controller.removeFromParent()
        controller.didMove(toParent: nil)

        containerController.hostView.removeSubview(view: controller.view, by: containerId)
    }
}

protocol ContainerViewController: UIViewController  {
    associatedtype View: ContainerView
    
    var hostView: View { get }
}

protocol ContainerView {
    associatedtype ContainerID
    
    func addSubview(view: UIView, by id: ContainerID)
    
    func removeSubview(view: UIView, by id: ContainerID)
}
