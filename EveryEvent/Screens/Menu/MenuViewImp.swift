import UIKit

final class MenuViewImp: UIView, MenuView {
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = A.Colors.Grayscale.lightGray.color
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    var onProfile: (() -> Void)?
    var onCatalog: (() -> Void)?
    var onMyEvent: (() -> Void)?
    var onCreateEvent: (() -> Void)?
    var onSettings: (() -> Void)?
    var onLogOut: (() -> Void)?

    //MARK: View hierarchy
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Меню"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30, weight: .init(700))
        
        return label
    }()
    
    private lazy var profileButton: UIButton = {
        let button = UIButton()
        
        button.setImage(A.Images.Menu.profile.image, for: .normal)
        button.setTitle("    Профиль", for: .normal)
        button.addTarget(self, action: #selector(toProfile), for: .touchUpInside)
        defaultButtonSetup(button: button)
        
        return button
    }()
    
    private lazy var catalogButton: UIButton = {
        let button = UIButton()
        
        button.setImage(A.Images.Menu.events.image, for: .normal)
        button.setTitle("    Каталог мероприятий", for: .normal)
        defaultButtonSetup(button: button)
        button.addTarget(self, action: #selector(toCatalog), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var myEventsButton: UIButton = {
        let button = UIButton()
        
        button.setImage(A.Images.Menu.myEvents.image, for: .normal)
        button.setTitle("    Мои мероприятия", for: .normal)
        defaultButtonSetup(button: button)
        
        return button
    }()
    
    private lazy var createEventButton: UIButton = {
        let button = UIButton()
        
        button.setImage(A.Images.Menu.create.image, for: .normal)
        button.setTitle("    Создать мероприятие", for: .normal)
        defaultButtonSetup(button: button)
        button.addTarget(self, action: #selector(toCreateEvent), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        
        button.setImage(A.Images.Menu.settings.image, for: .normal)
        button.setTitle("    Настройки", for: .normal)
        defaultButtonSetup(button: button)
        
        return button
    }()
    
    private lazy var logOutButton: UIButton = {
        let button = UIButton()
        
        button.setImage(A.Images.Menu.logout.image, for: .normal)
        button.setTitle("    Выход", for: .normal)
        defaultButtonSetup(button: button)
        button.addTarget(self, action: #selector(logOutAction), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: Menu stackView
    private lazy var menuStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    titleLabel,
                    profileButton,
                    catalogButton,
                    myEventsButton,
                    createEventButton,
                    settingsButton,
                    logOutButton
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.setCustomSpacing(60, after: titleLabel)
        stackView.spacing = 30
        return stackView
    }()
    
    //MARK: Button logic
    @objc
    private func toProfile() {
        onProfile?()
    }
    
    @objc
    private func toCatalog() {
        onCatalog?()
    }
    
    @objc
    private func toMyEvent() {
        onMyEvent?()
    }
    
    @objc
    private func toCreateEvent() {
        onCreateEvent?()
    }
    
    @objc
    private func toSettings() {
        onSettings?()
    }
    
    @objc
    private func logOutAction() {
        onLogOut?()
    }
}

//MARK: Setup view
private extension MenuViewImp {
    
    func defaultButtonSetup(button: UIButton) {
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.backgroundColor = A.Colors.Primary.blue.color
        button.layer.cornerRadius = 10
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 0)
        button.imageView?.tintColor = A.Colors.white.color
    }
    
    func setup() {
        addSubview(menuStackView)
        
        NSLayoutConstraint.activate(
            [
                menuStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
                menuStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
                menuStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50)
            ]
        )
    }
    
}
