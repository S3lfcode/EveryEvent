import Foundation
import FirebaseAuth

class AuthService {
    
    static let shared = AuthService()
    
    private init() {
        
    }
    
    private let auth = Auth.auth()
    
    var currentUser: User? {
        return auth.currentUser
    }
    
    func sighUp(
        email: String,
        passw: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        auth.createUser(withEmail: email, password: passw) { result, error in
            guard let result = result else {
                if let error = error {
                    completion(.failure(error))
                }
                
                print("(AuthService): Неизвестная ошибка регистрации")
                
                return
            }

            UserDefaults.standard.set(email, forKey: "email")
            completion(.success(result.user))
        }
    }
    
    func sighIn(
        email: String,
        passw: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        auth.signIn(withEmail: email, password: passw) { result, error in
            guard let result = result else {
                if let error = error {
                    completion(.failure(error))
                }
                
                print("(AuthService): Неизвестная ошибка входа")
                
                return
            }
            UserDefaults.standard.set(email, forKey: "email")
            completion(.success(result.user))
        }
    }
}
