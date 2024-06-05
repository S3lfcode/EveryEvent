
import Foundation

public protocol PropertyPath {
    associatedtype Root
    associatedtype Value

    @discardableResult
    func setValue(_ value: Value, object: Root) -> Root?
}

public struct Property<Root, Value>: PropertyPath {
    private let setValue: (Root, Value) -> Root?

    init(_ keyPath: ReferenceWritableKeyPath<Root, Value>) {
        setValue = {
            $0[keyPath: keyPath] = $1
            return nil
        }
    }

    init(_ keyPath: WritableKeyPath<Root, Value>) {
        setValue = {
            var root = $0
            root[keyPath: keyPath] = $1
            return root
        }
    }

    init<Current>(_ keyPath: KeyPath<Root, Current?>, child: Property<Current, Value>) {
        setValue = {
            if
                let current = $0[keyPath: keyPath],
                let result = child.setValue(current, $1),
                let refKeyPath = keyPath as? ReferenceWritableKeyPath<Root, Current?>
            {
                $0[keyPath: refKeyPath] = result
            }
            return nil
        }
    }

    // MARK: PropertyPath

    public func setValue(_ value: Value, object: Root) -> Root? {
        setValue(object, value)
    }
}


import Foundation

protocol PropertyScope {
    init()
}


import UIKit

// swiftlint:disable file_types_order

extension ConfigurableUI {
    @available(*, deprecated, renamed: "ui")
    public var configurator: UIConfigurator<Self> {
        UIConfigurator(self)
    }
}

extension UIConfigurator {
    func set<Scope: PropertyScope, Path: PropertyPath>(
        value: Path.Value,
        to path: KeyPath<Scope, Path>
    ) -> Self where Wrapped == Path.Root {
        let scope = Scope()
        scope[keyPath: path].setValue(value, object: wrapped)
        return self
    }
}

// MARK: - CALayer

public struct CALayerProperties<Layer: CALayer>: PropertyScope {
    public let bounds = Property(\Layer.bounds)
    public let position = Property(\Layer.position)
    public let zPosition = Property(\Layer.zPosition)
    public let anchorPoint = Property(\Layer.anchorPoint)
    public let anchorPointZ = Property(\Layer.anchorPointZ)
    public let transform = Property(\Layer.transform)
    public let frame = Property(\Layer.frame)
    public let isHidden = Property(\Layer.isHidden)
    public let isDoubleSided = Property(\Layer.isDoubleSided)
    public let isGeometryFlipped = Property(\Layer.isGeometryFlipped)
    public let sublayers = Property(\Layer.sublayers)
    public let sublayerTransform = Property(\Layer.sublayerTransform)
    public let mask = Property(\Layer.mask)
    public let masksToBounds = Property(\Layer.masksToBounds)
    public let contents = Property(\Layer.contents)
    public let contentsRect = Property(\Layer.contentsRect)
    public let contentsGravity = Property(\Layer.contentsGravity)
    public let contentsScale = Property(\Layer.contentsScale)
    public let contentsCenter = Property(\Layer.contentsCenter)
    public let contentsFormat = Property(\Layer.contentsFormat)
    public let minificationFilter = Property(\Layer.minificationFilter)
    public let magnificationFilter = Property(\Layer.magnificationFilter)
    public let minificationFilterBias = Property(\Layer.minificationFilterBias)
    public let isOpaque = Property(\Layer.isOpaque)
    public let needsDisplayOnBoundsChange = Property(\Layer.needsDisplayOnBoundsChange)
    public let drawsAsynchronously = Property(\Layer.drawsAsynchronously)
    public let edgeAntialiasingMask = Property(\Layer.edgeAntialiasingMask)
    public let allowsEdgeAntialiasing = Property(\Layer.allowsEdgeAntialiasing)
    public let backgroundColor = Property(\Layer.backgroundColor)
    public let cornerRadius = Property(\Layer.cornerRadius)
    public let maskedCorners = Property(\Layer.maskedCorners)
    public let cornerCurve = Property(\Layer.cornerCurve)
    public let borderWidth = Property(\Layer.borderWidth)
    public let borderColor = Property(\Layer.borderColor)
    public let opacity = Property(\Layer.opacity)
    public let allowsGroupOpacity = Property(\Layer.allowsGroupOpacity)
    public let compositingFilter = Property(\Layer.compositingFilter)
    public let filters = Property(\Layer.filters)
    public let backgroundFilters = Property(\Layer.backgroundFilters)
    public let shouldRasterize = Property(\Layer.shouldRasterize)
    public let rasterizationScale = Property(\Layer.rasterizationScale)
    public let shadowColor = Property(\Layer.shadowColor)
    public let shadowOpacity = Property(\Layer.shadowOpacity)
    public let shadowOffset = Property(\Layer.shadowOffset)
    public let shadowRadius = Property(\Layer.shadowRadius)
    public let shadowPath = Property(\Layer.shadowPath)
    public let actions = Property(\Layer.actions)
    public let name = Property(\Layer.name)
    public let delegate = Property(\Layer.delegate)
    public let style = Property(\Layer.style)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: CALayer {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<CALayerProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UIView

public struct UIViewProperties<View: UIView>: PropertyScope {
    public let cornerRadius = Property(\View.layer.cornerRadius)
    public let maskedCorners = Property(\View.layer.maskedCorners)
    public let cornerCurve = Property(\View.layer.cornerCurve)
    public let borderWidth = Property(\View.layer.borderWidth)
    public let borderColor = Property(\View.layer.borderColor)
    public let isUserInteractionEnabled = Property(\View.isUserInteractionEnabled)
    public let tag = Property(\View.tag)
    public let frame = Property(\View.frame)
    public let bounds = Property(\View.bounds)
    public let center = Property(\View.center)
    public let transform = Property(\View.transform)
    public let transform3D = Property(\View.transform3D)
    public let contentScaleFactor = Property(\View.contentScaleFactor)
    public let isMultipleTouchEnabled = Property(\View.isMultipleTouchEnabled)
    public let isExclusiveTouch = Property(\View.isExclusiveTouch)
    public let autoresizesSubviews = Property(\View.autoresizesSubviews)
    public let autoresizingMask = Property(\View.autoresizingMask)
    public let layoutMargins = Property(\View.layoutMargins)
    public let directionalLayoutMargins = Property(\View.directionalLayoutMargins)
    public let preservesSuperviewLayoutMargins = Property(\View.preservesSuperviewLayoutMargins)
    public let insetsLayoutMarginsFromSafeArea = Property(\View.insetsLayoutMarginsFromSafeArea)
    public let clipsToBounds = Property(\View.clipsToBounds)
    public let backgroundColor = Property(\View.backgroundColor)
    public let alpha = Property(\View.alpha)
    public let isOpaque = Property(\View.isOpaque)
    public let clearsContextBeforeDrawing = Property(\View.clearsContextBeforeDrawing)
    public let isHidden = Property(\View.isHidden)
    public let contentMode = Property(\View.contentMode)
    public let mask = Property(\View.mask)
    public let tintColor = Property(\View.tintColor)
    public let tintAdjustmentMode = Property(\View.tintAdjustmentMode)
    public let overrideUserInterfaceStyle = Property(\View.overrideUserInterfaceStyle)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: UIView {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UIViewProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UIControl

public struct UIControlProperties<View: UIControl>: PropertyScope {
    public let isEnabled = Property(\View.isEnabled)
    public let isSelected = Property(\View.isSelected)
    public let isHighlighted = Property(\View.isHighlighted)
    public let contentVerticalAlignment = Property(\View.contentVerticalAlignment)
    public let contentHorizontalAlignment = Property(\View.contentHorizontalAlignment)
    public let isContextMenuInteractionEnabled = Property(\View.isContextMenuInteractionEnabled)
    public let showsMenuAsPrimaryAction = Property(\View.showsMenuAsPrimaryAction)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: UIControl {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UIControlProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UIButton

public struct UIButtonProperties<View: UIButton>: PropertyScope {
    public let configurationUpdateHandler = Property(\View.configurationUpdateHandler)
    public let automaticallyUpdatesConfiguration = Property(\View.automaticallyUpdatesConfiguration)
    public let role = Property(\View.role)
    public let menu = Property(\View.menu)
    public let changesSelectionAsPrimaryAction = Property(\View.changesSelectionAsPrimaryAction)
    public let backgroundColor = Property(\View.configuration, child: Property(\.background.backgroundColor))
    public let textColor = Property(\View.configuration, child: Property(\.baseForegroundColor))
    public let image = Property(\View.configuration, child: Property(\.image))
    public let title = Property(\View.configuration, child: Property(\.title))
    public let attributedTitle = Property(\View.configuration, child: Property(\.attributedTitle))
    public let subtitle = Property(\View.configuration, child: Property(\.subtitle))
    public let attributedSubtitle = Property(\View.configuration, child: Property(\.attributedSubtitle))
    public let contentInsets = Property(\View.configuration, child: Property(\.contentInsets))
    public let imagePlacement = Property(\View.configuration, child: Property(\.imagePlacement))
    public let imagePadding = Property(\View.configuration, child: Property(\.imagePadding))
    public let titlePadding = Property(\View.configuration, child: Property(\.titlePadding))
    public let titleAlignment = Property(\View.configuration, child: Property(\.titleAlignment))
    public let configuration = Property(\View.configuration)
}

@available(*, deprecated, message: "Используйте метод, соответствуующий настраиваемоему свойству")
extension UIConfigurator where Wrapped: UIButton {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UIButtonProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UICollectionView

public struct UICollectionViewProperties<View: UICollectionView>: PropertyScope {
    public let collectionViewLayout = Property(\View.collectionViewLayout)
    public let isPrefetchingEnabled = Property(\View.isPrefetchingEnabled)
    public let dragInteractionEnabled = Property(\View.dragInteractionEnabled)
    public let reorderingCadence = Property(\View.reorderingCadence)
    public let backgroundView = Property(\View.backgroundView)
    public let allowsSelection = Property(\View.allowsSelection)
    public let allowsMultipleSelection = Property(\View.allowsMultipleSelection)
    public let isEditing = Property(\View.isEditing)
    public let allowsSelectionDuringEditing = Property(\View.allowsSelectionDuringEditing)
    public let allowsMultipleSelectionDuringEditing = Property(\View.allowsMultipleSelectionDuringEditing)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: UICollectionView {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UICollectionViewProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UIImageView

public struct UIImageViewProperties<View: UIImageView>: PropertyScope {
    public let image = Property(\View.image)
    public let highlightedImage = Property(\View.highlightedImage)
    public let isHighlighted = Property(\View.isHighlighted)
    public let animationImages = Property(\View.animationImages)
    public let highlightedAnimationImages = Property(\View.highlightedAnimationImages)
    public let animationDuration = Property(\View.animationDuration)
    public let animationRepeatCount = Property(\View.animationRepeatCount)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: UIImageView {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UIImageViewProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UILabel

public struct UILabelProperties<View: UILabel>: PropertyScope {
    public let text = Property(\View.text)
    public let font = Property(\View.font)
    public let textColor = Property(\View.textColor)
    public let shadowColor = Property(\View.shadowColor)
    public let shadowOffset = Property(\View.shadowOffset)
    public let textAlignment = Property(\View.textAlignment)
    public let lineBreakMode = Property(\View.lineBreakMode)
    public let attributedText = Property(\View.attributedText)
    public let highlightedTextColor = Property(\View.highlightedTextColor)
    public let isHighlighted = Property(\View.isHighlighted)
    public let isEnabled = Property(\View.isEnabled)
    public let numberOfLines = Property(\View.numberOfLines)
    public let adjustsFontSizeToFitWidth = Property(\View.adjustsFontSizeToFitWidth)
    public let baselineAdjustment = Property(\View.baselineAdjustment)
    public let minimumScaleFactor = Property(\View.minimumScaleFactor)
    public let allowsDefaultTighteningForTruncation = Property(\View.allowsDefaultTighteningForTruncation)
    public let lineBreakStrategy = Property(\View.lineBreakStrategy)
    public let preferredMaxLayoutWidth = Property(\View.preferredMaxLayoutWidth)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: UILabel {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UILabelProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UIScrollView

public struct UIScrollViewProperties<View: UIScrollView>: PropertyScope {
    public let contentOffset = Property(\View.contentOffset)
    public let contentSize = Property(\View.contentSize)
    public let contentInset = Property(\View.contentInset)
    public let contentInsetAdjustmentBehavior = Property(\View.contentInsetAdjustmentBehavior)
    // swiftlint:disable:next identifier_name
    public let automaticallyAdjustsScrollIndicatorInsets = Property(\View.automaticallyAdjustsScrollIndicatorInsets)
    public let isDirectionalLockEnabled = Property(\View.isDirectionalLockEnabled)
    public let bounces = Property(\View.bounces)
    public let alwaysBounceVertical = Property(\View.alwaysBounceVertical)
    public let alwaysBounceHorizontal = Property(\View.alwaysBounceHorizontal)
    public let isPagingEnabled = Property(\View.isPagingEnabled)
    public let isScrollEnabled = Property(\View.isScrollEnabled)
    public let showsVerticalScrollIndicator = Property(\View.showsVerticalScrollIndicator)
    public let showsHorizontalScrollIndicator = Property(\View.showsHorizontalScrollIndicator)
    public let indicatorStyle = Property(\View.indicatorStyle)
    public let verticalScrollIndicatorInsets = Property(\View.verticalScrollIndicatorInsets)
    public let horizontalScrollIndicatorInsets = Property(\View.horizontalScrollIndicatorInsets)
    public let scrollIndicatorInsets = Property(\View.scrollIndicatorInsets)
    public let decelerationRate = Property(\View.decelerationRate)
    public let indexDisplayMode = Property(\View.indexDisplayMode)
    public let delaysContentTouches = Property(\View.delaysContentTouches)
    public let canCancelContentTouches = Property(\View.canCancelContentTouches)
    public let minimumZoomScale = Property(\View.minimumZoomScale)
    public let maximumZoomScale = Property(\View.maximumZoomScale)
    public let zoomScale = Property(\View.zoomScale)
    public let bouncesZoom = Property(\View.bouncesZoom)
    public let scrollsToTop = Property(\View.scrollsToTop)
    public let keyboardDismissMode = Property(\View.keyboardDismissMode)
    public let refreshControl = Property(\View.refreshControl)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: UIScrollView {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UIScrollViewProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UIStackView

public struct UIStackViewProperties<View: UIStackView>: PropertyScope {
    public let axis = Property(\View.axis)
    public let distribution = Property(\View.distribution)
    public let alignment = Property(\View.alignment)
    public let spacing = Property(\View.spacing)
    public let isBaselineRelativeArrangement = Property(\View.isBaselineRelativeArrangement)
    public let isLayoutMarginsRelativeArrangement = Property(\View.isLayoutMarginsRelativeArrangement)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: UIStackView {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UIStackViewProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UITextField

public struct UITextFieldProperties<View: UITextField>: PropertyScope {
    public let text = Property(\View.text)
    public let attributedText = Property(\View.attributedText)
    public let textColor = Property(\View.textColor)
    public let font = Property(\View.font)
    public let textAlignment = Property(\View.textAlignment)
    public let borderStyle = Property(\View.borderStyle)
    public let defaultTextAttributes = Property(\View.defaultTextAttributes)
    public let placeholder = Property(\View.placeholder)
    public let attributedPlaceholder = Property(\View.attributedPlaceholder)
    public let clearsOnBeginEditing = Property(\View.clearsOnBeginEditing)
    public let adjustsFontSizeToFitWidth = Property(\View.adjustsFontSizeToFitWidth)
    public let minimumFontSize = Property(\View.minimumFontSize)
    public let background = Property(\View.background)
    public let disabledBackground = Property(\View.disabledBackground)
    public let allowsEditingTextAttributes = Property(\View.allowsEditingTextAttributes)
    public let typingAttributes = Property(\View.typingAttributes)
    public let clearButtonMode = Property(\View.clearButtonMode)
    public let leftView = Property(\View.leftView)
    public let leftViewMode = Property(\View.leftViewMode)
    public let rightView = Property(\View.rightView)
    public let rightViewMode = Property(\View.rightViewMode)
    public let inputView = Property(\View.inputView)
    public let inputAccessoryView = Property(\View.inputAccessoryView)
    public let clearsOnInsertion = Property(\View.clearsOnInsertion)
    public let autocapitalizationType = Property(\View.autocapitalizationType)
    public let autocorrectionType = Property(\View.autocorrectionType)
    public let spellCheckingType = Property(\View.spellCheckingType)
    public let smartQuotesType = Property(\View.smartQuotesType)
    public let smartDashesType = Property(\View.smartDashesType)
    public let smartInsertDeleteType = Property(\View.smartInsertDeleteType)
    public let keyboardType = Property(\View.keyboardType)
    public let keyboardAppearance = Property(\View.keyboardAppearance)
    public let returnKeyType = Property(\View.returnKeyType)
    public let enablesReturnKeyAutomatically = Property(\View.enablesReturnKeyAutomatically)
    public let isSecureTextEntry = Property(\View.isSecureTextEntry)
    public let textContentType = Property(\View.textContentType)
    public let passwordRules = Property(\View.passwordRules)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: UITextField {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UITextFieldProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - UITextView

public struct UITextViewProperties<View: UITextView>: PropertyScope {
    public let text = Property(\View.text)
    public let font = Property(\View.font)
    public let textColor = Property(\View.textColor)
    public let textAlignment = Property(\View.textAlignment)
    public let selectedRange = Property(\View.selectedRange)
    public let isEditable = Property(\View.isEditable)
    public let isSelectable = Property(\View.isSelectable)
    public let dataDetectorTypes = Property(\View.dataDetectorTypes)
    public let allowsEditingTextAttributes = Property(\View.allowsEditingTextAttributes)
    public let attributedText = Property(\View.attributedText)
    public let typingAttributes = Property(\View.typingAttributes)
    public let inputView = Property(\View.inputView)
    public let inputAccessoryView = Property(\View.inputAccessoryView)
    public let clearsOnInsertion = Property(\View.clearsOnInsertion)
    public let textContainerInset = Property(\View.textContainerInset)
    public let linkTextAttributes = Property(\View.linkTextAttributes)
    public let usesStandardTextScaling = Property(\View.usesStandardTextScaling)
    public let autocapitalizationType = Property(\View.autocapitalizationType)
    public let autocorrectionType = Property(\View.autocorrectionType)
    public let spellCheckingType = Property(\View.spellCheckingType)
    public let smartQuotesType = Property(\View.smartQuotesType)
    public let smartDashesType = Property(\View.smartDashesType)
    public let smartInsertDeleteType = Property(\View.smartInsertDeleteType)
    public let keyboardType = Property(\View.keyboardType)
    public let keyboardAppearance = Property(\View.keyboardAppearance)
    public let returnKeyType = Property(\View.returnKeyType)
    public let enablesReturnKeyAutomatically = Property(\View.enablesReturnKeyAutomatically)
    public let isSecureTextEntry = Property(\View.isSecureTextEntry)
    public let textContentType = Property(\View.textContentType)
    public let passwordRules = Property(\View.passwordRules)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: UITextView {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<UITextViewProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - TextField

public struct TextFieldProperties<View: TextField>: PropertyScope {
    public let isBordered = Property(\View.isBordered)
    public let errorMessage = Property(\View.errorMessage)
    public let validateOnEndEditing = Property(\View.validatesTextAutomatically)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: TextField {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<TextFieldProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - Slider

public struct SliderProperties<View: Slider>: PropertyScope {
    public let minimumValue = Property(\View.minimumValue)
    public let maximumValue = Property(\View.maximumValue)
    public let value = Property(\View.value)
    public let isContinuous = Property(\View.isContinuous)
//    public let color = Property(\View.color)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: Slider {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<SliderProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - SegmentedControl

//public struct SegmentedControlProperties<View: SegmentedControl>: PropertyScope {
//    public let segments = Property(\View.segments)
//    public let selectedSegmentIndex = Property(\View.selectedSegmentIndex)
//}

//@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
//extension UIConfigurator where Wrapped: SegmentedControl {
//    @discardableResult
//    public func set<Path: PropertyPath>(
//        _ path: KeyPath<SegmentedControlProperties<Wrapped>, Path>,
//        to value: Path.Value
//    ) -> Self where Wrapped == Path.Root {
//        set(value: value, to: path)
//    }
//}

// MARK: - PageControl

//public struct PageControlProperties<View: PageControl>: PropertyScope {
//    public let numberOfPages = Property(\View.numberOfPages)
//    public let currentPage = Property(\View.currentPage)
//    public let hidesForSinglePage = Property(\View.hidesForSinglePage)
//}

//@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
//extension UIConfigurator where Wrapped: PageControl {
//    @discardableResult
//    public func set<Path: PropertyPath>(
//        _ path: KeyPath<PageControlProperties<Wrapped>, Path>,
//        to value: Path.Value
//    ) -> Self where Wrapped == Path.Root {
//        set(value: value, to: path)
//    }
//}

// MARK: - Label

public struct LabelProperties<View: Label>: PropertyScope {
    public let textStyle = Property(\View.textStyle)
    public let contentInsets = Property(\View.contentInsets)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: Label {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<LabelProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - InteractiveLabel

public struct InteractiveLabelProperties<View: InteractiveLabel>: PropertyScope {
    public let textStyle = Property(\View.textStyle)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: InteractiveLabel {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<InteractiveLabelProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - ImageView

public struct ImageViewProperties<View: ImageView>: PropertyScope {
    public let alwaysUseOriginal = Property(\View.alwaysUseOriginal)
    public let ignoreBoundsChanges = Property(\View.ignoreBoundsChanges)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: ImageView {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<ImageViewProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

// MARK: - FavoritesButton

//public struct FavoritesButtonProperties<View: FavoritesButton>: PropertyScope {
//    public let contentInsets = Property(\View.contentInsets)
//}

//@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
//extension UIConfigurator where Wrapped: FavoritesButton {
//    @discardableResult
//    public func set<Path: PropertyPath>(
//        _ path: KeyPath<FavoritesButtonProperties<Wrapped>, Path>,
//        to value: Path.Value
//    ) -> Self where Wrapped == Path.Root {
//        set(value: value, to: path)
//    }
//}
//
//// MARK: - CounterView
//
//public struct CounterViewProperties<View: CounterView>: PropertyScope {
//    public let text = Property(\View.text)
//    public let isFractional = Property(\View.isFractional)
//    public let isError = Property(\View.isError)
//}
//
//@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
//extension UIConfigurator where Wrapped: CounterView {
//    @discardableResult
//    public func set<Path: PropertyPath>(
//        _ path: KeyPath<CounterViewProperties<Wrapped>, Path>,
//        to value: Path.Value
//    ) -> Self where Wrapped == Path.Root {
//        set(value: value, to: path)
//    }
//}

// MARK: - Button

public struct ButtonProperties<View: Button>: PropertyScope {
    public let title = Property(\View.title)
    public let subtitle = Property(\View.subtitle)
    public let image = Property(\View.image)
    public let highlightedImage = Property(\View.highlightedImage)
    public let textAlignment = Property(\View.textAlignment)
    public let isLoading = Property(\View.isLoading)
    public let additionalTouchInsets = Property(\View.additionalTouchInsets)
}

@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
extension UIConfigurator where Wrapped: Button {
    @discardableResult
    public func set<Path: PropertyPath>(
        _ path: KeyPath<ButtonProperties<Wrapped>, Path>,
        to value: Path.Value
    ) -> Self where Wrapped == Path.Root {
        set(value: value, to: path)
    }
}

//// MARK: - BadgeView
//
//public struct BadgeViewProperties<View: BadgeView>: PropertyScope {
//    public let style = Property(\View.style)
//    public let color = Property(\View.color)
//    public let textColor = Property(\View.textColor)
//    public let highlightedTextColor = Property(\View.highlightedTextColor)
//    public let text = Property(\View.text)
//    public let additionalTouchInsets = Property(\View.additionalTouchInsets)
//}
//
//@available(*, deprecated, message: "Используйте метод, соответствующий настраиваемому свойству")
//extension UIConfigurator where Wrapped: BadgeView {
//    @discardableResult
//    public func set<Path: PropertyPath>(
//        _ path: KeyPath<BadgeViewProperties<Wrapped>, Path>,
//        to value: Path.Value
//    ) -> Self where Wrapped == Path.Root {
//        set(value: value, to: path)
//    }
//}

// swiftlint:enable file_types_order

import QuartzCore

extension UIConfigurator where Wrapped: CALayer {
    /// The layer’s bounds rectangle. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func bounds(_ bounds: CGRect) -> Self {
        wrapped.bounds = bounds
        return self
    }

    /// The layer’s position in its superlayer’s coordinate space. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func position(_ position: CGPoint) -> Self {
        wrapped.position = position
        return self
    }

    /// The layer’s position on the z axis. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func zPosition(_ zPosition: CGFloat) -> Self {
        wrapped.zPosition = zPosition
        return self
    }

    /// Defines the anchor point of the layer's bounds rectangle. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func anchorPoint(_ anchorPoint: CGPoint) -> Self {
        wrapped.anchorPoint = anchorPoint
        return self
    }

    /// The anchor point for the layer’s position along the z axis. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func anchorPointZ(_ anchorPointZ: CGFloat) -> Self {
        wrapped.anchorPointZ = anchorPointZ
        return self
    }

    /// The transform applied to the layer’s contents. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func transform(_ transform: CATransform3D) -> Self {
        wrapped.transform = transform
        return self
    }

    /// The layer’s frame rectangle.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func frame(_ frame: CGRect) -> Self {
        wrapped.frame = frame
        return self
    }

    /// A Boolean indicating whether the layer is displayed. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isHidden(_ isHidden: Bool) -> Self {
        wrapped.isHidden = isHidden
        return self
    }

    /// A Boolean indicating whether the layer displays its content when facing away from the viewer. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isDoubleSided(_ isDoubleSided: Bool) -> Self {
        wrapped.isDoubleSided = isDoubleSided
        return self
    }

    /// A Boolean that indicates whether the geometry of the layer and its sublayers is flipped vertically.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isGeometryFlipped(_ isGeometryFlipped: Bool) -> Self {
        wrapped.isGeometryFlipped = isGeometryFlipped
        return self
    }

    /// Specifies the transform to apply to sublayers when rendering. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func sublayerTransform(_ sublayerTransform: CATransform3D) -> Self {
        wrapped.sublayerTransform = sublayerTransform
        return self
    }

    /// An optional layer whose alpha channel is used to mask the layer’s content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func mask(_ mask: CALayer?) -> Self {
        wrapped.mask = mask
        return self
    }

    /// A Boolean indicating whether sublayers are clipped to the layer’s bounds. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func masksToBounds(_ masksToBounds: Bool) -> Self {
        wrapped.masksToBounds = masksToBounds
        return self
    }

    /// An object that provides the contents of the layer. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contents(_ contents: Any?) -> Self {
        wrapped.contents = contents
        return self
    }

    /// The rectangle, in the unit coordinate space, that defines the portion of the layer’s contents
    /// that should be used. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentsRect(_ contentsRect: CGRect) -> Self {
        wrapped.contentsRect = contentsRect
        return self
    }

    /// A constant that specifies how the layer's contents are positioned or scaled within its bounds.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentsGravity(_ contentsGravity: CALayerContentsGravity) -> Self {
        wrapped.contentsGravity = contentsGravity
        return self
    }

    /// The scale factor applied to the layer.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentsScale(_ contentsScale: CGFloat) -> Self {
        wrapped.contentsScale = contentsScale
        return self
    }

    /// The rectangle that defines how the layer contents are scaled if the layer’s contents are resized. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentsCenter(_ contentsCenter: CGRect) -> Self {
        wrapped.contentsCenter = contentsCenter
        return self
    }

    /// A hint for the desired storage format of the layer contents.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentsFormat(_ contentsFormat: CALayerContentsFormat) -> Self {
        wrapped.contentsFormat = contentsFormat
        return self
    }

    /// The filter used when reducing the size of the content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func minificationFilter(_ minificationFilter: CALayerContentsFilter) -> Self {
        wrapped.minificationFilter = minificationFilter
        return self
    }

    /// The filter used when increasing the size of the content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func magnificationFilter(_ magnificationFilter: CALayerContentsFilter) -> Self {
        wrapped.magnificationFilter = magnificationFilter
        return self
    }

    /// The bias factor used by the minification filter to determine the levels of detail.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func minificationFilterBias(_ minificationFilterBias: Float) -> Self {
        wrapped.minificationFilterBias = minificationFilterBias
        return self
    }

    /// A Boolean value indicating whether the layer contains completely opaque content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isOpaque(_ isOpaque: Bool) -> Self {
        wrapped.isOpaque = isOpaque
        return self
    }

    /// A Boolean indicating whether the layer contents must be updated when its bounds rectangle changes.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func needsDisplayOnBoundsChange(_ needsDisplayOnBoundsChange: Bool) -> Self {
        wrapped.needsDisplayOnBoundsChange = needsDisplayOnBoundsChange
        return self
    }

    /// A Boolean indicating whether drawing commands are deferred and processed asynchronously in a background thread.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func drawsAsynchronously(_ drawsAsynchronously: Bool) -> Self {
        wrapped.drawsAsynchronously = drawsAsynchronously
        return self
    }

    /// A bitmask defining how the edges of the receiver are rasterized.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func edgeAntialiasingMask(_ edgeAntialiasingMask: CAEdgeAntialiasingMask) -> Self {
        wrapped.edgeAntialiasingMask = edgeAntialiasingMask
        return self
    }

    /// A Boolean indicating whether the layer is allowed to perform edge antialiasing.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func allowsEdgeAntialiasing(_ allowsEdgeAntialiasing: Bool) -> Self {
        wrapped.allowsEdgeAntialiasing = allowsEdgeAntialiasing
        return self
    }

    /// The background color of the receiver. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func backgroundColor(_ backgroundColor: CGColor?) -> Self {
        wrapped.backgroundColor = backgroundColor
        return self
    }

    /// The radius to use when drawing rounded corners for the layer’s background. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Parameters:
    ///   - cornerRadius: The radius to use when drawing rounded corners for the layer’s background
    ///   - cornerCurve: Defines the curve used for rendering the rounded corners of the layer
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func cornerRadius(_ cornerRadius: CGFloat, cornerCurve: CALayerCornerCurve = .continuous) -> Self {
        wrapped.cornerRadius = cornerRadius
        wrapped.cornerCurve = .continuous
        return self
    }

    /// Defines which of the four corners receives the masking when using `cornerRadius` property
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func maskedCorners(_ maskedCorners: CACornerMask) -> Self {
        wrapped.maskedCorners = maskedCorners
        return self
    }

    /// Defines the curve used for rendering the rounded corners of the layer.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func cornerCurve(_ cornerCurve: CALayerCornerCurve) -> Self {
        wrapped.cornerCurve = cornerCurve
        return self
    }

    /// The width of the layer’s border. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func borderWidth(_ borderWidth: CGFloat) -> Self {
        wrapped.borderWidth = borderWidth
        return self
    }

    /// The color of the layer’s border. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func borderColor(_ borderColor: CGColor?) -> Self {
        wrapped.borderColor = borderColor
        return self
    }

    /// The opacity of the receiver. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func opacity(_ opacity: Float) -> Self {
        wrapped.opacity = opacity
        return self
    }

    /// A Boolean indicating whether the layer is allowed to composite itself as a group separate from its parent.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func allowsGroupOpacity(_ allowsGroupOpacity: Bool) -> Self {
        wrapped.allowsGroupOpacity = allowsGroupOpacity
        return self
    }

    /// A CoreImage filter used to composite the layer and the content behind it. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func compositingFilter(_ compositingFilter: Any?) -> Self {
        wrapped.compositingFilter = compositingFilter
        return self
    }

    /// An array of Core Image filters to apply to the contents of the layer and its sublayers. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func filters(_ filters: [Any]?) -> Self {
        wrapped.filters = filters
        return self
    }

    /// An array of Core Image filters to apply to the content immediately behind the layer. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func backgroundFilters(_ backgroundFilters: [Any]?) -> Self {
        wrapped.backgroundFilters = backgroundFilters
        return self
    }

    /// A Boolean that indicates whether the layer is rendered as a bitmap before compositing. Animatable
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func shouldRasterize(_ shouldRasterize: Bool) -> Self {
        wrapped.shouldRasterize = shouldRasterize
        return self
    }

    /// The scale at which to rasterize content, relative to the coordinate space of the layer. Animatable
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func rasterizationScale(_ rasterizationScale: CGFloat) -> Self {
        wrapped.rasterizationScale = rasterizationScale
        return self
    }

    /// The color of the layer’s shadow. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func shadowColor(_ shadowColor: CGColor?) -> Self {
        wrapped.shadowColor = shadowColor
        return self
    }

    /// The opacity of the layer’s shadow. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func shadowOpacity(_ shadowOpacity: Float) -> Self {
        wrapped.shadowOpacity = shadowOpacity
        return self
    }

    /// The offset (in points) of the layer’s shadow. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func shadowOffset(_ shadowOffset: CGSize) -> Self {
        wrapped.shadowOffset = shadowOffset
        return self
    }

    /// The blur radius (in points) used to render the layer’s shadow. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func shadowRadius(_ shadowRadius: CGFloat) -> Self {
        wrapped.shadowRadius = shadowRadius
        return self
    }

    /// The shape of the layer’s shadow. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func shadowPath(_ shadowPath: CGPath?) -> Self {
        wrapped.shadowPath = shadowPath
        return self
    }

    /// A dictionary containing layer actions.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func actions(_ actions: [String: CAAction]?) -> Self {
        wrapped.actions = actions
        return self
    }

    /// The name of the receiver.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func name(_ name: String?) -> Self {
        wrapped.name = name
        return self
    }

    /// The layer’s delegate object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func delegate(_ delegate: CALayerDelegate?) -> Self {
        wrapped.delegate = delegate
        return self
    }

    /// An optional dictionary used to store property values that aren't explicitly defined by the layer.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func style(_ style: [AnyHashable: Any]?) -> Self {
        wrapped.style = style
        return self
    }
}

// MARK: - Methods

extension UIConfigurator where Wrapped: CALayer {
    /// Sets the layer’s transform to the specified affine transform.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func setAffineTransform(_ transform: CGAffineTransform) -> Self {
        wrapped.setAffineTransform(transform)
        return self
    }

    /// Appends the layer to the layer’s list of sublayers.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func addSublayer(_ layer: CALayer) -> Self {
        wrapped.addSublayer(layer)
        return self
    }

    /// Inserts the specified layer into the receiver’s list of sublayers at the specified index.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertSublayer(_ layer: CALayer, at idx: UInt32) -> Self {
        wrapped.insertSublayer(layer, at: idx)
        return self
    }

    /// Inserts the specified sublayer below a different sublayer that already belongs to the receiver.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertSublayer(_ layer: CALayer, below sibling: CALayer?) -> Self {
        wrapped.insertSublayer(layer, below: sibling)
        return self
    }

    /// Inserts the specified sublayer above a different sublayer that already belongs to the receiver.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertSublayer(_ layer: CALayer, above sibling: CALayer?) -> Self {
        wrapped.insertSublayer(layer, above: sibling)
        return self
    }

    /// Replaces the specified sublayer with a different layer object.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func replaceSublayer(_ oldLayer: CALayer, with newLayer: CALayer) -> Self {
        wrapped.replaceSublayer(oldLayer, with: newLayer)
        return self
    }

    /// Add the specified animation object to the layer’s render tree.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func add(_ anim: CAAnimation, forKey key: String?) -> Self {
        wrapped.add(anim, forKey: key)
        return self
    }
}


import UIKit

/// Протокол описывает объект, который поддерживает настройку UI с помощью цепочки действий
public protocol ConfigurableUI: AnyObject {}

extension ConfigurableUI {
    /// Свойство, оборачивающее объект в `UIConfigurator`
    public var ui: UIConfigurator<Self> {
        UIConfigurator(self)
    }
}

extension CALayer: ConfigurableUI {}
extension UIView: ConfigurableUI {}


import UIKit

/// Объект, который оборачивает визуальный элемент отображения и позволяет настраивать его с помощью цепочки действий
public struct UIConfigurator<Wrapped: ConfigurableUI> {
    let wrapped: Wrapped

    // MARK: Initialization

    init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    // MARK: Public

    /// Возвращает настроенный объект
    /// - Returns: Объект, настроенный с помощью цепочки действий
    public func make() -> Wrapped {
        wrapped
    }
}


import Foundation

/// Протокол содержит необходимые модулю данные, которые предоставляет приложение
public protocol EveryEventUIConfigurationProvider {
    /// Приложение запущено в Debug окружении
    var isDebugEnvironment: Bool { get }
    /// Максимальное количество единиц товара, которое можно положить в корзину
    var maximumQuantity: Int { get }
}

/// Конфигурация модуля
public enum EveryEventUIConfiguration {
    fileprivate static var provider: EveryEventUIConfigurationProvider!

    /// Настраивает модуль, предоставляя ему необходимые данные
    /// - Parameter provider: Объект, содержащий необходимые модулю данные
    public static func setup(with provider: EveryEventUIConfigurationProvider) {
        Self.provider = provider
    }
}

import Foundation

/// Объект, предоставляющий информацию о текущем окружении и настройках приложения
public enum Configuration {
    /// Информация о текущей языковой модели
    public static let locale = Locale(identifier: "ru_RU")
}


// MARK: -

extension Configuration {
    /// Приложение запущено в `Debug` окружении
    static var isDebugEnvironment: Bool { EveryEventUIConfiguration.provider.isDebugEnvironment }
    /// Максимальное количество единиц товара, которое можно положить в корзину
    static var maximumQuantity: Int { EveryEventUIConfiguration.provider.maximumQuantity }
}

import LinkPresentation
import UIKit
import UniformTypeIdentifiers

/// Обёртка над ссылкой для шторки "Поделиться".
/// При копировании и добавлении в список для чтении предоставляет просто ссылку,
/// для остальных действий форматирует под заданный формат
public final class SharingURL: NSObject, UIActivityItemSource {
    private let title: String
    private let url: URL
    private let formatter: ((String) -> String)?

    // MARK: Initialization

    /// Создаёт обёртку над ссылкой для шторки "Поделиться"
    /// - Parameters:
    ///   - title: Название ссылки
    ///   - url: Ссылка, которой нужно поделиться
    ///   - formatter: Замыкание принимает ссылку и возвращает текст, который будет передан в выполняемое действие
    public init(title: String, url: URL, formatter: ((_ url: String) -> String)? = nil) {
        self.title = title
        self.url = url
        self.formatter = formatter
    }

    // MARK: UIActivityItemSource

    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        title
    }

    public func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        guard let formatter else {
            return url
        }
        if activityType == .copyToPasteboard || activityType == .addToReadingList {
            return url
        }
        return formatter(url.absoluteString)
    }
}

extension UIConfigurator where Wrapped: UIView {
    /// Задаёт радиус и кривизну скругления углов для фона представления
    /// - Parameters:
    ///   - cornerRadius: Радиус, который используется для скругления углов
    ///   - cornerCurve: Определяет кривую, которая используется для скругления углов
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func cornerRadius(_ cornerRadius: CGFloat, cornerCurve: CALayerCornerCurve = .continuous) -> Self {
        wrapped.layer.ui.cornerRadius(cornerRadius, cornerCurve: cornerCurve)
        return self
    }

    /// Определяет, какой из четырех углов скругляется при использовании свойства `cornerRadius`
    ///
    /// По умолчанию все четыре угла
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func maskedCorners(_ maskedCorners: CACornerMask) -> Self {
        wrapped.layer.ui.maskedCorners(maskedCorners)
        return self
    }

    /// Ширина рамки вокруг представления
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func borderWidth(_ borderWidth: CGFloat) -> Self {
        wrapped.layer.ui.borderWidth(borderWidth)
        return self
    }

    /// Цвет рамки вокруг представления
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func borderColor(_ borderColor: UIColor?) -> Self {
        wrapped.layer.ui.borderColor(borderColor?.cgColor)
        return self
    }

    /// A Boolean value that determines whether user events are ignored and removed from the event queue.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isUserInteractionEnabled(_ isUserInteractionEnabled: Bool) -> Self {
        wrapped.isUserInteractionEnabled = isUserInteractionEnabled
        return self
    }

    /// An integer that you can use to identify view objects in your application.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func tag(_ tag: Int) -> Self {
        wrapped.tag = tag
        return self
    }

    /// The frame rectangle, which describes the view’s location and size in its superview’s coordinate system.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func frame(_ frame: CGRect) -> Self {
        wrapped.frame = frame
        return self
    }

    /// The bounds rectangle, which describes the view’s location and size in its own coordinate system.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func bounds(_ bounds: CGRect) -> Self {
        wrapped.bounds = bounds
        return self
    }

    /// The center point of the view's frame rectangle.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func center(_ center: CGPoint) -> Self {
        wrapped.center = center
        return self
    }

    /// Specifies the transform applied to the view, relative to the center of its bounds.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func transform(_ transform: CGAffineTransform) -> Self {
        wrapped.transform = transform
        return self
    }

    /// The three-dimensional transform to apply to the view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func transform3D(_ transform3D: CATransform3D) -> Self {
        wrapped.transform3D = transform3D
        return self
    }

    /// The scale factor applied to the view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentScaleFactor(_ contentScaleFactor: CGFloat) -> Self {
        wrapped.contentScaleFactor = contentScaleFactor
        return self
    }

    /// A Boolean value that indicates whether the view receives more than one touch at a time.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isMultipleTouchEnabled(_ isMultipleTouchEnabled: Bool) -> Self {
        wrapped.isMultipleTouchEnabled = isMultipleTouchEnabled
        return self
    }

    /// A Boolean value that indicates whether the receiver handles touch events exclusively.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isExclusiveTouch(_ isExclusiveTouch: Bool) -> Self {
        wrapped.isExclusiveTouch = isExclusiveTouch
        return self
    }

    /// A Boolean value that determines whether the receiver automatically resizes its subviews when its bounds change.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func autoresizesSubviews(_ autoresizesSubviews: Bool) -> Self {
        wrapped.autoresizesSubviews = autoresizesSubviews
        return self
    }

    /// An integer bit mask that determines how the receiver resizes itself when its superview’s bounds change.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func autoresizingMask(_ autoresizingMask: UIView.AutoresizingMask) -> Self {
        wrapped.autoresizingMask = autoresizingMask
        return self
    }

    /// The default spacing to use when laying out content in the view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func layoutMargins(_ layoutMargins: UIEdgeInsets) -> Self {
        wrapped.layoutMargins = layoutMargins
        return self
    }

    /// The default spacing to use when laying out content in a view,
    /// taking into account the current language direction.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func directionalLayoutMargins(_ directionalLayoutMargins: NSDirectionalEdgeInsets) -> Self {
        wrapped.directionalLayoutMargins = directionalLayoutMargins
        return self
    }

    /// A Boolean value indicating whether the current view also respects the margins of its superview.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func preservesSuperviewLayoutMargins(_ preservesSuperviewMargins: Bool) -> Self {
        wrapped.preservesSuperviewLayoutMargins = preservesSuperviewMargins
        return self
    }

    /// A Boolean value indicating whether the view's layout margins are updated automatically to reflect the safe area.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insetsLayoutMarginsFromSafeArea(_ insetsMarginsFromSafeArea: Bool) -> Self {
        wrapped.insetsLayoutMarginsFromSafeArea = insetsMarginsFromSafeArea
        return self
    }

    /// A Boolean value that determines whether subviews are confined to the bounds of the view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func clipsToBounds(_ clipsToBounds: Bool) -> Self {
        wrapped.clipsToBounds = clipsToBounds
        return self
    }

    /// The view’s background color.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func backgroundColor(_ backgroundColor: UIColor?) -> Self {
        wrapped.backgroundColor = backgroundColor
        return self
    }

    /// The view’s alpha value.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func alpha(_ alpha: CGFloat) -> Self {
        wrapped.alpha = alpha
        return self
    }

    /// A Boolean value that determines whether the view is opaque.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isOpaque(_ isOpaque: Bool) -> Self {
        wrapped.isOpaque = isOpaque
        return self
    }

    /// A Boolean value that determines whether the view’s bounds should be automatically cleared before drawing.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func clearsContextBeforeDrawing(_ clearsContextBeforeDrawing: Bool) -> Self {
        wrapped.clearsContextBeforeDrawing = clearsContextBeforeDrawing
        return self
    }

    /// A Boolean value that determines whether the view is hidden.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isHidden(_ isHidden: Bool) -> Self {
        wrapped.isHidden = isHidden
        return self
    }

    /// A flag used to determine how a view lays out its content when its bounds change.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentMode(_ contentMode: UIView.ContentMode) -> Self {
        wrapped.contentMode = contentMode
        return self
    }

    /// An optional view whose alpha channel is used to mask a view’s content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func mask(_ mask: UIView?) -> Self {
        wrapped.mask = mask
        return self
    }

    /// The first nondefault tint color value in the view’s hierarchy, ascending from and starting with the view itself.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func tintColor(_ tintColor: UIColor) -> Self {
        wrapped.tintColor = tintColor
        return self
    }

    /// The first non-default tint adjustment mode value in the view’s hierarchy,
    /// ascending from and starting with the view itself.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func tintAdjustmentMode(_ tintAdjustmentMode: UIView.TintAdjustmentMode) -> Self {
        wrapped.tintAdjustmentMode = tintAdjustmentMode
        return self
    }

    /// The user interface style adopted by the view and all of its subviews.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func overrideUserInterfaceStyle(_ overrideUserInterfaceStyle: UIUserInterfaceStyle) -> Self {
        wrapped.overrideUserInterfaceStyle = overrideUserInterfaceStyle
        return self
    }
}

// MARK: - Methods

extension UIConfigurator where Wrapped: UIView {
    /// Возвращает представление, настроенное для работы с `Auto Layout`
    ///
    /// Задаёт свойству `translatesAutoresizingMaskIntoConstraints` значение `false`.
    ///
    /// Подробности смотрите в документации к свойству `translatesAutoresizingMaskIntoConstraints`
    /// - Returns: Представление, настроенное для работы с `Auto Layout`
    @discardableResult
    public func forAutoLayout() -> Wrapped {
        wrapped.translatesAutoresizingMaskIntoConstraints = false
        return wrapped
    }

    /// Sets the priority with which a view resists being made larger than its intrinsic size.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func setContentHuggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        wrapped.setContentHuggingPriority(priority, for: axis)
        return self
    }

    /// Задаёт приоритет, с которым представление сопротивляется расширению, больше, чем у другого представления
    /// - Parameters:
    ///   - view: Представление, чей приоритет берётся за основу
    ///   - constant: Число, на которое должно быть изменено значение приоритета
    ///   - axis: Ось, для которой задаётся приоритет
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func setContentHuggingPriority(
        greaterThan view: UIView,
        constant: Float = 1,
        for axis: NSLayoutConstraint.Axis
    ) -> Self {
        let rawValue = max(min(view.contentHuggingPriority(for: axis).rawValue + constant, 1000), 1)
        wrapped.setContentHuggingPriority(UILayoutPriority(rawValue), for: axis)
        return self
    }

    /// Задаёт приоритет, с которым представление сопротивляется расширению, меньше, чем у другого представления
    /// - Parameters:
    ///   - view: Представление, чей приоритет берётся за основу
    ///   - constant: Число, на которое должно быть изменено значение приоритета
    ///   - axis: Ось, для которой задаётся приоритет
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func setContentHuggingPriority(
        lessThan view: UIView,
        constant: Float = 1,
        for axis: NSLayoutConstraint.Axis
    ) -> Self {
        setContentHuggingPriority(greaterThan: view, constant: -constant, for: axis)
    }

    /// Sets the priority with which a view resists being made smaller than its intrinsic size.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func setContentCompressionResistancePriority(
        _ priority: UILayoutPriority,
        for axis: NSLayoutConstraint.Axis
    ) -> Self {
        wrapped.setContentCompressionResistancePriority(priority, for: axis)
        return self
    }

    /// Задаёт приоритет, с которым представление сопротивляется сжатию, больше, чем у другого представления
    /// - Parameters:
    ///   - view: Представление, чей приоритет берётся за основу
    ///   - constant: Число, на которое должно быть изменено значение приоритета
    ///   - axis: Ось, для которой задаётся приоритет
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func setContentCompressionResistancePriority(
        greaterThan view: UIView,
        constant: Float = 1,
        for axis: NSLayoutConstraint.Axis
    ) -> Self {
        let rawValue = max(min(view.contentCompressionResistancePriority(for: axis).rawValue + constant, 1000), 1)
        wrapped.setContentCompressionResistancePriority(UILayoutPriority(rawValue), for: axis)
        return self
    }

    /// Задаёт приоритет, с которым представление сопротивляется сжатию, меньше, чем у другого представления
    /// - Parameters:
    ///   - view: Представление, чей приоритет берётся за основу
    ///   - constant: Число, на которое должно быть изменено значение приоритета
    ///   - axis: Ось, для которой задаётся приоритет
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func setContentCompressionResistancePriority(
        lessThan view: UIView,
        constant: Float = 1,
        for axis: NSLayoutConstraint.Axis
    ) -> Self {
        setContentCompressionResistancePriority(greaterThan: view, constant: -constant, for: axis)
    }

    /// Resizes and moves the receiver view so it just encloses its subviews.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func sizeToFit() -> Wrapped {
        wrapped.sizeToFit()
        return wrapped
    }

    /// Adds a view to the end of the receiver’s list of subviews.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func addSubview(_ view: UIView) -> Self {
        wrapped.addSubview(view)
        return self
    }

    /// Adds an array of views to the end of the receiver’s list of subviews.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func addSubviews(_ views: [UIView]) -> Self {
        views.forEach { wrapped.addSubview($0) }
        return self
    }

    /// Inserts a subview at the specified index.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertSubview(_ view: UIView, at index: Int) -> Self {
        wrapped.insertSubview(view, at: index)
        return self
    }

    /// Inserts an array of subviews at the specified index.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertSubviews(_ views: [UIView], at index: Int) -> Self {
        views.enumerated().forEach { wrapped.insertSubview($0.element, at: index + $0.offset) }
        return self
    }

    /// Inserts a view below another view in the view hierarchy.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertSubview(_ view: UIView, belowSubview siblingSubview: UIView) -> Self {
        wrapped.insertSubview(view, belowSubview: siblingSubview)
        return self
    }

    /// Inserts an array of views below another view in the view hierarchy.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertSubviews(_ views: [UIView], belowSubview siblingSubview: UIView) -> Self {
        views.forEach { wrapped.insertSubview($0, belowSubview: siblingSubview) }
        return self
    }

    /// Inserts a view above another view in the view hierarchy.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) -> Self {
        wrapped.insertSubview(view, aboveSubview: siblingSubview)
        return self
    }

    /// Inserts an array of views above another view in the view hierarchy.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertSubviews(_ views: [UIView], aboveSubview siblingSubview: UIView) -> Self {
        views.reversed().forEach { wrapped.insertSubview($0, aboveSubview: siblingSubview) }
        return self
    }

    /// Exchanges the subviews at the specified indices.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func exchangeSubview(at index1: Int, withSubviewAt index2: Int) -> Self {
        wrapped.exchangeSubview(at: index1, withSubviewAt: index2)
        return self
    }

    /// Moves the specified subview so that it appears on top of its siblings.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func bringSubviewToFront(_ view: UIView) -> Self {
        wrapped.bringSubviewToFront(view)
        return self
    }

    /// Moves the specified subview so that it appears behind its siblings.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func sendSubviewToBack(_ view: UIView) -> Self {
        wrapped.sendSubviewToBack(view)
        return self
    }

    /// Adds the specified layout guide to the view.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func addLayoutGuide(_ layoutGuide: UILayoutGuide) -> Self {
        wrapped.addLayoutGuide(layoutGuide)
        return self
    }
}

extension UIConfigurator where Wrapped: UITextView {
    /// The text view’s delegate.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func delegate(_ delegate: UITextViewDelegate?) -> Self {
        wrapped.delegate = delegate
        return self
    }

    /// The text that the text view displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Parameters:
    ///   - text: Текст, который должен отображаться в поле
    ///   - style: Стиль, в котором поле должно отображать текст
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func text(_ text: String, style: TextStyle? = nil) -> Self {
        if let style {
            let attributes = style.attributes(for: wrapped, usingFont: true)
            wrapped.attributedText = AttributedString(text, attributes: attributes).nsAttributedString
        } else {
            wrapped.text = text
        }
        return self
    }

    /// The font of the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func font(_ font: UIFont?) -> Self {
        wrapped.font = font
        return self
    }

    /// The color of the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textColor(_ textColor: UIColor?) -> Self {
        wrapped.textColor = textColor
        return self
    }

    /// The technique for aligning the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        wrapped.textAlignment = textAlignment
        return self
    }

    /// The current selection range of the text view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func selectedRange(_ selectedRange: NSRange) -> Self {
        wrapped.selectedRange = selectedRange
        return self
    }

    /// A Boolean value that indicates whether the text view is editable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isEditable(_ isEditable: Bool) -> Self {
        wrapped.isEditable = isEditable
        return self
    }

    /// A Boolean value that indicates whether the text view is selectable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isSelectable(_ isSelectable: Bool) -> Self {
        wrapped.isSelectable = isSelectable
        return self
    }

    /// The types of data that convert to tappable URLs in the text view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func dataDetectorTypes(_ dataDetectorTypes: UIDataDetectorTypes) -> Self {
        wrapped.dataDetectorTypes = dataDetectorTypes
        return self
    }

    /// A Boolean value that indicates whether the text view allows the user to edit style information.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func allowsEditingTextAttributes(_ allowsEditingTextAttributes: Bool) -> Self {
        wrapped.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }

    /// The styled text that the text view displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func attributedText(_ attributedText: AttributedString) -> Self {
        wrapped.attributedText = attributedText.nsAttributedString
        return self
    }

    /// The attributes to apply to new text that the user enters.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func typingAttributes(_ typingAttributes: AttributeContainer) -> Self {
        wrapped.typingAttributes = typingAttributes.asDictionary
        return self
    }

    /// The custom input view to display when the text view becomes the first responder.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func inputView(_ inputView: UIView?) -> Self {
        wrapped.inputView = inputView
        return self
    }

    /// The custom accessory view to display when the text view becomes the first responder.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func inputAccessoryView(_ inputAccessoryView: UIView?) -> Self {
        wrapped.inputAccessoryView = inputAccessoryView
        return self
    }

    /// A Boolean value that indicates whether inserting text replaces the previous contents.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func clearsOnInsertion(_ clearsOnInsertion: Bool) -> Self {
        wrapped.clearsOnInsertion = clearsOnInsertion
        return self
    }

    /// The inset of the text container's layout area within the text view's content area.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textContainerInset(_ textContainerInset: UIEdgeInsets) -> Self {
        wrapped.textContainerInset = textContainerInset
        return self
    }

    /// The attributes to apply to links.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func linkTextAttributes(_ linkTextAttributes: AttributeContainer) -> Self {
        wrapped.linkTextAttributes = linkTextAttributes.asDictionary
        return self
    }

    /// A Boolean value that determines the rendering scale of the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func usesStandardTextScaling(_ usesStandardTextScaling: Bool) -> Self {
        wrapped.usesStandardTextScaling = usesStandardTextScaling
        return self
    }

    /// The autocapitalization style for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func autocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        wrapped.autocapitalizationType = autocapitalizationType
        return self
    }

    /// The autocorrection style for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func autocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
        wrapped.autocorrectionType = autocorrectionType
        return self
    }

    /// The spell-checking style for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func spellCheckingType(_ spellCheckingType: UITextSpellCheckingType) -> Self {
        wrapped.spellCheckingType = spellCheckingType
        return self
    }

    /// The configuration state for smart quotes.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func smartQuotesType(_ smartQuotesType: UITextSmartQuotesType) -> Self {
        wrapped.smartQuotesType = smartQuotesType
        return self
    }

    /// The configuration state for smart dashes.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func smartDashesType(_ smartDashesType: UITextSmartDashesType) -> Self {
        wrapped.smartDashesType = smartDashesType
        return self
    }

    /// The configuration state for the smart insertion and deletion of space characters.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func smartInsertDeleteType(_ smartInsertDeleteType: UITextSmartInsertDeleteType) -> Self {
        wrapped.smartInsertDeleteType = smartInsertDeleteType
        return self
    }

    /// The keyboard type for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        wrapped.keyboardType = keyboardType
        return self
    }

    /// The appearance style of the keyboard for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func keyboardAppearance(_ keyboardAppearance: UIKeyboardAppearance) -> Self {
        wrapped.keyboardAppearance = keyboardAppearance
        return self
    }

    /// The visible title of the Return key.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        wrapped.returnKeyType = returnKeyType
        return self
    }

    /// A Boolean value that indicates whether the system automatically enables the Return key
    /// when the user is enters text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func enablesReturnKeyAutomatically(_ enablesReturnKey: Bool) -> Self {
        wrapped.enablesReturnKeyAutomatically = enablesReturnKey
        return self
    }

    /// A Boolean value that indicates whether a text object disables copying,
    /// and in some cases, prevents recording/broadcasting and also hides the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isSecureTextEntry(_ isSecureTextEntry: Bool) -> Self {
        wrapped.isSecureTextEntry = isSecureTextEntry
        return self
    }

    /// The semantic meaning for a text input area.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textContentType(_ textContentType: UITextContentType) -> Self {
        wrapped.textContentType = textContentType
        return self
    }

    /// Requirements for passwords for your service to ensure iOS can generate compatible passwords for users.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func passwordRules(_ passwordRules: UITextInputPasswordRules?) -> Self {
        wrapped.passwordRules = passwordRules
        return self
    }
}

extension UIConfigurator where Wrapped: UITextField {
    /// The text that the text field displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Parameters:
    ///   - text: Текст, который должен отображаться в поле
    ///   - style: Стиль, в котором поле должно отображать текст
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func text(_ text: String?, style: TextStyle? = nil) -> Self {
        if let text, let style {
            let attributes = style.attributes(for: wrapped, usingFont: true)
            wrapped.attributedText = AttributedString(text, attributes: attributes).nsAttributedString
        } else {
            wrapped.text = text
        }
        return self
    }

    /// The styled text that the text field displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func attributedText(_ attributedText: AttributedString?) -> Self {
        wrapped.attributedText = attributedText?.nsAttributedString
        return self
    }

    /// The color of the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textColor(_ textColor: UIColor?) -> Self {
        wrapped.textColor = textColor
        return self
    }

    /// The font of the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func font(_ font: UIFont?) -> Self {
        wrapped.font = font
        return self
    }

    /// The technique for aligning the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        wrapped.textAlignment = textAlignment
        return self
    }

    /// The border style for the text field.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func borderStyle(_ borderStyle: UITextField.BorderStyle) -> Self {
        wrapped.borderStyle = borderStyle
        return self
    }

    /// The default attributes to apply to the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func defaultTextAttributes(_ defaultTextAttributes: AttributeContainer) -> Self {
        wrapped.defaultTextAttributes = defaultTextAttributes.asDictionary
        return self
    }

    /// The string that displays when there is no other text in the text field.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func placeholder(_ placeholder: String?) -> Self {
        wrapped.placeholder = placeholder
        return self
    }

    /// The styled string that displays when there is no other text in the text field.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func attributedPlaceholder(_ attributedPlaceholder: AttributedString?) -> Self {
        wrapped.attributedPlaceholder = attributedPlaceholder?.nsAttributedString
        return self
    }

    /// A Boolean value that determines whether the text field removes old text when editing begins.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func clearsOnBeginEditing(_ clearsOnBeginEditing: Bool) -> Self {
        wrapped.clearsOnBeginEditing = clearsOnBeginEditing
        return self
    }

    /// A Boolean value that indicates whether to reduce the font size to fit the text string
    /// into the text field’s bounding rectangle.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> Self {
        wrapped.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }

    /// The size of the smallest permissible font when drawing the text field’s text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func minimumFontSize(_ minimumFontSize: CGFloat) -> Self {
        wrapped.minimumFontSize = minimumFontSize
        return self
    }

    /// The text field’s delegate.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func delegate(_ delegate: UITextFieldDelegate?) -> Self {
        wrapped.delegate = delegate
        return self
    }

    /// The image that represents the background appearance of the text field when it is in an enabled state.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func background(_ background: UIImage?) -> Self {
        wrapped.background = background
        return self
    }

    /// The image that represents the background appearance of the text field when it is in a disabled state.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func disabledBackground(_ disabledBackground: UIImage?) -> Self {
        wrapped.disabledBackground = disabledBackground
        return self
    }

    /// A Boolean value that determines whether the user can edit the attributes of the text in the text field.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func allowsEditingTextAttributes(_ allowsEditingTextAttributes: Bool) -> Self {
        wrapped.allowsEditingTextAttributes = allowsEditingTextAttributes
        return self
    }

    /// The attributes to apply to new text that the user enters.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func typingAttributes(_ typingAttributes: AttributeContainer?) -> Self {
        wrapped.typingAttributes = typingAttributes?.asDictionary
        return self
    }

    /// A mode that controls when the standard Clear button appears in the text field.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func clearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> Self {
        wrapped.clearButtonMode = clearButtonMode
        return self
    }

    /// The overlay view that displays on the left (or leading) side of the text field.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func leftView(_ leftView: UIView?) -> Self {
        wrapped.leftView = leftView
        return self
    }

    /// A mode that controls when the left overlay view appears in the text field.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func leftViewMode(_ leftViewMode: UITextField.ViewMode) -> Self {
        wrapped.leftViewMode = leftViewMode
        return self
    }

    /// The overlay view that displays on the right (or trailing) side of the text field.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func rightView(_ rightView: UIView?) -> Self {
        wrapped.rightView = rightView
        return self
    }

    /// The overlay view that displays on the right (or trailing) side of the text field.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func rightViewMode(_ rightViewMode: UITextField.ViewMode) -> Self {
        wrapped.rightViewMode = rightViewMode
        return self
    }

    /// The custom input view to display when the text field becomes the first responder.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func inputView(_ inputView: UIView?) -> Self {
        wrapped.inputView = inputView
        return self
    }

    /// The custom accessory view to display when the text field becomes the first responder.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func inputAccessoryView(_ inputAccessoryView: UIView?) -> Self {
        wrapped.inputAccessoryView = inputAccessoryView
        return self
    }

    /// A Boolean value that determines whether inserting text replaces the previous contents.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func clearsOnInsertion(_ clearsOnInsertion: Bool) -> Self {
        wrapped.clearsOnInsertion = clearsOnInsertion
        return self
    }

    /// The autocapitalization style for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func autocapitalizationType(_ autocapitalizationType: UITextAutocapitalizationType) -> Self {
        wrapped.autocapitalizationType = autocapitalizationType
        return self
    }

    /// The autocorrection style for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func autocorrectionType(_ autocorrectionType: UITextAutocorrectionType) -> Self {
        wrapped.autocorrectionType = autocorrectionType
        return self
    }

    /// The spell-checking style for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func spellCheckingType(_ spellCheckingType: UITextSpellCheckingType) -> Self {
        wrapped.spellCheckingType = spellCheckingType
        return self
    }

    /// The configuration state for smart quotes.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func smartQuotesType(_ smartQuotesType: UITextSmartQuotesType) -> Self {
        wrapped.smartQuotesType = smartQuotesType
        return self
    }

    /// The configuration state for smart dashes.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func smartDashesType(_ smartDashesType: UITextSmartDashesType) -> Self {
        wrapped.smartDashesType = smartDashesType
        return self
    }

    /// The configuration state for the smart insertion and deletion of space characters.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func smartInsertDeleteType(_ smartInsertDeleteType: UITextSmartInsertDeleteType) -> Self {
        wrapped.smartInsertDeleteType = smartInsertDeleteType
        return self
    }

    /// The keyboard type for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        wrapped.keyboardType = keyboardType
        return self
    }

    /// The appearance style of the keyboard for the text object.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func keyboardAppearance(_ keyboardAppearance: UIKeyboardAppearance) -> Self {
        wrapped.keyboardAppearance = keyboardAppearance
        return self
    }

    /// The visible title of the Return key.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func returnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        wrapped.returnKeyType = returnKeyType
        return self
    }

    /// A Boolean value that indicates whether the system automatically enables the Return key
    /// when the user is enters text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func enablesReturnKeyAutomatically(_ enablesReturnKey: Bool) -> Self {
        wrapped.enablesReturnKeyAutomatically = enablesReturnKey
        return self
    }

    /// A Boolean value that indicates whether a text object disables copying,
    /// and in some cases, prevents recording/broadcasting and also hides the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isSecureTextEntry(_ isSecureTextEntry: Bool) -> Self {
        wrapped.isSecureTextEntry = isSecureTextEntry
        return self
    }

    /// The semantic meaning for a text input area.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textContentType(_ textContentType: UITextContentType) -> Self {
        wrapped.textContentType = textContentType
        return self
    }

    /// Requirements for passwords for your service to ensure iOS can generate compatible passwords for users.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func passwordRules(_ passwordRules: UITextInputPasswordRules?) -> Self {
        wrapped.passwordRules = passwordRules
        return self
    }
}

extension UIConfigurator where Wrapped: UIStackView {
    /// The axis along which the arranged views lay out.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        wrapped.axis = axis
        return self
    }

    /// The distribution of the arranged views along the stack view’s axis.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func distribution(_ distribution: UIStackView.Distribution) -> Self {
        wrapped.distribution = distribution
        return self
    }

    /// The alignment of the arranged subviews perpendicular to the stack view’s axis.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func alignment(_ alignment: UIStackView.Alignment) -> Self {
        wrapped.alignment = alignment
        return self
    }

    /// The distance in points between the adjacent edges of the stack view’s arranged views.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func spacing(_ spacing: CGFloat) -> Self {
        wrapped.spacing = spacing
        return self
    }

    /// A Boolean value that determines whether the vertical spacing between views is measured from their baselines.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isBaselineRelativeArrangement(_ isBaseline: Bool) -> Self {
        wrapped.isBaselineRelativeArrangement = isBaseline
        return self
    }

    /// A Boolean value that determines whether the stack view lays out its arranged views relative
    /// to its layout margins.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isLayoutMarginsRelativeArrangement(_ isLayoutMargins: Bool) -> Self {
        wrapped.isLayoutMarginsRelativeArrangement = isLayoutMargins
        return self
    }
}

// MARK: - Methods

extension UIConfigurator where Wrapped: UIStackView {
    /// Adds a view to the end of the arranged subviews array.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func addArrangedSubview(_ view: UIView) -> Self {
        wrapped.addArrangedSubview(view)
        return self
    }

    /// Adds an array of views to the end of the arranged subviews array.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func addArrangedSubviews(_ views: [UIView]) -> Self {
        views.forEach { wrapped.addArrangedSubview($0) }
        return self
    }

    /// Adds the provided view to the array of arranged subviews at the specified index.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertArrangedSubview(_ view: UIView, at stackIndex: Int) -> Self {
        wrapped.insertArrangedSubview(view, at: stackIndex)
        return self
    }

    /// Adds the provided array of views to the array of arranged subviews at the specified index.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func insertArrangedSubviews(_ views: [UIView], at stackIndex: Int) -> Self {
        views.enumerated().forEach { wrapped.insertArrangedSubview($0.element, at: stackIndex + $0.offset) }
        return self
    }

    /// Applies custom spacing after the specified view.
    ///
    /// Подробности смотрите в документации к методу
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func setSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) -> Self {
        wrapped.setCustomSpacing(spacing, after: arrangedSubview)
        return self
    }
}

extension UIConfigurator where Wrapped: UIScrollView {
    /// The point at which the origin of the content view is offset from the origin of the scroll view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentOffset(_ contentOffset: CGPoint) -> Self {
        wrapped.contentOffset = contentOffset
        return self
    }

    /// The size of the content view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentSize(_ contentSize: CGSize) -> Self {
        wrapped.contentSize = contentSize
        return self
    }

    /// The custom distance that the content view is inset from the safe area or scroll view edges.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentInset(_ contentInset: UIEdgeInsets) -> Self {
        wrapped.contentInset = contentInset
        return self
    }

    /// The behavior for determining the adjusted content offsets.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentInsetAdjustmentBehavior(_ behavior: UIScrollView.ContentInsetAdjustmentBehavior) -> Self {
        wrapped.contentInsetAdjustmentBehavior = behavior
        return self
    }

    /// A Boolean value that indicates whether the system automatically adjusts the scroll indicator insets.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func automaticallyAdjustsScrollIndicatorInsets(_ automaticallyAdjustsInsets: Bool) -> Self {
        wrapped.automaticallyAdjustsScrollIndicatorInsets = automaticallyAdjustsInsets
        return self
    }

    /// The delegate of the scroll view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func delegate(_ delegate: UIScrollViewDelegate?) -> Self {
        wrapped.delegate = delegate
        return self
    }

    /// A Boolean value that determines whether scrolling is disabled in a particular direction.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isDirectionalLockEnabled(_ isDirectionalLockEnabled: Bool) -> Self {
        wrapped.isDirectionalLockEnabled = isDirectionalLockEnabled
        return self
    }

    /// A Boolean value that controls whether the scroll view bounces past the edge of content and back again.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func bounces(_ bounces: Bool) -> Self {
        wrapped.bounces = bounces
        return self
    }

    /// A Boolean value that determines whether bouncing always occurs
    /// when vertical scrolling reaches the end of the content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func alwaysBounceVertical(_ alwaysBounceVertical: Bool) -> Self {
        wrapped.alwaysBounceVertical = alwaysBounceVertical
        return self
    }

    /// A Boolean value that determines whether bouncing always occurs
    /// when horizontal scrolling reaches the end of the content view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func alwaysBounceHorizontal(_ alwaysBounceHorizontal: Bool) -> Self {
        wrapped.alwaysBounceHorizontal = alwaysBounceHorizontal
        return self
    }

    /// A Boolean value that determines whether paging is enabled for the scroll view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isPagingEnabled(_ isPagingEnabled: Bool) -> Self {
        wrapped.isPagingEnabled = isPagingEnabled
        return self
    }

    /// A Boolean value that determines whether scrolling is enabled.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isScrollEnabled(_ isScrollEnabled: Bool) -> Self {
        wrapped.isScrollEnabled = isScrollEnabled
        return self
    }

    /// A Boolean value that controls whether the vertical scroll indicator is visible.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func showsVerticalScrollIndicator(_ showsVerticalScrollIndicator: Bool) -> Self {
        wrapped.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        return self
    }

    /// A Boolean value that controls whether the horizontal scroll indicator is visible.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func showsHorizontalScrollIndicator(_ showsHorizontalIndicator: Bool) -> Self {
        wrapped.showsHorizontalScrollIndicator = showsHorizontalIndicator
        return self
    }

    /// The style of the scroll indicators.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func indicatorStyle(_ indicatorStyle: UIScrollView.IndicatorStyle) -> Self {
        wrapped.indicatorStyle = indicatorStyle
        return self
    }

    /// The vertical distance the scroll indicators are inset from the edge of the scroll view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func verticalScrollIndicatorInsets(_ verticalIndicatorInsets: UIEdgeInsets) -> Self {
        wrapped.verticalScrollIndicatorInsets = verticalIndicatorInsets
        return self
    }

    /// The horizontal distance the scroll indicators are inset from the edge of the scroll view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func horizontalScrollIndicatorInsets(_ horizontalIndicatorInsets: UIEdgeInsets) -> Self {
        wrapped.horizontalScrollIndicatorInsets = horizontalIndicatorInsets
        return self
    }

    /// The distance the scroll indicators are inset from the edge of the scroll view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func scrollIndicatorInsets(_ scrollIndicatorInsets: UIEdgeInsets) -> Self {
        wrapped.scrollIndicatorInsets = scrollIndicatorInsets
        return self
    }

    /// A floating-point value that determines the rate of deceleration after the user lifts their finger.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func decelerationRate(_ decelerationRate: UIScrollView.DecelerationRate) -> Self {
        wrapped.decelerationRate = decelerationRate
        return self
    }

    /// The manner in which the index appears while the user is scrolling.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func indexDisplayMode(_ indexDisplayMode: UIScrollView.IndexDisplayMode) -> Self {
        wrapped.indexDisplayMode = indexDisplayMode
        return self
    }

    /// A Boolean value that determines whether the scroll view delays the handling of touch-down gestures.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func delaysContentTouches(_ delaysContentTouches: Bool) -> Self {
        wrapped.delaysContentTouches = delaysContentTouches
        return self
    }

    /// A Boolean value that controls whether touches in the content view always lead to tracking.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func canCancelContentTouches(_ canCancelContentTouches: Bool) -> Self {
        wrapped.canCancelContentTouches = canCancelContentTouches
        return self
    }

    /// A floating-point value that specifies the minimum scale factor that can apply to the scroll view’s content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func minimumZoomScale(_ minimumZoomScale: CGFloat) -> Self {
        wrapped.minimumZoomScale = minimumZoomScale
        return self
    }

    /// A floating-point value that specifies the maximum scale factor that can apply to the scroll view’s content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func maximumZoomScale(_ maximumZoomScale: CGFloat) -> Self {
        wrapped.maximumZoomScale = maximumZoomScale
        return self
    }

    /// A floating-point value that specifies the current scale factor applied to the scroll view’s content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func zoomScale(_ zoomScale: CGFloat) -> Self {
        wrapped.zoomScale = zoomScale
        return self
    }

    /// A Boolean value that determines whether the scroll view animates the content scaling
    /// when the scaling exceeds the maximum or minimum limits.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func bouncesZoom(_ bouncesZoom: Bool) -> Self {
        wrapped.bouncesZoom = bouncesZoom
        return self
    }

    /// A Boolean value that controls whether the scroll-to-top gesture is enabled.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func scrollsToTop(_ scrollsToTop: Bool) -> Self {
        wrapped.scrollsToTop = scrollsToTop
        return self
    }

    /// The manner in which the system dismisses the keyboard when a drag begins in the scroll view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func keyboardDismissMode(_ keyboardDismissMode: UIScrollView.KeyboardDismissMode) -> Self {
        wrapped.keyboardDismissMode = keyboardDismissMode
        return self
    }

    /// The refresh control associated with the scroll view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func refreshControl(_ refreshControl: UIRefreshControl?) -> Self {
        wrapped.refreshControl = refreshControl
        return self
    }
}

extension UIConfigurator where Wrapped: UIProgressView {
    /// The current graphical style of the progress view
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func progressViewStyle(_ progressViewStyle: UIProgressView.Style) -> Self {
        wrapped.progressViewStyle = progressViewStyle
        wrapped.progressViewStyle = .default
        return self
    }

    /// The current progress of the progress view
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func progress(_ progress: Float) -> Self {
        wrapped.progress = progress
        return self
    }

    /// The color shown for the portion of the progress bar that’s filled
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func progressTintColor(_ progressTintColor: UIColor?) -> Self {
        wrapped.progressTintColor = progressTintColor
        return self
    }

    /// The color shown for the portion of the progress bar that isn’t filled
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func trackTintColor(_ trackTintColor: UIColor?) -> Self {
        wrapped.trackTintColor = trackTintColor
        return self
    }
}

extension UIConfigurator where Wrapped: UILabel {
    /// The text that the label displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Parameters:
    ///   - text: Текст, который должен отображаться в поле
    ///   - style: Стиль, в котором поле должно отображать текст
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func text(_ text: String?, style: TextStyle? = nil) -> Self {
        if let text, let style {
            let attributes = style.attributes(for: wrapped, usingFont: true)
            wrapped.attributedText = AttributedString(text, attributes: attributes).nsAttributedString
        } else {
            wrapped.text = text
        }
        return self
    }

    /// The font of the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        wrapped.font = font
        return self
    }

    /// The color of the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textColor(_ textColor: UIColor) -> Self {
        wrapped.textColor = textColor
        return self
    }

    /// The shadow color of the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func shadowColor(_ shadowColor: UIColor?) -> Self {
        wrapped.shadowColor = shadowColor
        return self
    }

    /// The shadow offset, in points, for the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func shadowOffset(_ shadowOffset: CGSize) -> Self {
        wrapped.shadowOffset = shadowOffset
        return self
    }

    /// The technique for aligning the text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textAlignment(_ textAlignment: NSTextAlignment) -> Self {
        wrapped.textAlignment = textAlignment
        return self
    }

    /// The technique for wrapping and truncating the label’s text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func lineBreakMode(_ lineBreakMode: NSLineBreakMode) -> Self {
        wrapped.lineBreakMode = lineBreakMode
        return self
    }

    /// The styled text that the label displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func attributedText(_ attributedText: AttributedString?) -> Self {
        wrapped.attributedText = attributedText?.nsAttributedString
        return self
    }

    /// The highlight color for the label’s text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func highlightedTextColor(_ highlightedTextColor: UIColor?) -> Self {
        wrapped.highlightedTextColor = highlightedTextColor
        return self
    }

    /// A Boolean value that determines whether the label draws its text with a highlight.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isHighlighted(_ isHighlighted: Bool) -> Self {
        wrapped.isHighlighted = isHighlighted
        return self
    }

    /// A Boolean value that determines whether the label draws its text in an enabled state.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isEnabled(_ isEnabled: Bool) -> Self {
        wrapped.isEnabled = isEnabled
        return self
    }

    /// The maximum number of lines for rendering text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func numberOfLines(_ numberOfLines: Int) -> Self {
        wrapped.numberOfLines = numberOfLines
        return self
    }

    /// A Boolean value that determines whether the label reduces the text’s font size to fit the title string
    /// into the label’s bounding rectangle.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Bool) -> Self {
        wrapped.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return self
    }

    /// An option that controls whether the text’s baseline remains fixed when text needs to shrink to fit in the label.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func baselineAdjustment(_ baselineAdjustment: UIBaselineAdjustment) -> Self {
        wrapped.baselineAdjustment = baselineAdjustment
        return self
    }

    /// The minimum scale factor for the label’s text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func minimumScaleFactor(_ minimumScaleFactor: CGFloat) -> Self {
        wrapped.minimumScaleFactor = minimumScaleFactor
        return self
    }

    /// A Boolean value that determines whether the label tightens text before truncating.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func allowsDefaultTighteningForTruncation(_ allowsDefaultTightening: Bool) -> Self {
        wrapped.allowsDefaultTighteningForTruncation = allowsDefaultTightening
        return self
    }

    /// The strategy that the system uses to break lines when laying out multiple lines of text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func lineBreakStrategy(_ lineBreakStrategy: NSParagraphStyle.LineBreakStrategy) -> Self {
        wrapped.lineBreakStrategy = lineBreakStrategy
        return self
    }

    /// The preferred maximum width, in points, for a multiline label.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func preferredMaxLayoutWidth(_ preferredMaxLayoutWidth: CGFloat) -> Self {
        wrapped.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        return self
    }
}

extension UIConfigurator where Wrapped: UIImageView {
    /// The image displayed in the image view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        wrapped.image = image
        return self
    }

    /// The highlighted image displayed in the image view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func highlightedImage(_ highlightedImage: UIImage?) -> Self {
        wrapped.highlightedImage = highlightedImage
        return self
    }

    /// A Boolean value that determines whether the image is highlighted.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isHighlighted(_ isHighlighted: Bool) -> Self {
        wrapped.isHighlighted = isHighlighted
        return self
    }

    /// An array of UIImage objects to use for an animation.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func animationImages(_ animationImages: [UIImage]?) -> Self {
        wrapped.animationImages = animationImages
        return self
    }

    /// An array of UIImage objects to use for an animation when the view is highlighted.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func highlightedAnimationImages(_ highlightedAnimationImages: [UIImage]?) -> Self {
        wrapped.highlightedAnimationImages = highlightedAnimationImages
        return self
    }

    /// The amount of time it takes to go through one cycle of the images.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func animationDuration(_ animationDuration: TimeInterval) -> Self {
        wrapped.animationDuration = animationDuration
        return self
    }

    /// Specifies the number of times to repeat the animation.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func animationRepeatCount(_ animationRepeatCount: Int) -> Self {
        wrapped.animationRepeatCount = animationRepeatCount
        return self
    }
}

extension UIConfigurator where Wrapped: UIControl {
    /// A Boolean value indicating whether the control is in the enabled state.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isEnabled(_ isEnabled: Bool) -> Self {
        wrapped.isEnabled = isEnabled
        return self
    }

    /// A Boolean value indicating whether the control is in the selected state.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isSelected(_ isSelected: Bool) -> Self {
        wrapped.isSelected = isSelected
        return self
    }

    /// A Boolean value indicating whether the control draws a highlight.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isHighlighted(_ isHighlighted: Bool) -> Self {
        wrapped.isHighlighted = isHighlighted
        return self
    }

    /// The vertical alignment of content within the control’s bounds.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentVerticalAlignment(_ contentVerticalAlignment: UIControl.ContentVerticalAlignment) -> Self {
        wrapped.contentVerticalAlignment = contentVerticalAlignment
        return self
    }

    /// The horizontal alignment of content within the control’s bounds.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentHorizontalAlignment(_ contentHorizontalAlignment: UIControl.ContentHorizontalAlignment) -> Self {
        wrapped.contentHorizontalAlignment = contentHorizontalAlignment
        return self
    }

    /// A Boolean value that determines whether the control enables its context menu interaction.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isContextMenuInteractionEnabled(_ isInteractionEnabled: Bool) -> Self {
        wrapped.isContextMenuInteractionEnabled = isInteractionEnabled
        return self
    }

    /// A Boolean value that determines whether the context menu interaction is the control’s primary action.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func showsMenuAsPrimaryAction(_ showsMenuAsPrimaryAction: Bool) -> Self {
        wrapped.showsMenuAsPrimaryAction = showsMenuAsPrimaryAction
        return self
    }
}

extension UIConfigurator where Wrapped: UICollectionView {
    /// The layout used to organize the collected view’s items.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func collectionViewLayout(_ collectionViewLayout: UICollectionViewLayout) -> Self {
        wrapped.collectionViewLayout = collectionViewLayout
        return self
    }

    /// The object that acts as the delegate of the collection view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func delegate(_ delegate: UICollectionViewDelegate?) -> Self {
        wrapped.delegate = delegate
        return self
    }

    /// The object that provides the data for the collection view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func dataSource(_ dataSource: UICollectionViewDataSource?) -> Self {
        wrapped.dataSource = dataSource
        return self
    }

    /// The object that acts as the prefetching data source for the collection view,
    /// receiving notifications of upcoming cell data requirements.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func prefetchDataSource(_ prefetchDataSource: UICollectionViewDataSourcePrefetching?) -> Self {
        wrapped.prefetchDataSource = prefetchDataSource
        return self
    }

    /// A Boolean value that indicates whether cell and data prefetching are enabled.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isPrefetchingEnabled(_ isPrefetchingEnabled: Bool) -> Self {
        wrapped.isPrefetchingEnabled = isPrefetchingEnabled
        return self
    }

    /// The delegate object that manages the dragging of items from the collection view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func dragDelegate(_ dragDelegate: UICollectionViewDragDelegate?) -> Self {
        wrapped.dragDelegate = dragDelegate
        return self
    }

    /// The delegate object that manages the dropping of items into the collection view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func dropDelegate(_ dropDelegate: UICollectionViewDropDelegate?) -> Self {
        wrapped.dropDelegate = dropDelegate
        return self
    }

    /// A Boolean value that indicates whether the collection view supports dragging content.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func dragInteractionEnabled(_ dragInteractionEnabled: Bool) -> Self {
        wrapped.dragInteractionEnabled = dragInteractionEnabled
        return self
    }

    /// The speed at which items in the collection view are reordered to show potential drop locations.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func reorderingCadence(_ reorderingCadence: UICollectionView.ReorderingCadence) -> Self {
        wrapped.reorderingCadence = reorderingCadence
        return self
    }

    /// The view that provides the background appearance.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func backgroundView(_ backgroundView: UIView?) -> Self {
        wrapped.backgroundView = backgroundView
        return self
    }

    /// A Boolean value that indicates whether users can select items in the collection view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func allowsSelection(_ allowsSelection: Bool) -> Self {
        wrapped.allowsSelection = allowsSelection
        return self
    }

    /// A Boolean value that determines whether users can select more than one item in the collection view.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func allowsMultipleSelection(_ allowsMultipleSelection: Bool) -> Self {
        wrapped.allowsMultipleSelection = allowsMultipleSelection
        return self
    }

    /// A Boolean value that determines whether the collection view is in editing mode.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func isEditing(_ isEditing: Bool) -> Self {
        wrapped.isEditing = isEditing
        return self
    }

    /// A Boolean value that determines whether users can select cells while the collection view is in editing mode.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func allowsSelectionDuringEditing(_ allowsSelectionDuringEditing: Bool) -> Self {
        wrapped.allowsSelectionDuringEditing = allowsSelectionDuringEditing
        return self
    }

    /// A Boolean value that controls whether users can select more than one cell simultaneously in editing mode.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func allowsMultipleSelectionDuringEditing(_ allowsSelectionDuringEditing: Bool) -> Self {
        wrapped.allowsMultipleSelectionDuringEditing = allowsSelectionDuringEditing
        return self
    }
}

extension UIConfigurator where Wrapped: UIButton {
    /// The role of the button.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func role(_ role: UIButton.Role) -> Self {
        wrapped.role = role
        return self
    }

    /// A menu that the button displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func menu(_ menu: UIMenu?) -> Self {
        wrapped.menu = menu
        return self
    }

    /// A Boolean value that indicates whether the button tracks a selection, either through a menu or a toggle.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func changesSelectionAsPrimaryAction(_ changes: Bool) -> Self {
        wrapped.changesSelectionAsPrimaryAction = changes
        return self
    }

    /// The configuration for the button’s appearance.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func configuration(_ configuration: UIButton.Configuration?) -> Self {
        wrapped.configuration = configuration
        return self
    }

    /// A Boolean value that determines whether the button configuration changes when button’s state changes.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func automaticallyUpdatesConfiguration(_ updates: Bool) -> Self {
        wrapped.automaticallyUpdatesConfiguration = updates
        return self
    }

    /// The configuration to customize the button background.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func background(_ background: UIBackgroundConfiguration) -> Self {
        updateConfiguration(.filled()) { configuration in
            configuration.background = background
        }
        return self
    }

    /// The color of the background.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func backgroundColor(_ backgroundColor: UIColor?) -> Self {
        updateConfiguration(.filled()) { configuration in
            configuration.background.backgroundColor = backgroundColor
        }
        return self
    }

    /// The button style that controls the display behavior of the background corner radius.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func cornerStyle(_ cornerStyle: UIButton.Configuration.CornerStyle) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.cornerStyle = cornerStyle
        }
        return self
    }

    /// A size that requests a preferred size for the button.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func buttonSize(_ buttonSize: UIButton.Configuration.Size) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.buttonSize = buttonSize
        }
        return self
    }

    /// The untransformed color for foreground views.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func baseForegroundColor(_ baseForegroundColor: UIColor?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.baseForegroundColor = baseForegroundColor
        }
        return self
    }

    /// The untransformed color for background views.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func baseBackgroundColor(_ baseBackgroundColor: UIColor?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.baseBackgroundColor = baseBackgroundColor
        }
        return self
    }

    /// The foreground image the button displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func image(_ image: UIImage?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.image = image
        }
        return self
    }

    /// A block that transforms the image color when the button state changes.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func imageColorTransformer(_ imageColorTransformer: UIConfigurationColorTransformer?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.imageColorTransformer = imageColorTransformer
        }
        return self
    }

    /// The text of the title label the button displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func title(_ title: String?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.title = title
        }
        return self
    }

    /// The text and style attributes for the button’s title label.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func attributedTitle(_ attributedTitle: AttributedString?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.attributedTitle = attributedTitle
        }
        return self
    }

    /// A structure to update the attributed title when the button state changes.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func titleTextAttributesTransformer(_ transformer: UIConfigurationTextAttributesTransformer?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.titleTextAttributesTransformer = transformer
        }
        return self
    }

    /// The text the subtitle label of the button displays.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func subtitle(_ subtitle: String?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.subtitle = subtitle
        }
        return self
    }

    /// The text and style attributes for the button’s subtitle label.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func attributedSubtitle(_ attributedSubtitle: AttributedString?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.attributedSubtitle = attributedSubtitle
        }
        return self
    }

    /// A structure to update the attributed subtitle when the button state changes.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func subtitleTextAttributesTransformer(_ transformer: UIConfigurationTextAttributesTransformer?) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.subtitleTextAttributesTransformer = transformer
        }
        return self
    }

    /// The distance from the button’s content area to its bounds.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentInsets(_ contentInsets: NSDirectionalEdgeInsets) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.contentInsets = contentInsets
        }
        return self
    }

    /// The edge against which the button places the image.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func imagePlacement(_ imagePlacement: NSDirectionalRectEdge) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.imagePlacement = imagePlacement
        }
        return self
    }

    /// The distance between the button’s image and text.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func imagePadding(_ imagePadding: CGFloat) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.imagePadding = imagePadding
        }
        return self
    }

    /// The distance between the title and subtitle labels.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func titlePadding(_ titlePadding: CGFloat) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.titlePadding = titlePadding
        }
        return self
    }

    /// The text alignment the button uses to lay out the title and subtitle.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func titleAlignment(_ titleAlignment: UIButton.Configuration.TitleAlignment) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.titleAlignment = titleAlignment
        }
        return self
    }

    /// A Boolean value that determines whether the style automatically updates when the button is in a selected state.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func automaticallyUpdateForSelection(_ update: Bool) -> Self {
        updateConfiguration(.plain()) { configuration in
            configuration.automaticallyUpdateForSelection = update
        }
        return self
    }

    private func updateConfiguration(
        _ buttonConfiguration: @autoclosure () -> UIButton.Configuration,
        changes: (_ configuration: inout UIButton.Configuration) -> Void
    ) {
        var configuration = wrapped.configuration ?? buttonConfiguration()
        changes(&configuration)
        wrapped.configuration = configuration
    }
}

extension UIConfigurator where Wrapped: CAShapeLayer {
    /// The path defining the shape to be rendered. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func path(_ path: CGPath?) -> Self {
        wrapped.path = path
        return self
    }

    /// The color used to fill the shape’s path. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func fillColor(_ fillColor: CGColor?) -> Self {
        wrapped.fillColor = fillColor
        return self
    }

    /// The fill rule used when filling the shape’s path.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func fillRule(_ fillRule: CAShapeLayerFillRule) -> Self {
        wrapped.fillRule = fillRule
        return self
    }

    /// The color used to stroke the shape’s path. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func strokeColor(_ strokeColor: CGColor?) -> Self {
        wrapped.strokeColor = strokeColor
        return self
    }

    /// The relative location at which to begin stroking the path. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func strokeStart(_ strokeStart: CGFloat) -> Self {
        wrapped.strokeStart = strokeStart
        return self
    }

    /// The relative location at which to stop stroking the path. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func strokeEnd(_ strokeEnd: CGFloat) -> Self {
        wrapped.strokeEnd = strokeEnd
        return self
    }

    /// Specifies the line width of the shape’s path. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func lineWidth(_ lineWidth: CGFloat) -> Self {
        wrapped.lineWidth = lineWidth
        return self
    }

    /// The miter limit used when stroking the shape’s path. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func miterLimit(_ miterLimit: CGFloat) -> Self {
        wrapped.miterLimit = miterLimit
        return self
    }

    /// Specifies the line cap style for the shape’s path.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func lineCap(_ lineCap: CAShapeLayerLineCap) -> Self {
        wrapped.lineCap = lineCap
        return self
    }

    /// Specifies the line join style for the shape’s path.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func lineJoin(_ lineJoin: CAShapeLayerLineJoin) -> Self {
        wrapped.lineJoin = lineJoin
        return self
    }

    /// The dash phase applied to the shape’s path when stroked. Animatable.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func lineDashPhase(_ lineDashPhase: CGFloat) -> Self {
        wrapped.lineDashPhase = lineDashPhase
        return self
    }

    /// The dash pattern applied to the shape’s path when stroked.
    ///
    /// Подробности смотрите в документации к свойству
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func lineDashPattern(_ lineDashPattern: [Double]?) -> Self {
        wrapped.lineDashPattern = lineDashPattern?.map(NSNumber.init(value:))
        return self
    }
}

// swiftlint:disable attributed_string
extension AttributedString {
    /// Преобразует в `NSAttributedString`
    public var nsAttributedString: NSAttributedString {
        NSAttributedString(self)
    }

    /// Создаёт форматированную строку, содержащую изображение
    /// - Parameters:
    ///   - image: Изображение, которое нужно добавить в строку
    ///   - padding: Горизонтальный отступ до и после изображения
    ///   - offset: Вертикальный сдвиг изображения в строке
    public init(image: UIImage, padding: CGFloat = 0, offset: CGFloat = 0) {
        let attachment = NSTextAttachment(image: image)
        if offset != 0 || padding != 0 {
            let size = image.size
            attachment.bounds = CGRect(x: 0, y: -offset, width: size.width + 2 * padding, height: size.height)
        }
        if padding != 0 {
            attachment.lineLayoutPadding = padding
        }

        self = AttributedString(NSAttributedString(attachment: attachment))
    }

    public init(image: UIImage, spacing: CGFloat = 0, offset: CGFloat = 0) {
        self.init(image: image, padding: 0, offset: offset)

        let spacingAttachment = NSTextAttachment()
        spacingAttachment.bounds = CGRect(x: 0, y: 0, width: 8, height: 0)
        let spacing = AttributedString(NSAttributedString(attachment: spacingAttachment))
        append(spacing)
    }
}
// swiftlint:enable attributed_string

import UIKit

/// Стиль отображения текста
public struct TextStyle: Equatable {
    let size: CGFloat
    let weight: UIFont.Weight
    let lineHeight: CGFloat
    let kern: CGFloat?
    let width: Width

    // MARK: Initialization

    /// Создаёт стиль отображения текста
    /// - Parameters:
    ///   - size: Размер шрифта
    ///   - weight: Начертание шрифта
    ///   - lineHeight: Высота линии
    ///   - kern: Кернинг
    public init(size: CGFloat, weight: UIFont.Weight, lineHeight: CGFloat, kern: CGFloat? = nil) {
        self.init(size: size, weight: weight, lineHeight: lineHeight, kern: kern, width: .standard)
    }

    init(size: CGFloat, weight: UIFont.Weight, lineHeight: CGFloat, kern: CGFloat? = nil, width: Width = .standard) {
        self.size = size
        self.weight = weight
        self.lineHeight = lineHeight
        self.kern = kern
        self.width = width
    }
}

// MARK: - Width

extension TextStyle {
    enum Width {
        case standard, monospacedDigit, monospaced
    }

    /// Возвращает текущий стиль текста со всеми цифрами одинаковой ширины
    public var monospacedDigit: TextStyle {
        TextStyle(size: size, weight: weight, lineHeight: lineHeight, kern: kern, width: .monospacedDigit)
    }

    /// Возвращает текущий стиль текста со шрифтом фиксированной ширины
    public var monospaced: TextStyle {
        TextStyle(size: size, weight: weight, lineHeight: lineHeight, kern: kern, width: .monospaced)
    }
}

// MARK: - UIFont

extension TextStyle {
    /// Возвращает шрифт для текущего стиля текста
    public var font: UIFont {
        switch width {
        case .standard:
            return .systemFont(ofSize: size, weight: weight)
        case .monospacedDigit:
            return .monospacedDigitSystemFont(ofSize: size, weight: weight)
        case .monospaced:
            return .monospacedSystemFont(ofSize: size, weight: weight)
        }
    }
}

// MARK: - Attributes

extension TextStyle {
    /// Возвращает набор свойств, которые должны быть применены к тексту, отображаемому в заданном стиле
    /// - Parameters:
    ///   - textAlignment: Выравнивание текста
    ///   - lineBreakMode: Определяет, что происходит, когда строка слишком длинная для контейнера
    ///   - lineBreakStrategy: Определяет, как система разбивает строки в абзацах
    ///   - paragraphSpacing: Расстояние между абзацами
    ///   - usingFont: Нужно ли добавлять шрифт в набор свойств
    /// - Returns: Набор свойств, которые должны быть применены к тексту
    public func attributes(
        textAlignment: NSTextAlignment,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail,
        lineBreakStrategy: NSParagraphStyle.LineBreakStrategy = [],
        paragraphSpacing: CGFloat = 0,
        usingFont: Bool = true
    ) -> AttributeContainer {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
        paragraph.alignment = textAlignment
        paragraph.lineBreakMode = lineBreakMode
        paragraph.lineBreakStrategy = lineBreakStrategy
        paragraph.paragraphSpacing = paragraphSpacing

        var attributes = AttributeContainer()
        attributes.uiKit.paragraphStyle = paragraph
        if let kern {
            attributes.uiKit.kern = kern
        }

        let font = font
        if usingFont {
            attributes.uiKit.font = font
        }
        if lineHeight != font.lineHeight {
            attributes.uiKit.baselineOffset = (lineHeight - font.lineHeight) / 4
        }

        return attributes
    }

    /// Возвращает набор свойств, которые должны быть применены к тексту, отображаемому в заданном стиле
    /// - Parameters:
    ///   - label: `UILabel`, в котором отображается текст
    ///   - usingFont: Нужно ли добавлять шрифт в набор свойств
    /// - Returns: Набор свойств, которые должны быть применены к тексту
    public func attributes(for label: UILabel, usingFont: Bool = false) -> AttributeContainer {
        attributes(
            textAlignment: label.textAlignment,
            lineBreakMode: label.lineBreakMode,
            lineBreakStrategy: label.lineBreakStrategy,
            usingFont: usingFont
        )
    }

    /// Возвращает набор свойств, которые должны быть применены к тексту, отображаемому в заданном стиле
    /// - Parameters:
    ///   - label: `Label`, в котором отображается текст
    ///   - usingFont: Нужно ли добавлять шрифт в набор свойств
    /// - Returns: Набор свойств, которые должны быть применены к тексту
    public func attributes(for label: Label, usingFont: Bool = false) -> AttributeContainer {
        attributes(
            textAlignment: label.textAlignment,
            lineBreakMode: label.lineBreakMode,
            lineBreakStrategy: label.lineBreakStrategy,
            paragraphSpacing: label.paragraphSpacing,
            usingFont: usingFont
        )
    }

    /// Возвращает набор свойств, которые должны быть применены к тексту, отображаемому в заданном стиле
    /// - Parameters:
    ///   - textField: `UITextField`, в котором отображается текст
    ///   - usingFont: Нужно ли добавлять шрифт в набор свойств
    /// - Returns: Набор свойств, которые должны быть применены к тексту
    public func attributes(for textField: UITextField, usingFont: Bool = false) -> AttributeContainer {
        attributes(textAlignment: textField.textAlignment, usingFont: usingFont)
    }

    /// Возвращает набор свойств, которые должны быть применены к тексту, отображаемому в заданном стиле
    /// - Parameters:
    ///   - textView: `UITextView`, в котором отображается текст
    ///   - usingFont: Нужно ли добавлять шрифт в набор свойств
    /// - Returns: Набор свойств, которые должны быть применены к тексту
    public func attributes(for textView: UITextView, usingFont: Bool = false) -> AttributeContainer {
        attributes(
            textAlignment: textView.textAlignment,
            lineBreakMode: textView.textContainer.lineBreakMode,
            usingFont: usingFont
        )
    }
}

// MARK: - Styles

extension TextStyle {
    public static var header1: TextStyle {
        TextStyle(size: 24, weight: .semibold, lineHeight: 28)
    }

    public static var title1: TextStyle {
        TextStyle(size: 20, weight: .semibold, lineHeight: 28, kern: -0.44)
    }

    public static var title2: TextStyle {
        TextStyle(size: 18, weight: .semibold, lineHeight: 24, kern: -0.44)
    }

    public static var title3: TextStyle {
        TextStyle(size: 14, weight: .semibold, lineHeight: 20, kern: -0.24)
    }

    public static var title4: TextStyle {
        TextStyle(size: 12, weight: .semibold, lineHeight: 16)
    }

    public static var title5: TextStyle {
        TextStyle(size: 10, weight: .semibold, lineHeight: 12)
    }

    public static var textBody: TextStyle {
        TextStyle(size: 14, weight: .regular, lineHeight: 20, kern: -0.24)
    }

    public static var subheader: TextStyle {
        TextStyle(size: 12, weight: .regular, lineHeight: 16)
    }

    public static var caption: TextStyle {
        TextStyle(size: 10, weight: .regular, lineHeight: 12)
    }

    public static var btnL: TextStyle {
        TextStyle(size: 15, weight: .semibold, lineHeight: 24)
    }

    public static var btnM: TextStyle {
        TextStyle(size: 12, weight: .semibold, lineHeight: 16)
    }

    public static var btnLink: TextStyle {
        TextStyle(size: 14, weight: .medium, lineHeight: 20, kern: -0.24)
    }

    public static var tabBar: TextStyle {
        TextStyle(size: 10, weight: .medium, lineHeight: 12)
    }
}

/// Текстовое поле с поддержкой стиля текста
public final class Label: UILabel {
    /// Стиль, в которым поле должно отобрать текст
    ///
    /// Стиль устанавливает шрифт, высоту строки и расстояние между символами.
    ///
    /// Значение по умолчанию `nil`
    public var textStyle: TextStyle? {
        didSet {
            if let font = textStyle?.font {
                self.font = font
            }
            updateCurrentText()
        }
    }

    /// Отступ текста от границ поля
    ///
    /// Значение по умолчанию `.zero`
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    /// Расстояние между абзацами
    ///
    /// Значение по умолчанию 0
    public var paragraphSpacing: CGFloat = 0 {
        didSet {
            updateCurrentText()
        }
    }

    /// Вертикальное выравнивание текста
    ///
    /// Значение по умолчанию `.center`
    public var verticalTextAlignment: VerticalTextAlignment = .center {
        didSet {
            setNeedsDisplay()
        }
    }

    override public var text: String? {
        didSet {
            updateCurrentText()
        }
    }

    override public var attributedText: NSAttributedString? {
        didSet {
            updateCurrentText(mergePolicy: .keepCurrent)
        }
    }

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override public func drawText(in rect: CGRect) {
        super.drawText(in: textRect(forBounds: rect.inset(by: contentInsets)))
    }

    override public func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let rect = super.textRect(forBounds: bounds.inset(by: contentInsets), limitedToNumberOfLines: numberOfLines)
        let inverted = UIEdgeInsets(
            top: -contentInsets.top,
            left: -contentInsets.left,
            bottom: -contentInsets.bottom,
            right: -contentInsets.right
        )
        return rect.inset(by: inverted)
    }

    // MARK: Configuration

    private func configure() {
        lineBreakStrategy = []
    }

    // MARK: Private

    private func updateCurrentText(mergePolicy: AttributedString.AttributeMergePolicy = .keepNew) {
        guard let attributedText, let textStyle else {
            return
        }

        var attributedString = AttributedString(attributedText)
        attributedString.mergeAttributes(textStyle.attributes(for: self), mergePolicy: mergePolicy)
        super.attributedText = attributedString.nsAttributedString
    }

    private func textRect(forBounds bounds: CGRect) -> CGRect {
        guard verticalTextAlignment != .center else {
            return bounds
        }

        var contentHeight = intrinsicContentSize.height - contentInsets.top - contentInsets.bottom
        guard contentHeight != bounds.height else {
            return bounds
        }

        if contentHeight > bounds.height {
            var numberOfLines = 1
            while true {
                let rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
                if rect.minY < bounds.minY {
                    break
                }
                contentHeight = rect.height
                numberOfLines += 1
            }
        }

        let offset = bounds.height - contentHeight
        guard offset.isGreaterThan(value: 0) else {
            return bounds
        }

        var rect = bounds
        switch verticalTextAlignment {
        case .top:
            rect.origin.y -= offset / 2
        case .bottom:
            rect.origin.y += offset / 2
        default:
            break
        }
        return rect
    }
}

// MARK: -

extension Label {
    /// Вертикальное выравнивание текста
    public enum VerticalTextAlignment {
        /// Выравнивание по верхней границе
        case top
        /// Выравнивание по центру
        case center
        /// Выравнивание по нижней границе
        case bottom
    }
}

extension FloatingPoint {
    /// Логическое значение, показывающее, равно ли текущее число 0. При сравнении учитывается epsilon
    public var isZeroValue: Bool {
        isEqualTo(value: 0)
    }

    /// Возвращает логическое значение, показывающее, равно ли текущее число заданному.
    /// При сравнении учитывается epsilon
    /// - Parameter value: Число, с которым нужно сравнить текущее
    public func isEqualTo(value: Self) -> Bool {
        abs(self - value) < .ulpOfOne
    }

    /// Возвращает логическое значение, показывающее, что текущее число не равно заданному.
    /// При сравнении учитывается epsilon
    /// - Parameter value: Число, с которым нужно сравнить текущее
    public func isNotEqualTo(value: Self) -> Bool {
        !isEqualTo(value: value)
    }

    /// Возвращает логическое значение, показывающее, является ли текущее число меньше заданного.
    /// При сравнении учитывается epsilon
    /// - Parameter value: Число, с которым нужно сравнить текущее
    public func isLessThan(value: Self) -> Bool {
        isNotEqualTo(value: value) && self < value
    }

    /// Возвращает логическое значение, показывающее, является ли текущее число меньше или равным заданному.
    /// При сравнении учитывается epsilon
    /// - Parameter value: Число, с которым нужно сравнить текущее
    public func isLessThanOrEqualTo(value: Self) -> Bool {
        isEqualTo(value: value) || self < value
    }

    /// Возвращает логическое значение, показывающее, является ли текущее число больше заданного.
    /// При сравнении учитывается epsilon
    /// - Parameter value: Число, с которым нужно сравнить текущее
    public func isGreaterThan(value: Self) -> Bool {
        !isLessThanOrEqualTo(value: value)
    }

    /// Возвращает логическое значение, показывающее, является ли текущее число больше или равным заданному.
    /// При сравнении учитывается epsilon
    /// - Parameter value: Число, с которым нужно сравнить текущее
    public func isGreaterThanOrEqualTo(value: Self) -> Bool {
        !isLessThan(value: value)
    }
}

import Foundation

extension AttributeContainer {
    /// Преобразует в словарь атрибутов
    public var asDictionary: [NSAttributedString.Key: Any] {
        (try? Dictionary(self, including: \.uiKit)) ?? [:]
    }
}

import Kingfisher
import UIKit
import UniformTypeIdentifiers

/// Элемент для показа изображений. Поддерживает загрузку с удалённого сервера
public final class ImageView: UIImageView {
    /// Использовать изображение оригинального размера, а не вписывать его в размер элемента
    ///
    /// Значение по умолчанию `false`
    public var alwaysUseOriginal = false

    /// Не обновлять изображение при изменении размеров элемента
    ///
    /// Значение по умолчанию `false`
    public var ignoreBoundsChanges = false

    /// Размер оригинального изображения, загруженного с сервера
    public var imageSize: CGSize? {
        guard
            let url = originalImagePath.map(URL.init(file:)),
            let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
            let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
            let height = properties[kCGImagePropertyPixelHeight] as? CGFloat
        else {
            return image?.size
        }

        return CGSize(width: width, height: height)
    }

    /// Оригинальное изображение, загруженное с сервера
    public var originalImage: UIImage? {
        guard let path = originalImagePath else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }

    private var originalImagePath: String? {
        guard let cacheKey = resource?.url?.cacheKey else {
            return nil
        }

        let cache = KingfisherManager.shared.cache
        guard cache.isCached(forKey: cacheKey) else {
            return nil
        }

        return cache.cachePath(forKey: cacheKey)
    }

    private var resource: Resource?
//    private var containerSize: CGSize = .zero {
//        didSet {
//            guard containerSize != currentImageSize, !alwaysUseOriginal, !ignoreBoundsChanges else {
//                return
//            }
//            if let resource, let url = resource.url, !resource.isSVG, resource.preferredSize == .zero {
//                cancel()
//                setImageURL(
//                    url,
//                    placeholder: resource.placeholder,
//                    preferredSize: resource.preferredSize,
//                    completion: resource.completion
//                )
//            }
//        }
//    }
//    private var currentImageSize: CGSize = .zero

    // MARK: Initialization

    public convenience init() {
        self.init(frame: .zero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    override public init(image: UIImage?) {
        super.init(image: image)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

//    override public func layoutSubviews() {
//        super.layoutSubviews()
//
//        containerSize = bounds.size
//    }

    // MARK: Configuration

    private func configure() {
        contentMode = .scaleAspectFit
    }

    // MARK: Public

    /// Задать изображение доступное по ссылке
    ///
    /// Когда изображение находится в кэше, повторной загрузки не происходит.
    ///
    /// После загрузки изображения его размер уменьшается, если возможно,
    /// чтобы его можно было вписать в размер представления. Когда задан параметр `preferredSize`,
    /// то он используется вместо реального размера представления
    /// - Parameters:
    ///   - imageURL: Ссылка на изображение
    ///   - placeholder: Заглушка, которая отображается, когда изображение отсутствует
    ///   - preferredSize: Размер, в который будет вписываться изображение
    ///   - completion: Замыкание, которое будет вызвано, когда изображение скачается и отобразится
    public func setImageURL(
        _ imageURL: URL?,
        placeholder: Placeholder? = PlaceholderView(fill: true),
        preferredSize: CGSize = .zero,
        completion: (() -> Void)? = nil
    ) {
        if resource?.url != imageURL {
            image = nil
        }

        resource = Resource(
            url: imageURL,
            placeholder: placeholder,
            preferredSize: preferredSize,
            completion: completion
        )

        let isSVG = resource?.isSVG ?? false
//        let size = preferredSize != .zero ? preferredSize : containerSize
//        guard imageURL == nil || alwaysUseOriginal || size != .zero || isSVG else {
//            setNeedsLayout()
//            return
//        }
//
//        currentImageSize = size

        // FIXME: временно отключен DownsamplingImageProcessor
        // Его активация приводит к https://pm.handh.ru/issues/134681 (ширина imageView должна быть 120)
        // и https://pm.handh.ru/issues/136450
        var options: KingfisherOptionsInfo = [
            .transition(.fade(0.25)),
            .keepCurrentImageWhileLoading
        ]
        if isSVG {
            options.append(contentsOf: [.processor(SVGProcessor()), .cacheSerializer(SVGCacheSerializer())])
//        } else if alwaysUseOriginal {
//            options.append(contentsOf: [.backgroundDecode, .imageModifier(ScaleModifier())])
        } else {
            options.append(contentsOf: [
                .backgroundDecode,
//                .processor(DownsamplingImageProcessor(size: size)),
//                .scaleFactor(traitCollection.displayScale),
//                .cacheOriginalImage
            ])
        }

        kf.setImage(with: imageURL, placeholder: placeholder, options: options) { _ in
            completion?()
        }
    }

    /// Отменить загрузку изображения
    public func cancel() {
        kf.cancelDownloadTask()
        resource = nil
    }
}

struct SVGProcessor: ImageProcessor {
    let identifier = "ru.everyEvent.svgImageProcessor"

    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case let .image(image):
            return image
        case let .data(data):
            return SVGImageCoder.shared.image(with: data)
        }
    }
}

import Foundation
import Kingfisher

struct SVGCacheSerializer: CacheSerializer {
    func data(with image: KFCrossPlatformImage, original: Data?) -> Data? {
        original ?? SVGImageCoder.shared.data(of: image)
    }

    func image(with data: Data, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        SVGImageCoder.shared.image(with: data)
    }
}



// MARK: -

extension ImageView {
    /// Начать предзагрузку изображений
    /// - Parameter urls: Массив ссылок на изображения
    public static func prefetch(urls: [URL]) {
        ImagePrefetcher(urls: urls).start()
    }
}

// MARK: -

extension ImageView {
    struct Resource {
        let url: URL?
        let placeholder: Placeholder?
        let preferredSize: CGSize
        let completion: (() -> Void)?

        var isSVG: Bool {
            guard let url else {
                return false
            }
            return UTType(filenameExtension: url.pathExtension) == .svg
        }
    }
}

import UIKit

extension UIConfigurator where Wrapped: Label {
    /// Стиль, в котором поле должно отобрать текст
    ///
    /// Стиль устанавливает шрифт, высоту строки и расстояние между символами.
    /// Значение по умолчанию `nil`
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func textStyle(_ textStyle: TextStyle?) -> Self {
        wrapped.textStyle = textStyle
        return self
    }

    /// Отступ текста от границ поля
    ///
    /// Значение по умолчанию `.zero`
    /// - Returns: Объект, обёрнутый в `UIConfigurator`
    @discardableResult
    public func contentInsets(_ contentInsets: UIEdgeInsets) -> Self {
        wrapped.contentInsets = contentInsets
        return self
    }

    /// Расстояние между абзацами
    ///
    /// Значение по умолчанию 0
    @discardableResult
    public func paragraphSpacing(_ paragraphSpacing: CGFloat) -> Self {
        wrapped.paragraphSpacing = paragraphSpacing
        return self
    }

    /// Вертикальное выравнивание текста
    ///
    /// Значение по умолчанию `.center`
    @discardableResult
    public func verticalTextAlignment(_ verticalTextAlignment: Label.VerticalTextAlignment) -> Self {
        wrapped.verticalTextAlignment = verticalTextAlignment
        return self
    }
}
