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
        rootView.onRegAction = { name, lastName, email, passw in
            AuthService.shared.sighUp(email: email, passw: passw) { result in
                switch result {
                case .success(let user):
                    print("Пользователь: \(user) зарегистрирован")
                    
                    let dataUser = DataUser(
                        id: user.uid,
                        name: name,
                        lastName: lastName,
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
                    
                    let chatAppUser = ChatAppUser(
                        firstName: name,
                        lastName: lastName,
                        emailAddress: email,
                        password: passw
                    )

                    UserDefaults.standard.set("\(name) \(lastName)", forKey: "name")

                    DatabaseManager.shared.insertUser(with: chatAppUser) { result in
                        //TODO: something with result
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
