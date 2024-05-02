//
//  TabBarController.swift
//  EveryEvent
//
//  Created by S3lfcode on 15.04.2024.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTabs()
    }
    
    let catalogCoordinator = Assembly().catalogCoordinator()
    
    private func setupTabs() {
        let catalogVC = catalogCoordinator.make()
        let catalog = self.createNav(
            with: "catalog",
            and: A.Images.Menu.events.image,
            vc: catalogCoordinator.make()
        )

//        let myEvents = self.createNav(
//            with: "myEvents",
//            and: A.Images.Menu.events.image,
//            vc: Assembly().eve()
//        )
        let newEvent = self.createNav(
            with: "newEvent",
            and: A.Images.Menu.myEvents.image,
            vc: Assembly().eventCreateCoordinator().make()
        )
//        let chat = self.createNav(
//            with: "chat",
//            and: A.Images.Menu.events.image,
//            vc: Assembly().()
//        )
        let profile = self.createNav(
            with: "profile",
            and: A.Images.Menu.profile.image,
            vc: Assembly().profileCoordinator().make()
        )

        self.setViewControllers([catalog, newEvent, profile], animated: true)
    }
    
    private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        
        //Иконка и название секции меню
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        
        nav.viewControllers.first?.navigationItem.title = title + "Controller"
        
        nav.viewControllers.first?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Button", style: .plain, target: nil, action: nil)
        
        return nav
    }
}
