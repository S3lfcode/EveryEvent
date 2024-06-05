import UIKit
import Kingfisher

final class EventCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        promotionView.isHidden = true
    }
    
    var onSelectLike: (() -> Void)?
    
    //MARK: Setup subviews & constraints
    private func setup() {
        contentView.addSubview(eventImageView)
        contentView.addSubview(descProductStackView)
        contentView.addSubview(promotionView)
        
        NSLayoutConstraint.activate(
            [
                eventImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                eventImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                eventImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                
                promotionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
                promotionView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 3),
                
                descProductStackView.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 12),
                descProductStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                descProductStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ]
        )
    }
    
    //MARK: Product image block
    lazy var eventImageView: UIImageView = {
        let imageView = UIImageView(image: A.Images.everyEventLogo.image)
        
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = A.Colors.Background.background.color
        imageView.layer.cornerRadius = 10
        imageView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = A.Colors.Grayscale.midGray.color.cgColor
        
        return imageView
    }()
    
    lazy var promoCountLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        
        return label
    }()
    
    lazy var promotionView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.blue.cgColor
        
        
        let starView = UIView()
        starView.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "star.fill")
        image.tintColor = .blue
        
        starView.addSubview(image)
        
        view.addSubview(starView)
        view.addSubview(promoCountLabel)
        
        
        NSLayoutConstraint.activate(
            [
                starView.leftAnchor.constraint(equalTo: view.leftAnchor),
                starView.topAnchor.constraint(equalTo: view.topAnchor),
                starView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                starView.widthAnchor.constraint(equalToConstant: 25),
                starView.heightAnchor.constraint(equalToConstant: 25),
                
                image.centerXAnchor.constraint(equalTo: starView.centerXAnchor),
                image.centerYAnchor.constraint(equalTo: starView.centerYAnchor),
                image.widthAnchor.constraint(equalToConstant: 18),
                image.heightAnchor.constraint(equalToConstant: 18),
                
                promoCountLabel.leftAnchor.constraint(equalTo: starView.rightAnchor),
                promoCountLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5),
                promoCountLabel.topAnchor.constraint(equalTo: view.topAnchor),
                promoCountLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
        
        return view
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
    
    //MARK: Title
    lazy var titleLabel: UILabel = {
        let label = UILabel()
    
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.22
        label.numberOfLines = 2
        label.attributedText = NSMutableAttributedString(
            string: "Безымянный",
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 15, weight: .init(700))
        
        return label
    }()
    
    //MARK: Date
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = A.Colors.Grayscale.black.color
        label.font = .systemFont(ofSize: 14)
        label.text = "11.11.23 22:00"
        
        return label
    }()
    
    //MARK: Address
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = A.Colors.Grayscale.black.color
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.text = "Ул. Большевистска д.30"
        
        return label
    }()
    
    //MARK: Category
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = A.Colors.Grayscale.black.color
        label.font = .systemFont(ofSize: 14)
        label.text = "музыка"
        
        return label
    }()

    
    lazy var descProductStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    titleLabel,
                    dateLabel,
                    addressLabel,
                    categoryLabel
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 10
        
        return stackView
    }()
    
}

//MARK: Setup sectionLayout
extension EventCell {
    static func layout() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(330)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: spacing/2, leading: spacing, bottom: spacing, trailing: spacing)
        section.interGroupSpacing = 24
        
        return section
    }
    
    //MARK: Update cell function
    func update(with data: EventCellData) {
        titleLabel.text = data.name ?? "-"
        dateLabel.text = data.date ?? "-"
        addressLabel.text = data.address ?? "-"
        categoryLabel.text = data.category ?? "-"
        updateProductImage(url: data.urlImage)
        if data.promotionCount > 0 {
            promotionView.isHidden = false
            promoCountLabel.text = String(data.promotionCount)
        }
    }
}
