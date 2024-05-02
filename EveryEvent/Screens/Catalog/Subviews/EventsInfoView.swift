import UIKit
import Kingfisher

final class EventsInfoView: UIView {
    private var model: EventVM?

    //MARK: Name
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .init(300))
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
    
    //MARK: event button
    private lazy var eventButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Выбрать мероприятие", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(requestAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func requestAction() {
        guard let event = model?.event else { return }
        model?.onEvent(event)
    }
    
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
                    eventButton
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.isHidden = true
        
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
                        size: CGSize(width: 250, height: 250)
                    )
                )
            ]
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Configuration

    private func configure() {
        backgroundColor = UIColor.white
        
        ui.addSubview(pageStackView)
        
        NSLayoutConstraint.activate(
            [
                pageStackView.topAnchor.constraint(equalTo: topAnchor),
                pageStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                pageStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                pageStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: 16),
                pageStackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -32),
                
                eventImageView.heightAnchor.constraint(equalToConstant: 150),
                eventImageView.widthAnchor.constraint(equalToConstant: 50)
            ]
        )
    }

    func update(with model: EventVM) {
        self.model = model

        pageStackView.isHidden = false
        nameLabel.text = "\(String(describing: model.event.name ?? "Без имени"))"
        categoryLabel.text = "\(String(describing: model.event.category ?? "Без категории"))"
        addressLabel.text = model.event.address
        dateLabel.text = "\(String(describing: model.event.date ?? "Без даты"))"
        updateProductImage(url: model.event.urlImage)
    }
}
