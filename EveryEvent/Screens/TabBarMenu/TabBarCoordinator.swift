//
//  TabBarCoordinator.swift
//  EveryEvent
//
//  Created by S3lfcode on 18.04.2024.
//

import Foundation

import UIKit
import Firebase

final class TabBarCoordinator: Coordinator<Assembly, UINavigationController, String?> {
    
    override init(assembly: Assembly) {
        super.init(assembly: assembly)
        
        let catalogCoordinator = assembly.catalogCoordinator()
        childs.append(catalogCoordinator)
    }
    
    override func make() -> UIViewController? {
        let controller = assembly.tabBarVC()
        
        //MARK: On profile
//        controller.onProfile = { [weak self] in
//            guard let self = self else {
//                return
//            }
//            
//            self.backTo(coordinator: self.assembly.profileCoordinator(), animated: true)
//        }
    
        return controller
    }
    
}
