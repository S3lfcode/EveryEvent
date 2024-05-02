import Foundation

final class ReviewVC<View: ReviewView>: BaseViewController<View> {
    
    init(eventId: String?) {
        self.eventId = eventId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let eventId: String?
    
    //MARK: Properties
    var onProfile: (() -> Void)?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        navigationController?.navigationBar.topItem?.title = ""
        
        updateInfo()
        
        rootView.onProfile = onProfile
        
        createReview()
    }
    
    private func updateInfo() {
        DatabaseService.shared.getEvents { [weak self] result in
            switch result {
            case .success(let events):
                
                let eventName = events.filter({ $0.id == self?.eventId }).first?.name
                
                guard let name = eventName else {
                    return
                }
                
                self?.rootView.update(eventName: name)
                
            case .failure(_):
                print("Ошибка получения эвентов для Review")
            }
        }
    }
    
    private func createReview() {
        rootView.onReviewCreate = { [weak self] text in
            guard let self = self else {
                return
            }
            
            DatabaseService.shared.getProfile { result in
                switch result {
                case .success(let user):
                    let review = Review(
                        userId: AuthService.shared.currentUser?.uid,
                        eventId: self.eventId,
                        name: user.name,
                        review: text
                    )
                    
                    DatabaseService.shared.setReview(review: review) { result in
                        switch result {
                        case .success(_):
                            print("Отзыв создан успешно")
                            self.onProfile?()
                        case .failure(_):
                            print("Возникла ошибка при создании отзыва")
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
 
}
