import Foundation

final class AuthVC<View: AuthView>: BaseViewController<View> {
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        rootView.onRegAction = onReg
        
        authUser()
    }
    
    //MARK: Properties
    var onReg: (() -> Void)?
    
    private func authUser() {
        rootView.onAuthAction = { email, passw in
            AuthService.shared.sighIn(
                email: email,
                passw: passw
            ) { result in
                switch result {
                case .success(let user):
                    print("Пользователь: \(user) вошел в аккаунт")
                case .failure(let error):
                    print("Ошибка входа \(error.localizedDescription)")
                }
            }
        }
    }
}
