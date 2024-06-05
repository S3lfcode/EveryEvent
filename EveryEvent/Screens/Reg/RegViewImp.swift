import UIKit

final class RegViewImp: UIView, RegView {
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    var onRegAction: ((_ name: String, _ lastName: String, _ email: String, _ passw: String) -> Void)?
    var onLoginAction: (() -> Void)?
    
    enum Constants {
        static let padding: CGFloat = 16
        static let fontSize: CGFloat = 14
        static let spacing: CGFloat = 30
        static let tfHeight: CGFloat = 56
    }
    //MARK: Logo
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Images/EveryEventLogo"))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        return imageView
    }()
    
    //MARK: Label
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Регистрация"
        label.font = .systemFont(ofSize: 25, weight: .init(700))
        label.textAlignment = .center
        
        return label
    }()

    //MARK: Name
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "  Имя"
        configureTF(textField: textField)
        
        return textField
    }()
    
    //MARK: Name
    private lazy var lastNameTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "  Фамилия"
        configureTF(textField: textField)
        
        return textField
    }()
    
    //MARK: Phone
//    private lazy var numberCodeLabel: UILabel = {
//        let label = UILabel()
//        
//        label.text = "+7"
//        label.textAlignment = .center
//        label.textColor = A.Colors.Background.placeholder.color
//        label.backgroundColor = A.Colors.Background.background.color
//        label.font = .systemFont(ofSize: Constants.fontSize)
//        label.heightAnchor.constraint(equalToConstant: 56).isActive = true
//        label.widthAnchor.constraint(equalToConstant: 45).isActive = true
//        label.layer.masksToBounds = true
//        label.layer.cornerRadius = 6
//        
//        return label
//    }()
    
//    private lazy var phoneTextField: UITextField = {
//        let textField = UITextField()
//        
//        textField.placeholder = "  Номер телефона"
//        configureTF(textField: textField)
//        
//        return textField
//    }()
    
//    private lazy var phoneStackView: UIStackView = {
//        let stackView = UIStackView(
//            arrangedSubviews:
//                [
//                    numberCodeLabel,
//                    phoneTextField
//                ]
//        )
//        
//        stackView.distribution = .fill
//        stackView.alignment = .fill
//        stackView.axis = .horizontal
//        stackView.spacing = 9
//        
//        return stackView
//    }()
    
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
    private lazy var regButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Зарегистрироваться", for: .normal)
        button.setTitleColor(A.Colors.white.color, for: .normal)
        button.backgroundColor = A.Colors.Primary.blue.color
        button.addTarget(self, action: #selector(regAction), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: Error label
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Все поля должны быть заполнены!"
        label.textColor = A.Colors.Primary.red.color
        label.textAlignment = .center
        label.isHidden = true
        
        return label
    }()
    
    //MARK: Login if needed
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Уже есть аккаунт?"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .clear
        button.setTitle("Вход", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(A.Colors.Primary.blue.color, for: .normal)
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var loginStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    loginLabel,
                    loginButton
                ]
        )
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 5
        
        return stackView
    }()
    
    //MARK: Objc methods
    @objc
    private func regAction() {
        guard let name = nameTextField.text,
              let lastName = lastNameTextField.text,
              let email = emailTextField.text,
              let passw = passwordTextField.text
        else {
            showError(text: "Все поля должны быть заполнены!", true)
            return
        }
        
        guard textFieldValidator(textField: nameTextField),
              textFieldValidator(textField: lastNameTextField),
              textFieldValidator(textField: emailTextField),
              textFieldValidator(textField: passwordTextField)
        else {
            showError(text: "Все поля должны быть заполнены!", true)
            return
        }
        
        onRegAction?(name, lastName, email, passw)
    }
    
    @objc
    private func loginAction() {
        onLoginAction?()
    }
    
    //MARK: Registration stackView
    private lazy var regStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    titleLabel,
                    nameTextField,
                    lastNameTextField,
                    emailTextField,
                    passwordTextField,
                    regButton,
                    errorLabel,
                    loginStackView
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = Constants.spacing
        
        return stackView
    }()
    
    //MARK: Showing error
    func showError(text: String = "", _ show: Bool) {
        if show {
            errorLabel.isHidden = false
        } else {
            errorLabel.isHidden = true
        }
    }
    
}

//MARK: View setup
private extension RegViewImp {
    
    //MARK: addSubview
    func setupView() {
        addSubview(logoImageView)
        addSubview(regStackView)
    }
    
    //MARK: Constraints
    func setupConstraints(){
        NSLayoutConstraint.activate(
            [
                regStackView.topAnchor.constraint(equalTo: topAnchor, constant: 150),
                regStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.padding),
                regStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.padding),
                
                logoImageView.bottomAnchor.constraint(equalTo: regStackView.topAnchor),
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
        textField.delegate = self
    }
    
    //MARK: TextField validator
    
    func textFieldValidator(textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }
        
        if text.isEmpty || text == "" || text.count > 30 {
            return false
        }
        
        return true
    }

}

extension RegViewImp: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showError(false)
    }
}
