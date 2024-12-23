import UIKit
import YandexMapsMobile

final class EventCreateViewImp: UIView {
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = A.Colors.white.color
        detailedAddressView.isHidden = true
        setup()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Properties
    var onCreateAction: (
        (
            _ name: String,
            _ url: String,
            _ category: String,
            _ address: String,
            _ date: String,
            _ count: Int,
            _ desc: String
        ) -> Void
    )?
    var onPresent: ((UIViewController, Bool) -> Void)?
    
    private var eventImageURL: String?
    
    //MARK: PageName
    private lazy var pageNameLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.text = "Создание мероприятия"
        label.font = .systemFont(ofSize: 25, weight: .init(700))
        
        return label
    }()
    
    //MARK: Name
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        
        label.text = " Название:"
        defaultLabelConfigure(label: label)
        
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "  Введите название"
        defaultTextFieldConfigure(textField: textField)
        
        return textField
    }()
    
    private lazy var nameStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    nameLabel,
                    nameTextField
                ]
        )
        
        defaultStackViewConfigure(stackView: stackView)
        
        return stackView
    }()
    
    //MARK: Image
    private lazy var imageLabel: UILabel = {
        let label = UILabel()
        
        label.text = " Картинка:"
        defaultLabelConfigure(label: label)
        
        return label
    }()
    
    private lazy var imageTextLabel: UILabel = {
        let label = UILabel()

        label.text = "  Картинка не выбрана"
        label.textColor = .red
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = A.Colors.Primary.blue.color.cgColor
        label.backgroundColor = A.Colors.Background.background.color
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        defaultLabelConfigure(label: label)
        
        return label
    }()
    
    private lazy var chooseImageButton: UIButton = {
        let button = UIButton()
        
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.addTarget(self, action: #selector(didTapChangeChooseImage), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        return button
    }()
    
    private lazy var imageHorizontalStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [imageTextLabel, chooseImageButton]
        )
        
        stackView.setCustomSpacing(5, after: imageTextLabel)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        
        return stackView
    }()
    
    @objc private func didTapChangeChooseImage() {
        presentPhotoActionSheet()
    }
    
    private lazy var imageStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    imageLabel,
                    imageHorizontalStackView
                ]
        )
        
        defaultStackViewConfigure(stackView: stackView)
        
        return stackView
    }()
    
    //MARK: Category
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        
        label.text = " Категория:"
        defaultLabelConfigure(label: label)
        
        return label
    }()
    
    private lazy var categoryTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "  Введите категорию"
        defaultTextFieldConfigure(textField: textField)
        
        return textField
    }()
    
    private lazy var categoryStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    categoryLabel,
                    categoryTextField
                ]
        )
        
        defaultStackViewConfigure(stackView: stackView)
        
        return stackView
    }()
    
    //MARK: Address
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        
        label.text = " Место проведения:"
        defaultLabelConfigure(label: label)
        
        return label
    }()
    
    //MARK: Address
    private lazy var currentAddressLabel: UILabel = {
        let label = UILabel()
        
        label.text = "  Адрес не выбран"
        label.textColor = .black
        label.layer.borderWidth = 1
        label.layer.borderColor = A.Colors.Primary.blue.color.cgColor
        label.backgroundColor = A.Colors.Background.background.color
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        defaultLabelConfigure(label: label)
        
        return label
    }()
    
//    private lazy var addressTextField: UITextField = {
//        let textField = UITextField()
//
//        textField.placeholder = "  Введите адрес"
//        defaultTextFieldConfigure(textField: textField)
//        
//        return textField
//    }()
    //MARK: Crate button
    private lazy var addressButton: UIButton = {
        let button = UIButton()
        
        button.setImage(A.Images.Catalog.mapIcon.image, for: .normal)
//        button.backgroundColor = A.Colors.Primary.blue.color
        button.addTarget(self, action: #selector(addAddress), for: .touchUpInside)
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        return button
    }()
    
    private lazy var addressStackView: UIStackView = {
        let horizontalStack = UIStackView(arrangedSubviews: [addressLabel, addressButton])
        horizontalStack.spacing = 30
        horizontalStack.alignment = .firstBaseline
        
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    horizontalStack,
                    currentAddressLabel,
                ]
        )

        
        
        defaultStackViewConfigure(stackView: stackView)
//        stackView.alignment = .leading
        return stackView
    }()
    
    //MARK: Date
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        
        label.text = " Дата проведения:"
        defaultLabelConfigure(label: label)
        
        return label
    }()
    
    private lazy var dateTextField: UITextField = {
        let textField = UITextField()

        textField.placeholder = "  Введите дату"
        defaultTextFieldConfigure(textField: textField)
        
        return textField
    }()
    
    private lazy var dateStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    dateLabel,
                    dateTextField
                ]
        )
        
        defaultStackViewConfigure(stackView: stackView)
        
        return stackView
    }()
    
    //MARK: People count
    
    private lazy var peopleLabel: UILabel = {
        let label = UILabel()
        
        label.text = " Максимальное количество участников:"
        defaultLabelConfigure(label: label)
        
        return label
    }()
    
    private lazy var peopleCountField: UITextField = {
        let textField = UITextField()

        textField.placeholder = "  Введите количество"
        defaultTextFieldConfigure(textField: textField)
        
        return textField
    }()
    
    private lazy var peopleStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    peopleLabel,
                    peopleCountField
                ]
        )
        
        defaultStackViewConfigure(stackView: stackView)
        
        return stackView
    }()
    
    //MARK: Description
    private lazy var descLabel: UILabel = {
        let label = UILabel()
        
        label.text = " Описание мероприятия:"
        defaultLabelConfigure(label: label)
        
        return label
    }()
    
    private lazy var descTextField: UITextView = {
        let textView = UITextView()
        
        textView.backgroundColor = A.Colors.Background.background.color
        textView.font = .systemFont(ofSize: 16, weight: .medium)
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        textView.layer.borderWidth = 1
        textView.layer.borderColor = A.Colors.Primary.blue.color.cgColor

        return textView
    }()
    
    private lazy var descStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    descLabel,
                    descTextField
                ]
        )
        
        defaultStackViewConfigure(stackView: stackView)
        
        return stackView
    }()
    
    //MARK: Crate button
    private lazy var createButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Создать мероприятие", for: .normal)
        button.backgroundColor = A.Colors.Primary.blue.color
        button.addTarget(self, action: #selector(createEventAction), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: CreateAction logic
    @objc
    private func createEventAction() {
        guard let name = nameTextField.text,
              let url = eventImageURL,
              let category = categoryTextField.text,
              let address = currentAddressLabel.text,
              let date = dateTextField.text,
              let peopleCount = Int(peopleCountField.text ?? "0"),
              let desc = descTextField.text
        else {
            print("EventCreateViewImp: Все поля должны быть заполнены")
            return
        }
        
        onCreateAction?(name, url, category, address, date, peopleCount, desc)
    }
    @objc
    private func addAddress() {
        detailedAddressView.isHidden = false
        detailedAddressView.addressField.becomeFirstResponder()
    }
    
    //MARK: Event stackView
    private lazy var createEventStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews:
                [
                    pageNameLabel,
                    nameStackView,
                    imageStackView,
                    categoryStackView,
                    addressStackView,
                    dateStackView,
                    peopleStackView,
                    descStackView,
                    createButton
                ]
        )
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 20
        
        return stackView
    }()
    
    private let myLocationShadowView = ShadowView(style: .control).ui.forAutoLayout()
    public let myLocationButton = Button(style: .white(.medium)).ui
        .image(A.Images.Menu.profile.image)
        .forAutoLayout()
    public let myPin = ImageView(image: A.Images.Catalog.mapPoint.image).ui
        .forAutoLayout()
//    public var deliveryButton: Button {
//        detailedAddressView.deliveryButton
//    }
    public var heightVisibleMap: CGFloat = 0 {
        didSet {
            if heightVisibleMap == .zero {
                deselectObject(object: selectedShop)
            }

            let stretchFactor = Float((mapView.bounds.height - heightVisibleMap) / mapView.bounds.height)
            mapView.mapWindow.focusRect = YMKScreenRect(
                topLeft: .init(x: 0, y: 0),
                bottomRight: .init(
                    x: Float(mapView.mapWindow.width()),
                    y: stretchFactor * Float(mapView.mapWindow.height())
                )
            )
        }
    }
    public var maxHeightInfoView: CGFloat {
        mapView.bounds.height - 76
    }
    public var collectionManager: CollectionManager {
        detailedAddressView.collectionManager
    }

    private let mapView = YMKMapView(frame: .zero, vulkanPreferred: false).ui.forAutoLayout()
    public var map: YMKMap {
        mapView.mapWindow.map
    }

    private var detailedAddressView = DetailedAddressView().ui.forAutoLayout()

    private var collection: YMKClusterizedPlacemarkCollection?
    private var selectedShop: YMKPlacemarkMapObject? {
        didSet {
            UIView.animate(withDuration: 0.2) { [unowned self] in
                myButtonBottomConstraint.constant = selectedShop == nil ? 16 + safeAreaInsets.bottom : 16
                layoutIfNeeded()
            }
        }
    }

    private var myButtonBottomConstraint: NSLayoutConstraint = .init()
    private var detailedAddressViewTopConstraint: NSLayoutConstraint = .init()

    private var onLocationChanged: ((Coordinates, Bool) -> Void)?
    private var onAddressChanged: ((String?) -> Void)?
    private var onMapTap: (() -> Void)?

    // MARK: Configuration

    private func configure() {
        backgroundColor = .white

        mapView.isHidden = true
        map.mapType = .vectorMap
        mapView.mapWindow.map.addInputListener(with: self)
        mapView.mapWindow.map.logo.setAlignmentWith(YMKLogoAlignment(
            horizontalAlignment: .right,
            verticalAlignment: YMKLogoVerticalAlignment.top
        ))

        detailedAddressView.addressField.delegate = self
        detailedAddressView.addressField.addAction { [unowned self] in
            textFieldDidChange($0)
        }
        
//        addressTextField.addaction

//        myLocationShadowView.addSubview(myLocationButton)
        ui.addSubviews([mapView, detailedAddressView])
//        myButtonBottomConstraint = detailedAddressView.topAnchor.constraint(
//            equalTo: myLocationShadowView.bottomAnchor,
//            constant: 16
//        )
        detailedAddressViewTopConstraint = detailedAddressView.topAnchor.constraint(
            equalTo: safeAreaLayoutGuide.topAnchor,
            constant: 56
        )


        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: mapView.bottomAnchor,
                constant: 155
            ),

            detailedAddressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: detailedAddressView.trailingAnchor),
            detailedAddressView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

//        registerDefaultStates()
    }

    // MARK: Private

    private func moveCamera(to target: YMKPoint, zoom: Float, duration: Float) {
        let position = YMKCameraPosition(target: target, zoom: zoom, azimuth: 0, tilt: 0)
        map.move(with: position, animation: YMKAnimation(type: .smooth, duration: duration))
    }

    private func deselectObject(object: YMKPlacemarkMapObject?) {
        guard let object, object.userData != nil else {
            return
        }
        selectedShop = nil
    }

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        onAddressChanged?(textField.text)
    }
}

// MARK: - DeliveryAddressRootView

extension EventCreateViewImp: EventCreateView {
    public func locationChanged(_ locationChanged: @escaping((Coordinates, Bool) -> Void)) {
        onLocationChanged = locationChanged
    }

    public func addressChanged(_ addressChanged: @escaping((String?) -> Void)) {
        onAddressChanged = addressChanged
    }

    public func mapTap(_ mapTapHandler: @escaping () -> Void) {
        onMapTap = mapTapHandler
    }

    public func setLocation(coordinates: Coordinates, zoom: Float) {
        moveCamera(
            to: YMKPoint(latitude: coordinates.latitude, longitude: coordinates.longitude),
            zoom: zoom,
            duration: 0
        )
    }

    public func updateAddress(address: String, close: Bool) {
        detailedAddressView.addressField.text = address
        if close {
            detailedAddressView.addressField.resignFirstResponder()
            detailedAddressView.isHidden = true
            currentAddressLabel.text = address
        } else {
            onAddressChanged?(address)
        }
    }

    public func currentCoordinates() -> Coordinates {
        Coordinates(
            longitude: map.cameraPosition.target.longitude,
            latitude: map.cameraPosition.target.latitude
        )
    }

    public func currentAddress() -> String {
        detailedAddressView.addressField.text ?? ""
    }

    public func showEmptyAddressError() {
        detailedAddressView.addressField.errorMessage = "Поле адреса должно быть заполнено"
    }

    public func showNoAddressError() {
        detailedAddressView.addressField.text = nil
        detailedAddressView.addressField.errorMessage = "Адрес не найден"
    }

    public func showEmptySuggestionsState() {
        detailedAddressView.collectionView.isHidden = true
        detailedAddressView.emptyView.isHidden = false
    }

    public func hideEmptySuggestionsState() {
        detailedAddressView.collectionView.isHidden = false
        detailedAddressView.emptyView.isHidden = true
    }
}

// MARK: - YMKMapCameraListener

extension EventCreateViewImp: YMKMapCameraListener {
    public func onCameraPositionChanged(
        with map: YMKMap,
        cameraPosition: YMKCameraPosition,
        cameraUpdateReason: YMKCameraUpdateReason,
        finished: Bool
    ) {
        onLocationChanged?(
            Coordinates(
                longitude: cameraPosition.target.longitude,
                latitude: cameraPosition.target.latitude
            ),
            finished
        )
    }
}

// MARK: - YMKMapInputListener

extension EventCreateViewImp: YMKMapInputListener {
    // swiftlint:disable:next empty_method
    public func onMapLongTap(with map: YMKMap, point: YMKPoint) {}

    public func onMapTap(with map: YMKMap, point: YMKPoint) {
        if detailedAddressView.addressField.isFirstResponder {
            detailedAddressView.addressField.resignFirstResponder()
            onMapTap?()
        } else {
            moveCamera(to: point, zoom: map.cameraPosition.zoom, duration: .zero)
            onLocationChanged?(
                Coordinates(
                    longitude: point.longitude,
                    latitude: point.latitude
                ),
                true
            )
        }
    }
}

// MARK: - UITextFieldDelegate

extension EventCreateViewImp: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        map.setInteractionEnabled(false)

        DispatchQueue.main.async {
            textField.selectedTextRange = textField.textRange(
                from: textField.endOfDocument,
                to: textField.endOfDocument
            )
        }

        UIView.animate(withDuration: 0.25) {
            self.detailedAddressViewTopConstraint.isActive = true
            self.myLocationShadowView.alpha = 0
            self.detailedAddressView.detailsView.alpha = 0
            self.detailedAddressView.collectionView.alpha = 1
            self.detailedAddressView.emptyView.alpha = 1
            self.layoutIfNeeded()
        }
        onAddressChanged?(textField.text)
        return true
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        map.setInteractionEnabled(true)

        UIView.animate(withDuration: 0.25) {
            self.detailedAddressViewTopConstraint.isActive = false
            self.myLocationShadowView.alpha = 1
            self.detailedAddressView.detailsView.alpha = 1
            self.detailedAddressView.collectionView.alpha = 0
            self.detailedAddressView.emptyView.alpha = 0
            self.layoutIfNeeded()
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension YMKMap {
    func setInteractionEnabled(_ isEnabled: Bool) {
        isScrollGesturesEnabled = isEnabled
        isTiltGesturesEnabled = isEnabled
        isRotateGesturesEnabled = isEnabled
        isZoomGesturesEnabled = isEnabled
    }
}

//MARK: Setup
private extension EventCreateViewImp {
    
    func setup() {
        addSubview(createEventStackView)
        
        NSLayoutConstraint.activate(
            [
                createEventStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
                createEventStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                createEventStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                createEventStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35)
            ]
        )
    }
    
    func defaultTextFieldConfigure(textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = A.Colors.Primary.blue.color.cgColor
        textField.backgroundColor = A.Colors.Background.background.color
        textField.textColor = A.Colors.Grayscale.black.color
        textField.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func defaultLabelConfigure(label: UILabel) {
        label.numberOfLines = 0
    }
    
    func defaultStackViewConfigure(stackView: UIStackView) {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
    }
    
}

extension EventCreateViewImp: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        self.endEditing(true)
        let actionSheet = UIAlertController(
            title: "Фото мероприятия",
            message: "Как бы вы хотели выбрать фото?",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Сфотографировать", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Выбрать фотографию", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
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
        
        guard let data = selectedImage.pngData() else {
            return
        }
        
        let fileName = "photo_event_" + UUID().uuidString.replacingOccurrences(of: " ", with: "-") + ".png"
        
        StorageService.shared.uploadEventPhoto(with: data, fileName: fileName) { [weak self] result in
            switch result {
            case .success(let downloadUrl):
                print(downloadUrl)
                self?.eventImageURL = downloadUrl
                self?.imageTextLabel.text = "Картинка выбрана"
                self?.imageTextLabel.textColor = .green
            case .failure(let error):
                print("Произошла ошибка менеджера хранилища: \(error)")
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
