import Foundation

final class MenuVC<View: MenuView>: BaseViewController<View> {
    
    //MARK: Properties
    var onProfile: (() -> Void)?
    var onCatalog: (() -> Void)?
    var onMyEvent: (() -> Void)?
    var onCreateEvent: (() -> Void)?
    var onSettings: (() -> Void)?
    var onLogOut: (() -> Void)?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        rootView.onProfile = onProfile
        rootView.onCatalog = onCatalog
        rootView.onMyEvent = onMyEvent
        rootView.onCreateEvent = onCreateEvent
        rootView.onSettings = onSettings
        rootView.onLogOut = onLogOut
    }
 
}