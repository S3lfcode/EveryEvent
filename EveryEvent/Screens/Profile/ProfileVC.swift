import Foundation
import UIKit

final class ProfileVC<View: ProfileView>: BaseViewController<View>, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    var onReview: ((_ eventId: String?) -> Void)?
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.title = ""
        updateUserInfo()
        
        rootView.onRefresh = { [weak self] in
            self?.loadData()
            return
        }
        
        rootView.onPresent = { [weak self] viewController, animated in
            self?.present(viewController, animated: animated)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    private func updateUserInfo() {
        DatabaseService.shared.getProfile { [weak self] result in
            switch result {
            case .success(let user):
                self?.rootView.updateProfile(user: user)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //MARK: Load data
    private func loadData(force: Bool = false) {
        DatabaseService.shared.getRequsets { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let data):
                self.rootView.display(
                    cellData: self.makeRequests(events: data)
                )
            case .failure(let error):
                print("Ошибка при получении данных \(error)")
            }
        }
    }

}

//MARK: Make data
private extension ProfileVC {
    func makeRequests(events: [Request]) -> [ProfileRequestData] {
        return events.enumerated().map { [weak self] item in
            let (_, value) = item
            
            return ProfileRequestData(
                status: value.status,
                userID: value.userID,
                eventID: value.eventID,
                eventOwnerID: value.eventOwnerID,
                eventName: value.eventName,
                eventDate: value.eventDate,
                eventImage: value.eventImage,
                userName: value.userName,
                userLastName: value.userLastName,
                userImage: value.userImage,
                onApply: { [weak self] in
                    self?.changeStatus(status: "Подтверждена", currentRequest: value)
                    self?.loadData()
                },
                onReject: { [weak self] in
                    self?.changeStatus(status: "Отклонена", currentRequest: value)
                    self?.loadData()
                },
                onReview: { [weak self] id in
                    self?.onReview?(id)
                }
            )
        }
    }
    
    private func changeStatus(status text: String?, currentRequest: Request) {
        let request = Request(
            id: currentRequest.id,
            status: text,
            userID: currentRequest.userID,
            eventID: currentRequest.eventID,
            eventOwnerID: currentRequest.eventOwnerID,
            eventName: currentRequest.eventName,
            eventDate: currentRequest.eventDate,
            eventImage: currentRequest.eventImage,
            userName: currentRequest.userName,
            userLastName: currentRequest.userLastName,
            userImage: currentRequest.userImage
        )

        DatabaseService.shared.setRequest(request: request) { result in
            switch result {
            case .success(let request):
                print("\(String(describing: text)) заявка пользователя \(String(describing: request.userName)) на мероприятие \(String(describing: request.eventName))")
            case .failure(let error):
                print("Возникла ошибка: \(error)")
            }
        }
    }
}
