import FirebaseFirestore

class DatabaseService {
    
    enum Error: Swift.Error {
        case userIsNil
        case docNotFound
        case dataNotFound
        case error(String)
        
        var description: String {
            switch self {
            case .userIsNil:
                return "Пользователь еще не вошел в аккаунт."
            case .docNotFound:
                return "Необходимый документ не найден"
            case .dataNotFound:
                return "Необходимые данные не найдены"
            case .error(let error):
                return error
            }
        }
    }
    
    static let shared = DatabaseService()
    private let db = Firestore.firestore()
    
    private var usersRef: CollectionReference {
        return db.collection("users")
    }
    
    private var eventsRef: CollectionReference {
        return db.collection("events")
    }
    
    private var requestsRef: CollectionReference {
        return db.collection("requests")
    }
    
    private var reviewsRef: CollectionReference {
        return db.collection("reviews")
    }
    
    private init() {
        
    }
    
    func setUser(user: DataUser, completion: @escaping (Result<DataUser, Error>) -> Void) {
        usersRef.document(user.id!).setData(user.representation) { error in
            if let error = error {
                completion(.failure(.error(error.localizedDescription)))
            } else {
                completion(.success(user))
            }
            
        }
    }
    
    func getProfile(completion: @escaping (Result<DataUser, Error>) -> Void) {
        guard let currentUser = AuthService.shared.currentUser else {
            completion(.failure(.userIsNil))
            return
        }
        
        usersRef.document(currentUser.uid).getDocument { docSnap, error in
            guard let docSnap = docSnap else {
                if let error = error {
                    completion(.failure(.error(error.localizedDescription)))
                    return
                }
                completion(.failure(.docNotFound))
                return
            }
            
            guard let doc = docSnap.data() else {
                completion(.failure(.dataNotFound))
                return
            }
            
            let user = DataUser(
                id: doc["id"] as? String,
                name: doc["name"] as? String,
                phone: doc["phone"] as? String,
                email: doc["email"] as? String,
                passw: doc["passw"] as? String
            )
            
            completion(.success(user))
        }
    }
    
    func getDataUser(userId: String, completion: @escaping (Result<DataUser, Error>) -> Void) {
        usersRef.document(userId).getDocument { docSnap, error in
            guard let docSnap = docSnap else {
                if let error = error {
                    completion(.failure(.error(error.localizedDescription)))
                    return
                }
                completion(.failure(.docNotFound))
                return
            }
            
            guard let doc = docSnap.data() else {
                completion(.failure(.dataNotFound))
                return
            }
            
            let user = DataUser(
                id: doc["id"] as? String,
                name: doc["name"] as? String,
                phone: doc["phone"] as? String,
                email: doc["email"] as? String,
                passw: doc["passw"] as? String
            )
            
            completion(.success(user))
        }
    }
    
    func setEvent(event: Event, completion: @escaping (Result<Event, Error>) -> Void) {
        eventsRef.document(event.id).setData(event.representation) { error in
            if let error = error {
                completion(.failure(.error(error.localizedDescription)))
            } else {
                completion(.success(event))
            }
        }
    }
    
    func getEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        eventsRef.getDocuments { qSnap, error in
            guard let qSnap = qSnap else {
                if let error = error {
                    completion(.failure(.error(error.localizedDescription)))
                }
                return
            }
            
            let docs = qSnap.documents
            
            var events = [Event]()
            
            for doc in docs {
                guard let event = Event(doc: doc) else {
                    return
                }
                
                events.append(event)
            }
            
            completion(.success(events))
        }
    }
    
    func setRequest(request: Request, completion: @escaping (Result<Request, Error>) -> Void) {
        requestsRef.document(request.id).setData(request.representation) { error in
            if let error = error {
                completion(.failure(.error(error.localizedDescription)))
            } else {
                completion(.success(request))
            }
        }
    }
    
    func getRequsets(completion: @escaping (Result<[Request], Error>) -> Void) {
        requestsRef.getDocuments { qSnap, error in
            guard let qSnap = qSnap else {
                if let error = error {
                    completion(.failure(.error(error.localizedDescription)))
                }
                return
            }
            
            let docs = qSnap.documents
            
            var requests = [Request]()
            
            for doc in docs {
                guard let request = Request(doc: doc) else {
                    return
                }
                
                requests.append(request)
            }
            
            completion(.success(requests))
        }
    }
    
    func setReview(review: Review, completion: @escaping (Result<Review, Error>) -> Void) {
        reviewsRef.document(review.id).setData(review.representation) { error in
            if let error = error {
                completion(.failure(.error(error.localizedDescription)))
            } else {
                completion(.success(review))
            }
        }
    }
    
    func getReviews(completion: @escaping (Result<[Review], Error>) -> Void) {
        reviewsRef.getDocuments { qSnap, error in
            guard let qSnap = qSnap else {
                if let error = error {
                    completion(.failure(.error(error.localizedDescription)))
                }
                return
            }
            
            let docs = qSnap.documents
            
            var reviews = [Review]()
            
            for doc in docs {
                guard let review = Review(doc: doc) else {
                    return
                }
                
                reviews.append(review)
            }
            
            completion(.success(reviews))
        }
    }
}
