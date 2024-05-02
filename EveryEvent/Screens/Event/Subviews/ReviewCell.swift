import UIKit
import Kingfisher

final class ReviewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Setup subviews & constraints
    private func setup() {
        contentView.addSubview(reviewStackView)
        
        NSLayoutConstraint.activate(
            [
                reviewStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                reviewStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                reviewStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ]
        )
    }
    
    //MARK: Name
    lazy var nameLabel: UILabel = {
        let label = UILabel()
    
        label.text = "Имя пользователя"
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .init(700))
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return label
    }()
    
    //MARK: Review
    lazy var reviewLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = A.Colors.Grayscale.black.color
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.text = "Текст отзыва"
        label.textAlignment = .left
        
        return label
    }()

    lazy var reviewStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    nameLabel,
                    reviewLabel
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 2
        
        return stackView
    }()
    
}

//MARK: Setup sectionLayout
extension ReviewCell {
    static func layout() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 16
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.5)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: spacing, leading: 0, bottom: spacing, trailing: 0)
        section.interGroupSpacing = 24
        
        return section
    }
    
    //MARK: Update cell function
    func update(with data: ReviewCellData) {
        nameLabel.text = data.name ?? "-"
        reviewLabel.text = data.review ?? "-"
    }
}
