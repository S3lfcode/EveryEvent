import UIKit

final class MaterialSearchView: UIControl {
    
    //MARK: States
    enum Status {
        case `default`
        case active
    }
    
    private(set) var status: Status = .default
    
    var textIsEditing: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(textField)
        addSubview(searchImageView)
        addSubview(clearButton)

        backgroundColor = UIColor(named: "Colors/Phone/background")
        layer.cornerRadius = 18
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "Colors/Phone/background")?.cgColor
        
        addTarget(self, action: #selector(didEditing), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        searchImageView.frame.origin = .init(
            x: 17,
            y: bounds.height/2 - searchImageView.frame.height/2
        )
        
        textField.frame = .init(
            x: searchImageView.frame.maxX + 12,
            y: 0,
            width: bounds.width-78,
            height: bounds.height
        )
        
        clearButton.frame = .init(
            x: textField.frame.maxX+5,
            y: bounds.height/2 - clearButton.frame.height/2,
            width: 15,
            height: 15
        )
    }
    
    @objc func didEditing() {
        textField.becomeFirstResponder()
    }
    
    //MARK: View hierarchy
    lazy var textField: UITextField = {
        let textField = UITextField()
        
        textField.backgroundColor = .white
        textField.placeholder = "Поиск"
        textField.font = UIFont(name: "GothamSSm-Book", size: 14)
        textField.delegate = self
        
        return textField
    }()
    
    lazy var searchImageView: UIImageView = {
        let imageView = UIImageView(image: A.Images.SearchComponent.search.image)
        
        imageView.tintColor = UIColor(named: "Colors/Phone/placeholder")
        
        return imageView
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = UIColor(named: "Colors/Phone/placeholder")
        button.layer.cornerRadius = 7
        button.setImage(UIImage(named: "SearchComponent/ClearField"), for: .normal)
        button.tintColor = UIColor(named: "Colors/white")
        button.contentMode = .center
        button.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.isHidden = true
        button.addTarget(
            self,
            action: #selector(clearText),
            for: .touchUpInside
        )
        
        return button
    }()
    
    //MARK: Clear button action
    @objc func clearText() {
        textField.text = ""
        clearButton.isHidden = true
        if !textField.isEditing {
            update(status: .default, animated: true)
        }
    }
}

//MARK: Update state function
extension MaterialSearchView {
    func update(status: Status, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.update(status: status)
            self.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        }
    }
    
    private func update(status: Status) {
        self.status = status
        switch status {
        case .`default`:
            layer.borderColor = A.Colors.Background.background.color.cgColor
            searchImageView.tintColor = A.Colors.Background.placeholder.color
        case .active:
            layer.borderColor = A.Colors.Primary.blue.color.cgColor
            searchImageView.tintColor = A.Colors.Primary.blue.color
        }
        setNeedsLayout()
    }
    
}

//MARK: TextField interactive logic
extension MaterialSearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        update(status: .active, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            update(status: .default, animated: true)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return false
        }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        
        if newString == "" {
            clearButton.isHidden = true
        } else {
            clearButton.isHidden = false
        }
        return true
    }
}
