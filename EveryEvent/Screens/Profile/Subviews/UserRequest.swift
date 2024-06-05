import Foundation
import UIKit
import Kingfisher

final class UserRequest: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onApply: (() -> Void)?
    var onReject: (() -> Void)?
    var onReview: (() -> Void)?
    
    //MARK: Setup subviews & constraints
    private func setup() {
        contentView.addSubview(requestStackView)
        contentView.addSubview(userButtonStackView)
        
        NSLayoutConstraint.activate(
            [
                requestStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                requestStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                requestStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                requestStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
                
                userButtonStackView.topAnchor.constraint(equalTo: requestStackView.bottomAnchor),
                userButtonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                userButtonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                userButtonStackView.heightAnchor.constraint(equalToConstant: 30),
            ]
        )
    }
    
    //MARK: Image
    lazy var cellImageView: UIImageView = {
        let imageView = UIImageView(image: A.Images.everyEventLogo.image)
        
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = A.Colors.Grayscale.midGray.color.cgColor
        
        return imageView
    }()
    
    private func updateImage(url: String?) {
        guard let stringURL = url else {
            return
        }
        
        let url = URL(string: stringURL)
        
        cellImageView.kf.indicatorType = .activity
        cellImageView.kf.setImage(
            with: url,
            placeholder: A.Images.everyEventLogo.image,
            options: [
                .transition(.fade(0.2)),
                .processor(
                    DownsamplingImageProcessor(
                        size: CGSize(width: 100, height: 100)
                    )
                )
            ]
        )
    }
    
    //MARK: Type card
    private lazy var cellType: UILabel = {
        let label = UILabel()
        
        label.text = "Тип: "
        
        return label
    }()
    
    //MARK: Event name
    private lazy var eventNameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Мероприятие"
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 14)
        
        
        return label
    }()
    
    //MARK: Even date
    private lazy var eventDateLabel: UILabel = {
        let label = UILabel()
        
        label.text = "11.11.23 22:00"
        label.font = .systemFont(ofSize: 14)
        
        return label
    }()
    
    //MARK: User name
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = A.Colors.Grayscale.black.color
        label.font = .systemFont(ofSize: 14)
        label.text = "Пользователь"
        
        return label
    }()
    
    //MARK: RequestInfo
    lazy var requestInfoStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    cellType,
                    userNameLabel,
                    eventNameLabel,
                    eventDateLabel
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 2
        
        return stackView
    }()
    
    //MARK: Request cell
    private lazy var requestStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    cellImageView,
                    requestInfoStackView
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 5
        
        return stackView
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Принять", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .green
        button.addTarget(self, action: #selector(applyAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func applyAction() {
        onApply?()
    }
    
    private lazy var rejectButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Отклонить", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(rejectAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func rejectAction() {
        onReject?()
    }
    
    //MARK: Status label
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        
        label.text = ""
        label.textAlignment = .center
        label.textColor = A.Colors.Primary.blue.color
        label.font = .systemFont(ofSize: 18, weight: .init(700))
        label.isHidden = true
        
        return label
    }()
    
    //MARK: Review button
    private lazy var reviewButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Отзыв", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .blue
        button.isHidden = true
        button.addTarget(self, action: #selector(reviewAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func reviewAction() {
        onReview?()
    }
    
    //MARK: Request buttons
    private lazy var userButtonStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    applyButton,
                    rejectButton,
                    statusLabel,
                    reviewButton
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        return stackView
    }()
    
}

//MARK: Setup sectionLayout
extension UserRequest {
    static func layout() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(180)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: spacing/2, leading: spacing, bottom: spacing, trailing: spacing)
        //        section.interGroupSpacing = 24
        
        return section
    }
    
    //MARK: Update cell function
    func update(with data: ProfileRequestData) {
        if data.userID == AuthService.shared.currentUser?.uid {
            cellType.text = "Тип: исходящая"
            updateImage(url: data.eventImage ?? "-")
            applyButton.isHidden = true
            rejectButton.isHidden = true
            statusLabel.isHidden = false
            
            switch data.status {
            case "Сформирована":
                statusLabel.text = "Заявка на участие отправлена"
                reviewButton.isHidden = true
                statusLabel.textColor = .blue
            case "Подтверждена":
                DatabaseService.shared.getReviews { [weak self] result in
                    switch result {
                    case .success(let reviews):
                        let alreadyReview = reviews.contains {
                            ($0.eventId == data.eventID) && ($0.userId == data.userID)
                        }
                        
                        if alreadyReview {
                            self?.statusLabel.text = "Участник | Отзыв оставлен"
                            self?.reviewButton.isHidden = true
                        } else {
                            self?.statusLabel.text = "Участник"
                            self?.reviewButton.isHidden = false
                        }
                        
                    case .failure(_):
                        print("Возникла ошибка получения отзывов (UserRequest)")
                    }
                }
                
                statusLabel.textColor = .green
            case "Отклонена":
                statusLabel.text = "Отказано в участии"
                reviewButton.isHidden = true
                statusLabel.textColor = .red
            default:
                print("Неверный тип")
            }
            
        } else {
            cellType.text = "Тип: входящая"
            cellImageView.image = A.Images.Profile.photo.image
            updateImage(url: data.userImage ?? "-")
            switch data.status {
            case "Сформирована":
                statusLabel.isHidden = true
                reviewButton.isHidden = true
                applyButton.isHidden = false
                rejectButton.isHidden = false
            case "Подтверждена":
                statusLabel.text = "Вы подтвердили участника"
                statusLabel.textColor = .green
                statusLabel.isHidden = false
                applyButton.isHidden = true
                rejectButton.isHidden = true
                reviewButton.isHidden = true
            case "Отклонена":
                statusLabel.text = "Вы отказали участнику"
                statusLabel.textColor = .red
                statusLabel.isHidden = false
                applyButton.isHidden = true
                rejectButton.isHidden = true
                reviewButton.isHidden = true
            default:
                print("Неверный тип")
            }
        }
        
        eventNameLabel.text = "Название: \(data.eventName ?? "-")"
        eventDateLabel.text = "Дата: \(data.eventDate ?? "-")"
        userNameLabel.text = "Имя пользователя: \(data.userName ?? "-") \(data.userLastName ?? "-")"
        
        onApply = data.onApply
        onReject = data.onReject
        onReview = {
            data.onReview(data.eventID)
        }
    }
}
