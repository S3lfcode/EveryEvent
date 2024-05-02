import UIKit
import Kingfisher

class EventViewImp: UIView, EventView {
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = A.Colors.white.color
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Property
    var onRequest: (() -> Void)?
    
    private var cellData: [ReviewCellData] = []
    
    //MARK: Setup
    private func setup() {
        addSubview(scrollView)
        scrollView.addSubview(pageStackView)
        
        NSLayoutConstraint.activate(
            [
                scrollView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                pageStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                pageStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
                pageStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
                pageStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                pageStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
            ]
        )
    }
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    //MARK: Name
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .init(700))
        label.numberOfLines = 0
        label.text = "\"Мероприятие\""
        
        return label
    }()
    
    //MARK: Image
    private lazy var eventImageView: UIImageView = {
        let imageView = UIImageView(image: A.Images.Catalog.testImage.image)
        
        imageView.alpha = 1
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = A.Colors.Background.background.color
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = A.Colors.Grayscale.midGray.color.cgColor
    
        imageView.heightAnchor.constraint(equalToConstant: 360).isActive = true
        return imageView
    }()
    
    //MARK: Category
    private lazy var categoryNameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Что? "
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        label.font = .systemFont(ofSize: 20, weight: .init(400))
        
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.text = "Музыка"
        
        return label
    }()
    
    private lazy var categoryStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    categoryNameLabel,
                    categoryLabel
                ]
        )
        
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    
    //MARK: Place
    private lazy var addressNameLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 20, weight: .init(400))
        label.text = "Где? "
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 2
        label.textAlignment = .left
        label.text = "Ул. Большевистская, д. 30, кв. 144"
        
        return label
    }()
    
    private lazy var placeStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    addressNameLabel,
                    addressLabel
                ]
        )
        
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        
        return stackView
    }()
    
    //MARK: Date
    private lazy var dateNameLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .init(400))
        label.text = "Когда? "
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 2
        label.text = "12.05.2020 10:45"
        
        return label
    }()
    
    private lazy var dateStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    dateNameLabel,
                    dateLabel
                ]
        )
        
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        
        return stackView
    }()
    
    //MARK: Description
    private lazy var descNameLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 20, weight: .init(400))
        label.text = "Описание мероприятия:"
        
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.text = "Описание мероприятия"
        
        return label
    }()
    
    //MARK: Request button
    private lazy var requestButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Подать заявку на участие", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(requestAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func requestAction() {
        onRequest?()
    }
    
    //MARK: Owner info block
    private lazy var ownerInfoLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Информация об организаторе:"
        label.font = .systemFont(ofSize: 15, weight: .init(700))
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var ownerNameLabel: UILabel = {
        let label = UILabel()
        
        
        return label
    }()
    
    private lazy var ownerPhoneLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private lazy var ownerEmailLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    private lazy var ownerStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                 ownerInfoLabel,
                 ownerNameLabel,
                 ownerEmailLabel,
                 ownerPhoneLabel
                ]
            
        )
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 3
        stackView.setCustomSpacing(15, after: ownerInfoLabel)
        
        return stackView
    }()
    
    //MARK: Owner info block
    private lazy var reviewInfoLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Отзывы о мероприятии:"
        label.font = .systemFont(ofSize: 15, weight: .init(700))
        label.textAlignment = .center
        
        return label
    }()
    
    //MARK: Events rewievs
    private lazy var reviews: UILabel = {
        let label = UILabel()
        
        label.text = "Отзывы о мероприятии"
        
        return label
    }()
    
    //MARK: Rewiews CollectionView
    private lazy var catalogCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewCompositionalLayout { _, _ in
            ReviewCell.layout()
        }
        
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ReviewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 400).isActive = true
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    //MARK: Page stackView
    private lazy var pageStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    nameLabel,
                    eventImageView,
                    categoryStackView,
                    placeStackView,
                    dateStackView,
                    descNameLabel,
                    descLabel,
                    requestButton,
                    ownerStackView,
                    reviewInfoLabel,
                    catalogCollectionView
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.isHidden = true
        stackView.setCustomSpacing(0, after: reviewInfoLabel)
        
        return stackView
    }()
    
    private func updateProductImage(url: String?) {
        guard let stringURL = url else {
            return
        }
        
        let url = URL(string: stringURL)
        
        eventImageView.kf.indicatorType = .activity
        eventImageView.kf.setImage(
            with: url,
            placeholder: A.Images.everyEventLogo.image,
            options: [
                .transition(.fade(0.2)),
                .processor(
                    DownsamplingImageProcessor(
                        size: CGSize(width: bounds.width, height: 250)
                    )
                )
            ]
        )
    }
}

//MARK: Calalog review settings
extension EventViewImp: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return cellData.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let cell = cell as? ReviewCell {
            cell.update(with: cellData[indexPath.item])
        }
        
        return cell
    }
}

//MARK: Collection view logic
extension EventViewImp: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
    }
    
}

//MARK: Update view state
extension EventViewImp {
    func updateInfo(event: Event, requests: [Request]) {
        nameLabel.text = "\(String(describing: event.name ?? "Без имени"))"
        categoryLabel.text = "\(String(describing: event.category ?? "Без категории"))"
        addressLabel.text = event.address
        dateLabel.text = "\(String(describing: event.date ?? "Без даты"))"
        updateProductImage(url: event.urlImage)
        descLabel.text = "\(String(describing: event.desc ?? "Нет описания"))"
        if event.userId == AuthService.shared.currentUser?.uid {
            requestButton.isHidden = true
        }
        
        let request = requests.filter {
            return $0.eventID == event.id && $0.userID == AuthService.shared.currentUser?.uid
        }
        
        if !request.isEmpty {
            requestButton.titleLabel?.numberOfLines = 2
            requestButton.setTitle("Вы уже подавали заявку на это мероприятие", for: .normal)
            requestButton.titleLabel?.font = .systemFont(ofSize: 14)
            requestButton.backgroundColor = .lightGray
            requestButton.isUserInteractionEnabled = false
        }
        
        pageStackView.isHidden = false
    }
    
    func updateOwnerInfo(owner: DataUser) {
        ownerNameLabel.text = "Имя организатора: \(owner.name ?? "Не указано")"
        ownerEmailLabel.text = "E-mail: \(owner.email ?? "-")"
        ownerPhoneLabel.text = "Телефон: \(owner.phone ?? "-")"
    }
}

//MARK: Display data
extension EventViewImp {
    func display(cellData: [ReviewCellData]) {

        self.cellData = cellData
        
        if cellData.isEmpty {
            reviewInfoLabel.isHidden = true
            catalogCollectionView.isHidden = true
        }
        
        catalogCollectionView.reloadData()
    }
}
