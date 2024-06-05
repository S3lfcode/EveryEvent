import Foundation
import UIKit

final class ConversationsVC<View: ConversationsView>: BaseViewController<View> {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(didTapComposeButton)
        )
        
        rootView.onPresent = { [weak self] viewController, animated in
            self?.navigationController?.pushViewController(viewController, animated: animated)
        }
    }
    
    @objc private func didTapComposeButton() {
        let vc = NewChatViewController()
        vc.completion = { [weak self] result in
            self?.createNewConversation(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Активные обсуждения"
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Properties
//    var onProfile: (() -> Void)?
    
    //MARK: Lifecycle
//    override func viewDidLoad() {
//        navigationController?.navigationBar.topItem?.title = ""
//        
//        updateInfo()
//        
//        rootView.onProfile = onProfile
//        
//        createReview()
//    }
//    
//    private func updateInfo() {
//        DatabaseService.shared.getEvents { [weak self] result in
//            switch result {
//            case .success(let events):
//                
//                let eventName = events.filter({ $0.id == self?.eventId }).first?.name
//                
//                guard let name = eventName else {
//                    return
//                }
//                
//                self?.rootView.update(eventName: name)
//                
//            case .failure(_):
//                print("Ошибка получения эвентов для Review")
//            }
//        }
//    }
//    
//    private func createReview() {
//        rootView.onReviewCreate = { [weak self] text in
//            guard let self = self else {
//                return
//            }
//            
//            DatabaseService.shared.getProfile { result in
//                switch result {
//                case .success(let user):
//                    let review = Review(
//                        userId: AuthService.shared.currentUser?.uid,
//                        eventId: self.eventId,
//                        name: user.name,
//                        review: text
//                    )
//                    
//                    DatabaseService.shared.setReview(review: review) { result in
//                        switch result {
//                        case .success(_):
//                            print("Отзыв создан успешно")
//                            self.onProfile?()
//                        case .failure(_):
//                            print("Возникла ошибка при создании отзыва")
//                        }
//                    }
//                case .failure(let error):
//                    print(error)
//                }
//            }
//        }
//    }
 
}
