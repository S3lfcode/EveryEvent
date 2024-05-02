import UIKit

public final class PlaceInfoView: UIView {
    private let eventsInfoView = EventsInfoView().ui.make()

    var onPan: ((Bool) -> Void)?

    var contentStack = UIStackView().ui
        .forAutoLayout()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        ui
            .backgroundColor(UIColor.white)
        .cornerRadius(16, cornerCurve: .circular)
        .maskedCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner])
        .clipsToBounds(true)

        let panView = UIView().ui
            .backgroundColor(UIColor.gray)
            .cornerRadius(2)
            .clipsToBounds(true)
            .forAutoLayout()
        let panAreaView = UIView().ui
            .backgroundColor(UIColor.white)
            .addSubview(panView)
            .forAutoLayout()

        addSubview(panAreaView)
        addSubview(contentStack)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        addGestureRecognizer(panGesture)

        NSLayoutConstraint.activate([
            panAreaView.heightAnchor.constraint(equalToConstant: 20),
            panAreaView.leadingAnchor.constraint(equalTo: leadingAnchor),
            panAreaView.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: panAreaView.trailingAnchor),

            panView.widthAnchor.constraint(equalToConstant: 33),
            panView.heightAnchor.constraint(equalToConstant: 4),
            panView.centerXAnchor.constraint(equalTo: panAreaView.centerXAnchor),
            panView.topAnchor.constraint(equalTo: panAreaView.topAnchor, constant: 8),

            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            panAreaView.bottomAnchor.constraint(equalTo: contentStack.topAnchor),
            trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),
            bottomAnchor.constraint(equalTo: contentStack.bottomAnchor)
        ])
    }

    private var initialTouchPoint: CGPoint = .zero

    func show(_ viewModel: EventVM) {
        eventsInfoView.update(with: viewModel)
        contentStack.addArrangedSubview(eventsInfoView)
    }

    // MARK: Private

    @objc
    private func didPan(_ gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: self.window)

        switch gesture.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            let diff = touchPoint.y - initialTouchPoint.y
            let showSheet = diff < 0
            onPan?(showSheet)
        default:
            break
        }
    }
}
