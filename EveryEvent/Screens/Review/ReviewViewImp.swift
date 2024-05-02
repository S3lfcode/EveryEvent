import UIKit

final class ReviewViewImp: UIView, ReviewView {
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = A.Colors.white.color
        
        setup()
        
        reviewTextView.becomeFirstResponder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    var onProfile: (() -> Void)?
    
    var onReviewCreate: ((_ reviewText: String) -> Void)?
    
    //MARK: View hierarchy
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Создание отзыва"
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 20, weight: .init(700))
        label.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        return label
    }()
    
    private lazy var reviewTextView: UITextView = {
        let textView = UITextView()
        
        textView.backgroundColor = A.Colors.Background.background.color
        
        textView.layer.borderWidth = 1
        textView.layer.borderColor = A.Colors.Primary.blue.color.cgColor
        
        return textView
    }()
    
    private lazy var reviewStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    titleLabel,
                    reviewTextView,
                    reviewButton
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 20
        
        return stackView
    }()
    
    private lazy var reviewButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .blue
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.setTitle("Отправить отзыв", for: .normal)
        button.addTarget(self, action: #selector(reviewAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func reviewAction() {
        guard
            let text = reviewTextView.text,
            !text.isEmpty
        else {
            print("Заполните поле для отзыва!")
            return
        }
        
        onReviewCreate?(text)
    }
}

//MARK: Setup view
private extension ReviewViewImp {
    func setup() {
        addSubview(reviewStackView)
        
        NSLayoutConstraint.activate(
            [
                reviewStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                reviewStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                reviewStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                reviewStackView.heightAnchor.constraint(equalToConstant: 400)
            ]
        )
    }
}

//MARK: Update info
extension ReviewViewImp {
    func update(eventName: String) {
        titleLabel.text = "Отзыв на мероприятие:\n\(eventName)"
    }
}
