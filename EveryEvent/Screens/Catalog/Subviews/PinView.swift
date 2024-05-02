

import UIKit
import Kingfisher

final class PinView: UIImageView {
    var isSelected = false {
        didSet {
            textLabel.textStyle = isSelected ? .textBody : .subheader
        }
    }
//    private let iconView = UIImageView().ui.forAutoLayout()
    private let iconView = ImageView().ui.forAutoLayout()
    private let textLabel = Label().ui
        .textStyle(.subheader)
        .textColor(UIColor.gray)
        .forAutoLayout()

    private var name: String

    enum Constants {
        static let iconSize = CGSize(width: 30, height: 30)
        static let horizontalSpacing = 10.0
        static let itemSpacing = 4.0
        static let height = 35.0
    }

    init(name: String, category: String?, text: String) {
        self.name = name
//        company = DeliveryCompany(rawValue: contractorName ?? "") ?? .none
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
//        iconView.image = A.Images.Catalog.mapIcon.image
        textLabel.text = text
        
        var image = A.Images.Catalog.Points.party.image
        switch category {
        case "Искусство":
            image = A.Images.Catalog.Points.art.image
        case "Музыка":
            image = A.Images.Catalog.Points.music.image
            break
        case "Образование":
            image = A.Images.Catalog.Points.education.image
        case "Спорт":
            image = A.Images.Catalog.Points.sport.image
        case "История":
            image = A.Images.Catalog.Points.history.image
        default:
            break
        }
        
        iconView.image = image
        
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public func setImage(imageURL: URL?) {
//        iconView.kf.indicatorType = .activity
//        iconView.kf.setImage(
//            with: imageURL,
//            placeholder: A.Images.Catalog.mapIcon.image,
//            options: [
//                .transition(.fade(0.2)),
//                .processor(
//                    DownsamplingImageProcessor(
//                        size: CGSize(width: 25, height: 25)
//                    )
//                )
//            ]
//        )
//    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: 2 * Constants.horizontalSpacing +
                Constants.iconSize.width +
                Constants.itemSpacing +
                textLabel.intrinsicContentSize.width,
            height: Constants.height
        )
    }

    private func configure() {
        ui
            .backgroundColor(.clear.withAlphaComponent(0))
            .isOpaque(false)
            .addSubviews([iconView, textLabel])

        NSLayoutConstraint.activate([
            iconView.heightAnchor.constraint(equalToConstant: Constants.iconSize.height),
            iconView.widthAnchor.constraint(equalToConstant: Constants.iconSize.width),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -3),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalSpacing),

            textLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: Constants.itemSpacing),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -3),
            trailingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: Constants.horizontalSpacing)
        ])
        layoutIfNeeded()
    }
}
