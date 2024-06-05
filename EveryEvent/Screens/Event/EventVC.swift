import Foundation
import Firebase

class EventVC<View: EventView>: BaseViewController<View> {
    
    //MARK: Initialization
    init(event: Event) {
        self.event = event
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    private var event: Event
    private var user: DataUser?
    var onCatalog: (() -> Void)?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        navigationController?.navigationBar.topItem?.title = ""
        
        updateInfoPage()
        
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    private func updateInfoPage() {
        guard let userId = event.userId else {
            return
        }
        
        DatabaseService.shared.getProfile { [weak self] result in
            if case .success(let user) = result {
                self?.rootView.displayLikeButton(
                    show: user.id != userId,
                    enable: true
                )
            }
        }
        
        DatabaseService.shared.getDataUser(userId: userId) { [weak self] result in
            switch result {
            case .success(let user):
                self?.rootView.updateOwnerInfo(owner: user)
            case .failure(let error):
                print(error)
            }
        }
        
        DatabaseService.shared.getRequsets { [weak self] result in
            guard let event = self?.event else {
                return
            }
            
            switch result {
            case .success(let requests):
                self?.rootView.updateInfo(event: event, requests: requests)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadData() {
        DatabaseService.shared.getReviews { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let reviews):
                let currentEventReviews = reviews.filter { $0.eventId == self.event.id}
                
                self.rootView.display(cellData: self.makeReviews(reviews: currentEventReviews))
                
            case .failure(_):
                print("Возникла ошибка при получении отзывов (EventVC)")
            }
        }
    }
    
    private func makeReviews(reviews: [Review]) -> [ReviewCellData] {
        return reviews.enumerated().map { item in
            let (_, value) = item
            
            return ReviewCellData(name: value.name, review: value.review)
        }
    }
    
    //MARK: Sending an application for participation in the event
    private func configure() {
        rootView.onLike = { [weak self] in
            guard let self else { return }
            let currentCount = self.event.promotionCount ?? 0
            
            self.event.promotionCount = currentCount + 1
            DatabaseService.shared.setEvent(event: self.event) { result in
                if case .success(let event) = result {
                    print("Голос за мероприятие засчитан. Текущих голосов на мероприятие \(event.name): \(event.promotionCount)")
                    self.rootView.displayLikeButton(show: true, enable: false)
                }
            }
        }
        
        rootView.onRequest = {
            DatabaseService.shared.getProfile { result in
                DatabaseService.shared.getProfile { [weak self] result in
                    switch result {
                    case .success(let user):
                        guard let event = self?.event else {
                            return
                        }
                        let safeEmail = DatabaseService.shared.getSafeEmail()
                        let filename = safeEmail + "_profile_picture.png"
                        let path = "images/" + filename

                        var imageURL = ""
                        StorageService.shared.downloadURL(for: path) { result in
                            if case .success(let url) = result {
                                imageURL = url.absoluteString
                            }
                        }
                        
                        let request = Request(
                            id: UUID().uuidString,
                            status: "Сформирована",
                            userID: user.id,
                            eventID: event.id,
                            eventOwnerID: event.userId,
                            eventName: event.name,
                            eventDate: event.date,
                            eventImage: event.urlImage,
                            userName: user.name,
                            userLastName: user.lastName,
                            userImage: imageURL
                        )

                        DatabaseService.shared.setRequest(request: request) { result in
                            switch result {
                            case .success(let event):
                                print("Заявка успешно создана: \n\(event)")
                            case .failure(let error):
                                print("Возникла ошибка при создании заявки: \n\(error)")
                            }
                        }
                        
                        self?.onCatalog?()
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}
