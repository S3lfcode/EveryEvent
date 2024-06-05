import Foundation
import UIKit
import Kingfisher

final class ProfileViewImp: UIView, ProfileView {
    enum RequestFilteredState {
        case incoming
        case outgoing
        case all
    }
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = A.Colors.white.color
        
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    private var cellData: [ProfileRequestData] = []
    private var incomingCellData = [ProfileRequestData]()
    private var outgoingCellData = [ProfileRequestData]()
    
    var onRefresh: (() -> Void)?
    var onPresent: ((UIViewController, Bool) -> Void)?
    
    private var state: RequestFilteredState = .all
    
    //MARK: ViewHierarchy
    private lazy var userImageView: UIImageView = {
        let imageView = UIImageView(image: A.Images.Profile.photo.image)
        
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 100
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        return imageView
    }()

    private lazy var profileButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .clear
        button.tintColor = .clear
        button.addTarget(self, action: #selector(didTapChangeProfilePhoto), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    @objc private func didTapChangeProfilePhoto() {
        presentPhotoActionSheet()
    }
    
    //MARK: User InfoLabel
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "UserName"
        
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        
        label.text = "user@email.com"
        
        return label
    }()
    
    private lazy var lastNameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "UserLastName"
        
        return label
    }()
    
    private lazy var typeRequest: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    //MARK: UserInfo
    private lazy var userInfoStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    nameLabel,
                    lastNameLabel,
                    emailLabel
                ]
        )
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        return stackView
    }()
    
    //MARK: Profile
    private lazy var userProfileStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    userImageView,
                    userInfoStackView
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        
        return stackView
    }()
    
    private lazy var requestLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Заявки на участие"
        label.backgroundColor = .lightGray
        label.font = .systemFont(ofSize: 16, weight: .init(700))
        label.textAlignment = .center
        
        return label
    }()
    
    private lazy var userIncomingButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Входящие", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(incomingAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func incomingAction() {
        switch self.state {
        case .all, .outgoing:
            userIncomingButton.backgroundColor = .lightGray
            userOutgoingButton.backgroundColor = .blue
            self.state = .incoming
            catalogCollectionView.reloadData()
        case .incoming:
            userIncomingButton.backgroundColor = .blue
            userOutgoingButton.backgroundColor = .blue
            self.state = .all
            catalogCollectionView.reloadData()
        }
    }
    
    private lazy var userOutgoingButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Исходящие", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(outgoingAction), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    private func outgoingAction() {
        switch self.state {
        case .all, .incoming:
            userIncomingButton.backgroundColor = .blue
            userOutgoingButton.backgroundColor = .lightGray
            self.state = .outgoing
            catalogCollectionView.reloadData()
        case .outgoing:
            userIncomingButton.backgroundColor = .blue
            userOutgoingButton.backgroundColor = .blue
            self.state = .all
            catalogCollectionView.reloadData()
        }
    }
    
    //MARK: Request buttons
    private lazy var userButtonStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    userIncomingButton,
                    userOutgoingButton
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        
        return stackView
    }()
    
    //MARK: Refresh Catalog
    private lazy var RefreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        
        refresh.tintColor = A.Colors.Primary.blue.color
        refresh.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        
        return refresh
    }()
    
    @objc
    private func refresh(sender: UIRefreshControl) {
        onRefresh?()
    }
    
    //MARK: CollectionView
    private lazy var catalogCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewCompositionalLayout { _, _ in
            UserRequest.layout()
        }
        
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionViewLayout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UserRequest.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.refreshControl = RefreshControl
        
        return collectionView
    }()
}

//MARK: Calalog view settings
extension ProfileViewImp: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch self.state {
        case .all:
            return cellData.count
        case .incoming:
            return incomingCellData.count
        case .outgoing:
            return outgoingCellData.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let cell = cell as? UserRequest {
            switch self.state {
            case .all:
                cell.update(with: cellData[indexPath.item])
            case .incoming:
                cell.update(with: incomingCellData[indexPath.item])
            case .outgoing:
                cell.update(with: outgoingCellData[indexPath.item])
            }
        }
        return cell
    }
}

//MARK: Collection view logic
extension ProfileViewImp: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
    }
    
}


//MARK: ViewSetup
private extension ProfileViewImp {
    func setup() {
        addSubview(userProfileStackView)
        addSubview(requestLabel)
        addSubview(userButtonStackView)
        addSubview(catalogCollectionView)
        addSubview(profileButton)
        
        NSLayoutConstraint.activate(
            [
                userProfileStackView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
                userProfileStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                userProfileStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                userProfileStackView.heightAnchor.constraint(equalToConstant: 200),
                
                profileButton.topAnchor.constraint(equalTo: topAnchor, constant: 50),
                profileButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                profileButton.heightAnchor.constraint(equalToConstant: 200),
                profileButton.widthAnchor.constraint(equalToConstant: 200),
                
                requestLabel.topAnchor.constraint(equalTo: userProfileStackView.bottomAnchor, constant: 10),
                requestLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                requestLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                requestLabel.heightAnchor.constraint(equalToConstant: 30),
                
                userButtonStackView.topAnchor.constraint(equalTo: requestLabel.bottomAnchor, constant: 10),
                userButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                userButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                userButtonStackView.heightAnchor.constraint(equalToConstant: 30),
                
                catalogCollectionView.topAnchor.constraint(equalTo: userButtonStackView.bottomAnchor, constant: 10),
                catalogCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                catalogCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                catalogCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            ]
        )
    }
}

//MARK: UpdateProfile
extension ProfileViewImp {
    func updateProfile(user: DataUser) {
        nameLabel.text = user.name
        lastNameLabel.text = user.lastName
        emailLabel.text = user.email
        
        let safeEmail = DatabaseService.shared.getSafeEmail()
        let filename = safeEmail + "_profile_picture.png"
        let path = "images/" + filename

        StorageService.shared.downloadURL(for: path) { [weak self] result in
            if case .success(let url) = result {
                self?.userImageView.kf.indicatorType = .activity
                self?.userImageView.kf.setImage(
                    with: url,
                    placeholder: A.Images.Profile.photo.image,
                    options: [
                        .transition(.fade(0.2)),
                        .processor(
                            DownsamplingImageProcessor(
                                size: CGSize(width: 200, height: 200)
                            )
                        )
                    ]
                )
            }
        }
    }
}

//MARK: Display data
extension ProfileViewImp {
    func display(cellData: [ProfileRequestData]) {
        self.incomingCellData = cellData.filter({ request in
            return (request.userID != AuthService.shared.currentUser?.uid) && (request.eventOwnerID == AuthService.shared.currentUser?.uid)
        })
        
        self.outgoingCellData = cellData.filter({ request in
            return request.userID == AuthService.shared.currentUser?.uid
        })
        
        self.cellData = self.incomingCellData + self.outgoingCellData
        
        catalogCollectionView.refreshControl?.endRefreshing()
        catalogCollectionView.reloadData()
    }
}

extension ProfileViewImp: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Фото профиля", message: "Как бы вы хотели выбрать фото?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Сфотографировать", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Выбрать фотографию", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        onPresent?(actionSheet, true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        onPresent?(vc, true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        onPresent?(vc, true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.userImageView.image = selectedImage
        guard let image = self.userImageView.image, let data = image.pngData() else {
            return
        }
        
        DatabaseService.shared.getProfile { result in
            if case .success(let dataUser) = result {
                let filename = dataUser.profilePictureFilename
                StorageService.shared.uploadProfilePicture(with: data, fileName: filename) { result in
                    switch result {
                    case .success(let downloadUrl):
                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                        print(downloadUrl)
                    case .failure(let error):
                        print("Произошла ошибка менеджера хранилища: \(error)")
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
