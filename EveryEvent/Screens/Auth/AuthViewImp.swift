import UIKit

final class AuthViewImp: UIView, AuthView {
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = A.Colors.white.color
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    var onAuthAction: ((_ email: String, _ passw: String) -> Void)?
    var onRegAction: (() -> Void)?
    
    enum Constants {
        static let padding: CGFloat = 16
        static let fontSize: CGFloat = 14
        static let spacing: CGFloat = 30
        static let tfHeight: CGFloat = 56
    }
    //MARK: Logo
    private lazy var logoImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "Images/EveryEventLogo"))
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        return image
    }()
    
    //MARK: Label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Авторизация"
        label.font = .systemFont(ofSize: 25, weight: .init(700))
        label.textAlignment = .center
        
        return label
    }()
    
    //MARK: E-mail
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "  E-mail"
        textField.textContentType = .emailAddress
        textField.autocapitalizationType = .none
        
        configureTF(textField: textField)
        
        return textField
    }()
    
    //MARK: Password
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "  Пароль"
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        
        configureTF(textField: textField)
        
        return textField
    }()
    
    //MARK: RegButton
    private lazy var authButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Вход", for: .normal)
        button.setTitleColor(A.Colors.white.color, for: .normal)
        button.backgroundColor = A.Colors.Primary.blue.color
        button.addTarget(self, action: #selector(auth), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: Auth stackView
    private lazy var loginStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    titleLabel,
                    emailTextField,
                    passwordTextField,
                    authButton,
                    regStackView
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Constants.spacing
        
        return stackView
    }()
    
    //MARK: Login if needed
    private lazy var regLabel: UILabel = {
        let label = UILabel()
        
        label.text = "У вас нет аккаунта?"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var regButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .clear
        button.setTitle("Регистрация", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(A.Colors.Primary.blue.color, for: .normal)
        button.addTarget(self, action: #selector(regAction), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var regStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    regLabel,
                    regButton
                ]
        )
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 5
        
        return stackView
    }()
    
    //MARK: Login logic
    @objc
    private func auth() {
        guard let email = emailTextField.text,
              let passw = passwordTextField.text
        else {
            print("(AuthViewImp): Нужно заполнить все поля")
            return
        }
        onAuthAction?(email, passw)
    }
    
    @objc
    private func regAction() {
        onRegAction?()
    }
}

//MARK: View setup
private extension AuthViewImp {
    
    //MARK: addSubview
    func setupView() {
        addSubview(logoImageView)
        addSubview(loginStackView)
    }
    
    //MARK: Constraints
    func setupConstraints(){
        NSLayoutConstraint.activate(
            [
                loginStackView.topAnchor.constraint(equalTo: topAnchor, constant: 250),
                loginStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
                loginStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
                
                logoImageView.bottomAnchor.constraint(equalTo: loginStackView.topAnchor),
                logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                logoImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ]
        )
    }
    
    //MARK: TextFieldConfigure
    func configureTF(textField: UITextField) {
        textField.font = .systemFont(ofSize: Constants.fontSize)
        textField.textColor = A.Colors.Grayscale.black.color
        textField.backgroundColor = A.Colors.Background.background.color
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 6
        textField.heightAnchor.constraint(equalToConstant: Constants.tfHeight).isActive = true
    }

}
