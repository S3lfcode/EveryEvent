import Foundation
import Firebase

final class RegVC<View: RegView>: BaseViewController<View> {
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        regUser()
        
        rootView.onLoginAction = onAuth
    }
    
    private func regUser() {
        rootView.onRegAction = { name, phone, email, passw in
            AuthService.shared.sighUp(email: email, passw: passw) { result in
                switch result {
                case .success(let user):
                    print("Пользователь: \(user) зарегистрирован")
                    
                    let dataUser = DataUser(
                        id: user.uid,
                        name: name,
                        phone: phone,
                        email: email,
                        passw: passw
                    )
                    
                    DatabaseService.shared.setUser(user: dataUser) { result in
                        switch result {
                        case .success(let dataUser):
                            print("Пользователь успешно записан в базу данных \(dataUser)")
                        case .failure(let error):
                            print("Возникла ошибка при записи пользователя в базу данных \(error)")
                        }
                    }
                case .failure(let error):
                    print("Ошибка регистрации \(error.localizedDescription)")
                }
            }
        }
    }
    
    //MARK: Properties
    var onAuth: (() -> Void)?
}
