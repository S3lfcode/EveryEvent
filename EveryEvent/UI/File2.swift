import UIKit
import Foundation
import CryptoKit
import UIKit

/// Объект, который при удалении автоматически вызывает `NotificationCenter.removeObserver(_:)`
public final class NotificationObservation {
    let notificationCenter: NotificationCenter
    let token: NSObjectProtocol

    // MARK: Initialization

    init(notificationCenter: NotificationCenter, token: NSObjectProtocol) {
        self.notificationCenter = notificationCenter
        self.token = token
    }

    deinit {
        invalidate()
    }

    // MARK: Public

    /// `invalidate()` будет вызван автоматически, когда `NotificationObservation` удалится из памяти
    public func invalidate() {
        notificationCenter.removeObserver(token)
    }
}
import Foundation

extension NotificationCenter {
    /// Добавляет наблюдателя в `NotificationCenter` для получения уведомлений,
    /// которые передаются в предоставленное замыкание
    /// - Parameters:
    ///   - name: Имя уведомления
    ///   - block: Замыкание, которое выполняется, когда получено уведомление
    /// - Returns: Объект, который автоматически вызывает `NotificationCenter.removeObserver(_:)` при удаляет
    public func observe(
        name: Notification.Name,
        using block: @escaping (Notification) -> Void
    ) -> NotificationObservation {
        NotificationObservation(
            notificationCenter: self,
            token: addObserver(forName: name, object: nil, queue: nil, using: block)
        )
    }
}



/// Индикатор загрузки
public final class IndicatorView: UIView {
    private let mainLayer = CAShapeLayer()
    private let secondaryLayer = CAShapeLayer()

    // MARK: Properties

    /// Стиль отображения индикатора загрузки
    public var style: Style {
        didSet {
            apply(style: style)
        }
    }

    /// Нужно ли скрывать индикатор, когда анимация останавливается
    ///
    /// Если значение `true`, то индикатор устанавливает свойству `isHidden` значение `true`,
    /// когда анимация останавливается. Если `false`, то индикатор не срывает себя при остановке анимации.
    ///
    /// Значение по умолчанию `true`
    public var hidesWhenStopped = true {
        didSet {
            if hidesWhenStopped != oldValue, hidesWhenStopped, !isAnimating {
                isHidden = true
            }
        }
    }

    /// Показывает, что анимация в индикаторе загрузки активна в данный момент
    public private(set) var isAnimating = false

    private let lineWidth: CGFloat = 1.3
    private var isBackground = false
    private var isPaused = false
    private var observations = [NotificationObservation]()

    override public var intrinsicContentSize: CGSize {
        CGSize(width: 24, height: 24)
    }

    // MARK: Initialization

    /// Создаёт индикатор загрузки
    /// - Parameter style: Стиль отображения индикатора загрузки
    public init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        guard newWindow != nil else {
            pauseAnimating()
            return
        }

        if isAnimating && !isBackground {
            resumeAnimating()
        }
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        let bounds = layer.bounds

        mainLayer.frame = bounds
        secondaryLayer.frame = bounds

        let radius = max((min(bounds.width, bounds.height) - 2 - lineWidth) / 2, 0)
        let path = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        ).cgPath

        mainLayer.path = path
        secondaryLayer.path = path
    }

    // MARK: Configuration

    private func configure() {
        [secondaryLayer, mainLayer].forEach {
            $0.ui.lineWidth(lineWidth).fillColor(nil).lineCap(.round).strokeStart(0).strokeEnd(0)
            layer.addSublayer($0)
        }
        apply(style: style)

        isHidden = hidesWhenStopped

        let handler = { [weak self] (notification: Notification) in
            guard let self else {
                return
            }

            self.isBackground = notification.name == UIScene.didEnterBackgroundNotification
            guard self.isAnimating else {
                return
            }

            if self.isBackground {
                self.pauseAnimating()
            } else if self.window != nil {
                self.resumeAnimating()
            }
        }

        isBackground = UIApplication.shared.applicationState == .background
        observations = [UIScene.didEnterBackgroundNotification, UIScene.willEnterForegroundNotification].map {
            NotificationCenter.default.observe(name: $0, using: handler)
        }
    }

    private func apply(style: Style) {
        [secondaryLayer, mainLayer].forEach {
            $0.strokeColor = style.color.cgColor
        }
    }
}

// MARK: - Public

extension IndicatorView {
    /// Запускает анимацию индикатора загрузки
    ///
    /// Когда анимация запускает, индикатор показывается, если он был скрыт.
    /// Анимация выполняется бесконечно до вызова `stopAnimating()`
    public func startAnimating() {
        guard !isAnimating else {
            return
        }

        isAnimating = true
        isHidden = false
        guard window != nil, !isBackground else {
            return
        }

        if isPaused {
            resumeAnimating()
        } else {
            addAnimations()
        }
    }

    /// Завершает выполнение анимации
    ///
    /// Когда анимация останавливается, индикатор скрывается, если значение свойства `hidesWhenStopped` равно `true`
    public func stopAnimating() {
        guard isAnimating else {
            return
        }

        isAnimating = false

        if hidesWhenStopped {
            isHidden = true
        }

        mainLayer.removeAnimation(forKey: Key.rotation.rawValue)
        mainLayer.removeAnimation(forKey: Key.stroke.rawValue)
        secondaryLayer.removeAnimation(forKey: Key.rotation.rawValue)
        secondaryLayer.removeAnimation(forKey: Key.stroke.rawValue)
    }
}


import QuartzCore

/// Слой, позволяющий ставить на паузу выполнение анимаций
public protocol InterruptibleLayer: CALayer {
    /// Приостановить выполнение анимаций
    func pause()
    /// Продолжить выполнение анимаций
    func resume()
}

extension InterruptibleLayer {
    public func pause() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0
        timeOffset = pausedTime
    }

    public func resume() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let currentTime = convertTime(CACurrentMediaTime(), from: nil)
        let timeSincePause = currentTime - pausedTime
        beginTime = timeSincePause
    }
}

extension CALayer: InterruptibleLayer {}


// MARK: - Private

extension IndicatorView {
    private func addAnimations(offset: CFTimeInterval = 0) {
        guard mainLayer.animation(forKey: Key.rotation.rawValue) == nil else {
            return
        }

        mainLayer.add(rotationAnimation(offset: offset), forKey: Key.rotation.rawValue)
        mainLayer.add(mainStrokeAnimation(offset: offset), forKey: Key.stroke.rawValue)
        secondaryLayer.add(rotationAnimation(offset: offset), forKey: Key.rotation.rawValue)
        secondaryLayer.add(secondaryStrokeAnimation(offset: offset), forKey: Key.stroke.rawValue)
    }

    private func pauseAnimating() {
        guard !isPaused else {
            return
        }

        isPaused = true
        layer.pause()
    }

    private func resumeAnimating() {
        addAnimations(offset: layer.timeOffset)

        guard isPaused else {
            return
        }

        isPaused = false
        layer.resume()
    }
}

// MARK: - Animations

extension IndicatorView {
    private enum Key: String {
        case rotation, stroke
    }

    private func rotationAnimation(offset: CFTimeInterval) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 1.5
        animation.fromValue = 0
        animation.toValue = 2 * CGFloat.pi
        animation.repeatCount = .infinity
        animation.timeOffset = offset
        return animation
    }

    private func mainStrokeAnimation(offset: CFTimeInterval) -> CAAnimation {
        let strokeStart = CAKeyframeAnimation(keyPath: "strokeStart")
        strokeStart.values = [0, 0, 0.9, 1]
        strokeStart.keyTimes = [0, 0.25, 0.5, 1]

        let strokeEnd = CAKeyframeAnimation(keyPath: "strokeEnd")
        strokeEnd.values = [0.1, 0.97, 1, 1]
        strokeEnd.keyTimes = [0, 0.25, 0.5, 1]

        let animation = CAAnimationGroup()
        animation.duration = 2
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.animations = [strokeStart, strokeEnd]
        animation.timeOffset = offset
        return animation
    }

    private func secondaryStrokeAnimation(offset: CFTimeInterval) -> CAAnimation {
        let animation = CAKeyframeAnimation(keyPath: "strokeEnd")
        animation.duration = 2
        animation.values = [0, 0.1]
        animation.keyTimes = [0.5, 1]
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.timeOffset = offset
        return animation
    }
}


extension IndicatorView {
    /// Объект, описывающий стиль отображения индикатора загрузки
    public struct Style {
        let color: UIColor

        // MARK: Initialization

        /// Создаёт объект, описывающий стиль отображения индикатора загрузки
        /// - Parameter color: Цвет индикатора загрузки
        public init(color: UIColor) {
            self.color = color
        }
    }
}

// MARK: - Default styles

extension IndicatorView.Style {
    /// Жёлтый индикатор загрузки
    public static var yellow: Self {
        IndicatorView.Style(color: UIColor.yellow)
    }

    /// Чёрный индикатор загрузки
    public static var black: Self {
        IndicatorView.Style(color: UIColor.black)
    }
}

extension String {
    /// MD5-хеш
    public var md5: String {
        Insecure.MD5.hash(data: Data(utf8)).map { String(format: "%02x", $0) }.joined()
    }

    /// Возвращает новую строку с экранированными служебными символами регулярного выражения
    public var addingRegexEscaping: String {
        replacingOccurrences(of: "+", with: "\\+")
            .replacingOccurrences(of: "(", with: "\\(")
            .replacingOccurrences(of: ")", with: "\\)")
    }

    /// Возвращает новую строку, в которой удалены все символы из заданного набора
    /// - Parameter set: Набор символов, которые должны быть удалены из строи
    /// - Returns: Новая строка, с удалёнными недопустимыми символами
    public func removingCharacters(in set: CharacterSet) -> String {
        String(unicodeScalars.filter { !set.contains($0) })
    }

    /// Возвращает новую строку, состоящую только из символов заданного набора
    /// - Parameter set: Набор символов, которые должны остаться в строке
    /// - Returns: Новая строка, с удалёнными недопустимыми символами
    public func removingAllCharacters(excluding set: CharacterSet) -> String {
        String(unicodeScalars.filter(set.contains))
    }

    /// Возвращает индекс, который находится на указанном расстоянии перед заданным индексом
    /// - Parameters:
    ///   - index: Корректный индекс в строке
    ///   - distance: Смещение относительно `index`
    /// - Returns: Индекс, который находится на указанном расстоянии перед заданным индексом.
    /// Если он выходит за пределы допустимых значение, то возвращается `startIndex`
    public func index(before index: Index, offsetBy distance: Int) -> Index {
        self.index(index, offsetBy: -distance, limitedBy: startIndex) ?? startIndex
    }

    /// Возвращает индекс, который находится на указанном расстоянии после заданного индекса
    /// - Parameters:
    ///   - index: Корректный индекс в строке
    ///   - distance: Смещение относительно `index`
    /// - Returns: Индекс, который находится на указанном расстоянии после заданного индекса.
    /// Если он выходит за пределы допустимых значение, то возвращается `endIndex`
    public func index(after index: Index, offsetBy distance: Int) -> Index {
        self.index(index, offsetBy: distance, limitedBy: endIndex) ?? endIndex
    }
}


///// Объект для форматирования текста по маске
//public struct MaskTextFormatter: TextFormatter, Codable, Hashable {
//    private let mask: String
//    private let placeholder: Character
//    private let allowedCharacters: CharacterSet
//    private let caretPositions: [Int] // Все позиции курсора в маске
//
//    // MARK: Initialization
//
//    /// Создаёт объект для форматирования текста по маске
//    /// - Parameters:
//    ///   - mask: Маска, которая будет использоваться для форматирования
//    ///   - characters: Набор разрешённых для вывода символов.
//    ///   Все символы, которые не входят в данный набор, будут удалены из исходной строки перед форматированием
//    ///   - placeholder: Символ в маске, который будет заменён. По умолчанию `"X"`
//    public init(mask: String, characters: CharacterSet, placeholder: Character = "X") {
//        self.mask = mask
//        self.placeholder = placeholder
//        allowedCharacters = characters
//        caretPositions = mask.enumerated().reduce(into: []) { result, item in
//            if item.element == placeholder {
//                if result.isEmpty {
//                    result.append(item.offset)
//                }
//                result.append(item.offset + 1)
//            }
//        }
//    }
//
//    // MARK: Public
//
//    /// Снимает маску с заданной строки
//    /// - Parameter string: Строка, содержащая маску
//    /// - Returns: Новая строка без маски
//    public func removeMask(from string: String) -> String {
//        string.isNotEmpty ? string.removingAllCharacters(excluding: allowedCharacters) : ""
//    }
//
//    /// Заменяет текст на новый и применяет к нему форматирование
//    /// - Parameters:
//    ///   - string: Исходная строка
//    ///   - range: Диапазон символов, которые нужно заменить
//    ///   - replacementString: Строка для замены
//    ///   - formatter: Замыкание, форматирующее строку
//    /// - Returns: Результат замены и форматирования исходного текста
//    public func format(
//        string: String,
//        afterReplacingIn range: Range<String.Index>,
//        with replacementString: String,
//        using formatter: (String) -> String
//    ) -> TextFormatterResult {
//        var range = range
//        if replacementString.isEmpty, removeMask(from: String(string[range])).isEmpty {
//            // Если в удаляемой подстроке нет символов, то расширяем диапазон до ближайшего, находящегося левее курсора
//            let position = string.distance(from: string.startIndex, to: range.lowerBound)
//            if let nearestPosition = caretPositions.last(where: { $0 <= position }) {
//                // Так как мы храним положение курсора, которое находится правее символа,
//                // то нужно увеличить смещение на 1
//                let offset = position - nearestPosition + 1
//                let lowerBound = string.index(before: range.lowerBound, offsetBy: offset)
//                range = lowerBound..<range.upperBound
//            }
//        }
//
//        let formattedText = formatter(string.replacingCharacters(in: range, with: replacementString))
//        guard formattedText.isNotEmpty else {
//            return .replace(string: formattedText, caret: 0)
//        }
//
//        // Позиция курсора в исходной строке
//        let position = string.distance(from: string.startIndex, to: range.lowerBound)
//        // Позиция курсора в маске (учитываем только символы placeholder)
//        let caretPosition = caretPositions.lastIndex { $0 <= position } ?? 0
//        // Смещение курсора (количество добавленных символов)
//        let offset = removeMask(from: replacementString).count
//
//        // Новая позиция курсора в маске
//        let index = min(caretPosition + offset, caretPositions.endIndex - 1)
//        // Позиция курсора в отформатированной строке
//        let targetPosition = caretPositions[index]
//        // Переводим позицию курсора в корректное для текстового поля значение.
//        // Это нужно, потому что при вводе некоторых unicode-символов видимая длина строки отличается от реальной
//        let targetIndex = formattedText
//            .index(formattedText.startIndex, offsetBy: targetPosition)
//            .utf16Offset(in: formattedText)
//        return .replace(string: formattedText, caret: targetIndex)
//    }
//
//    // MARK: TextFormatter
//
//    public func format(
//        string: String,
//        afterReplacingIn range: Range<String.Index>,
//        with replacementString: String
//    ) -> TextFormatterResult {
//        format(string: string, afterReplacingIn: range, with: replacementString, using: formatted(string:))
//    }
//
//    public func formatted(string: String) -> String {
//        let rawString = removeMask(from: string)
//        guard rawString.isNotEmpty else {
//            return ""
//        }
//
//        var formatted = ""
//        var index = rawString.startIndex
//        for char in mask where index < rawString.endIndex {
//            if char == placeholder {
//                formatted.append(rawString[index])
//                index = rawString.index(after: index)
//            } else {
//                formatted.append(char)
//            }
//        }
//        return formatted
//    }
//
//    public func plain(string: String) -> String {
//        removeMask(from: string)
//    }
//}


/// Объект для форматирования номера телефона
//public struct PhoneTextFormatter: TextFormatter, Codable, Hashable {
//    /// Международный код страны
//    public let phoneCode: String
//
//    private let formatter: MaskTextFormatter
//
//    // MARK: Initialization
//
//    /// Создаёт объект для форматирования номера телефона
//    public init() {
//        phoneCode = "+7\u{00a0}"
//        formatter = MaskTextFormatter(mask: "(XXX)\u{00a0}XXX-XX-XX", characters: .decimalDigits)
//    }
//
//    // MARK: TextFormatter
//
//    public func format(
//        string: String,
//        afterReplacingIn range: Range<String.Index>,
//        with replacementString: String
//    ) -> TextFormatterResult {
//        formatter.format(string: string, afterReplacingIn: range, with: replacementString, using: formatted(string:))
//    }
//
//    public func formatted(string: String) -> String {
//        // Если форматируем целый номер телефона, то удаляем из него код страны
//        var rawString = formatter.removeMask(from: string)
//        if rawString.count == 11, let first = rawString.first, (first == "7" || first == "8") {
//            rawString.removeFirst()
//        }
//
//        return formatter.formatted(string: rawString)
//    }
//
//    public func plain(string: String) -> String {
//        let plainString = formatter.plain(string: string)
//        switch plainString.count {
//        case 11 where plainString.hasPrefix("8"):
//            return plainString.replacingCharacters(in: ...plainString.startIndex, with: "7")
//        case 10:
//            return "7" + plainString
//        default:
//            return plainString
//        }
//    }
//}


/// Объект, который проверяет, что строка соответствует условиям
public protocol TextValidationRule {
    /// Проверить, что заданная строка соответствует условиям
    ///
    /// Если строка не прошла проверку, то выполнение метода заканчивается ошибкой `TextValidationError`
    /// - Parameter string: Строка, которую нужно проверить
    func validate(string: String) throws
}


/// Объект, который используется для проверки на корректность значения в текстовом поле
public struct TextValidator: TextValidationRule, ExpressibleByArrayLiteral {
    private let rules: [TextValidationRule]
    private let required: Bool

    // MARK: Initialization

    /// Создаёт объект, который использует одно правило проверки значения в текстовом поле
    /// - Parameters:
    ///   - rule: Правило проверки значения
    ///   - required: Должно ли правило применяться к пустой строке
    public init(rule: TextValidationRule, required: Bool = true) {
        rules = [rule]
        self.required = required
    }

    /// Создаёт объект, который использует комбинацию правил, для проверки на корректность значения в текстовом поле
    /// - Parameters:
    ///   - validators: Массив объектов для проверки значения в текстовом поле
    ///   - required: Должны ли правила применяться к пустой строке
    public init(validators: [TextValidator], required: Bool = true) {
        rules = validators.flatMap(\.rules)
        self.required = required
    }

    // MARK: ExpressibleByArrayLiteral

    public init(arrayLiteral elements: TextValidator...) {
        self.init(validators: elements)
    }

    // MARK: TextValidationRule

    public func validate(string: String) throws {
        guard required || string.isNotEmpty else {
            return
        }

        for rule in rules {
            try rule.validate(string: string)
        }
    }
}


extension TextField {
    /// Конфигурация текстового поля
    public struct Style {
        let placeholder: String
        let formatter: TextFormatter?
        let validator: TextValidator?
        let keyboardType: UIKeyboardType
        let textContentType: UITextContentType?
        let autocapitalizationType: UITextAutocapitalizationType
        let autocorrectionType: UITextAutocorrectionType
        let isSecureTextEntry: Bool
        let leftView: OverlayView?
        let rightView: OverlayView?

        // MARK: Initialization

        /// Создаёт конфигурацию текстового поля
        /// - Parameters:
        ///   - placeholder: Текст подсказки
        ///   - formatter: Объект, который форматирует вводимый текст
        ///   - validator: Объект, который проверяет введённый текст на корректность
        ///   - keyboardType: Тип клавиатуры
        ///   - textContentType: Семантическое значение содержимого тестового поля
        ///   - autocapitalizationType: Автоматическое включение заглавных букв на клавиатуре
        ///   - autocorrectionType: Автоматическая коррекция текста
        ///   - isSecureTextEntry: Должно ли текстовое поле скрывать вводимый текст
        ///   - leftView: Элемент, который отображается в левой части текстового поля
        ///   - rightView: Элемент, который отображается в правой части текстового поля
        public init(
            placeholder: String = "",
            formatter: TextFormatter? = nil,
            validator: TextValidator? = nil,
            keyboardType: UIKeyboardType = .default,
            textContentType: UITextContentType? = nil,
            autocapitalizationType: UITextAutocapitalizationType = .sentences,
            autocorrectionType: UITextAutocorrectionType = .default,
            isSecureTextEntry: Bool = false,
            leftView: OverlayView? = nil,
            rightView: OverlayView? = nil
        ) {
            self.placeholder = placeholder
            self.formatter = formatter
            self.validator = validator
            self.keyboardType = keyboardType
            self.textContentType = textContentType
            self.autocapitalizationType = autocapitalizationType
            self.autocorrectionType = autocorrectionType
            self.isSecureTextEntry = isSecureTextEntry
            self.leftView = leftView
            self.rightView = rightView
        }
    }

    /// Конфигурация объекта, который будет отображаться в текстовом поле
    public struct OverlayView {
        let view: UIView
        let viewMode: OverlayVisibleMode
        let alignment: OverlayAlignment
        let offset: CGPoint
        let spacing: CGFloat
        let configure: ((TextField) -> Void)?
        let changed: ((TextField) -> Void)?

        // MARK: Initialization

        /// Создаёт конфигурацию объекта, который будет отображаться в текстовом поле
        /// - Parameters:
        ///   - view: Элемент, который будет отображаться в текстовом поле
        ///   - viewMode: Режим видимости элемента в текстовом поле
        ///   - alignment: Выравнивание элемента в текстовом поле
        ///   - offset: Сдвиг элемента в текстовом поле
        ///   - spacing: Отступ между элементом и текстом в поле
        ///   - configure: Замыкание вызывается, когда элемент добавляется к текстовому полю
        ///   - changed: Замыкание вызывается, когда текстовое поле изменяется
        public init(
            view: UIView,
            viewMode: OverlayVisibleMode,
            alignment: OverlayAlignment,
            offset: CGPoint = .zero,
            spacing: CGFloat = 0,
            configure: ((TextField) -> Void)? = nil,
            changed: ((TextField) -> Void)? = nil
        ) {
            self.view = view
            self.viewMode = viewMode
            self.alignment = alignment
            self.offset = offset
            self.spacing = spacing
            self.configure = configure
            self.changed = changed
        }
    }
}

extension TextField.OverlayView {
    /// Режим видимости элемента в поле ввода
    public enum OverlayVisibleMode {
        /// Показывать всегда
        case always
        /// Показывать, когда поле активно или содержит текст
        case whenEditing
        /// Видимостью элемента управляют свойства `leftViewMode` и `rightViewMode` текстового поля
        case manual
    }

    /// Выравнивание элемента в поле ввода
    public enum OverlayAlignment {
        /// Выравнивание по центру текста
        case text
        /// Выравнивание по центру поля ввода
        case center
    }
}

// MARK: - Default styles

extension TextField.Style {
    /// Поле со стандартными настройками без форматирования и валидации
    public static var plain: Self {
        Self()
    }

    /// Поле для ввода телефона
    public static var phone: Self {
        phone(required: true)
    }

    /// Поле для ввода телефона
    /// - Parameter required: Является ли поле обязательным для заполнения
    public static func phone(required: Bool) -> Self {
        let textStyle = TextStyle.textBody
        // Label использовать нельзя, потому что на разных версиях iOS отличается сдвиг текста по вертикали
        let view = UITextField().ui
            .font(textStyle.font)
            .textColor(UIColor.lightGray)
            .text("+7", style: textStyle)
            .contentVerticalAlignment(.top)
            .isUserInteractionEnabled(false)
            .make()
        let overlayView = TextField.OverlayView(
            view: view,
            viewMode: .whenEditing,
            alignment: .text,
            offset: CGPoint(x: 14, y: 0.83),
            spacing: 3
        )
        return TextField.Style(
            placeholder: "Номер телефона",
            formatter: .none,
            validator: TextValidator(
                validators: .init(),
                required: required
            ),
            keyboardType: .phonePad,
            textContentType: .telephoneNumber,
            leftView: overlayView
        )
    }

    /// Поле для ввода почты
    public static var email: Self {
        email(required: true)
    }

    /// Поле для ввода почты
    /// - Parameter required: Является ли поле обязательным для заполнения
    public static func email(required: Bool) -> Self {
        TextField.Style(
            placeholder: "E-mail",
            validator: TextValidator(
                validators: .init(),
                required: required
            ),
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            autocapitalizationType: .none
        )
    }

//    /// Поле для ввода имени
//    public static var firstName: Self {
//        TextField.Style(
//            placeholder: "Имя",
//            validator: [.length(.maximum(50))],
//            textContentType: .name,
//            autocapitalizationType: .words
//        )
//    }

    /// Поле для ввода пароля
//    public static var password: Self {
//        let button = TextFieldEyeButton()
//        let overlayView = TextField.OverlayView(
//            view: button,
//            viewMode: .always,
//            alignment: .center,
//            configure: { [unowned button] textField in
//                button.addAction { [weak textField] in
//                    textField?.isSecureTextEntry.toggle()
//                }
//            },
//            changed: { [unowned button] textField in
//                button.isSelected = textField.isSecureTextEntry
//            }
//        )
//        return TextField.Style(
//            placeholder: L10n.TextField.passwordPlaceholder,
//            validator: [.notEmpty(), .length(.minimum(6)), .length(.maximum(50))],
//            textContentType: .password,
//            isSecureTextEntry: true,
//            rightView: overlayView
//        )
//    }

    /// Поле для ввода номера карты
//    public static var card: Self {
//        card(required: true)
//    }

//    /// Поле для ввода номера карты
//    /// - Parameter required: Является ли поле обязательным для заполнения
//    public static func card(required: Bool) -> Self {
//        TextField.Style(
//            formatter: MaskTextFormatter.card,
//            validator: TextValidator(
//                validators: [
//                    .notEmpty(error: L10n.ValidationError.Card.empty),
//                    .length(.exact(7), error: L10n.ValidationError.Card.length),
//                    .characters(.decimalDigits)
//                ],
//                required: required
//            ),
//            keyboardType: .numberPad
//        )
//    }
//
//    /// Поле для ввода числа
//    public static var decimal: Self {
//        TextField.Style(
//            formatter: NumberTextFormatter(allowsFloats: true),
//            validator: [.notEmpty(), .characters(.decimalDigits.union(CharacterSet(charactersIn: ".")))],
//            keyboardType: .decimalPad
//        )
//    }
//
//    // TODO: Перенести в сметы
//
//    /// Поле для ввода названия сметы
//    public static var estimate: Self {
//        TextField.Style(validator: TextValidator(validators: [.notEmpty(),.length(.maximum(100))], required: false))
//    }
//
//    /// Поле для ввода количества товара
//    public static func quantity(fractional: Bool) -> Self {
//        TextField.Style(
//            placeholder: L10n.Product.inputPlaceholder,
//            formatter: NumberTextFormatter(allowsFloats: fractional),
//            validator: [.notEmpty(), .range(minimum: .value(0), maximum: .value(Configuration.maximumQuantity))],
//            keyboardType: fractional ? .decimalPad : .numberPad
//        )
//    }
//
//    public static var lastName: Self {
//        Self(
//            placeholder: L10n.TextField.surnamePlaceholder,
//            validator: .length(.maximum(50)),
//            textContentType: .familyName
//        )
//    }
//
//    public static var fatherName: Self {
//        Self(
//            placeholder: L10n.TextField.fatherNamePlaceholder,
//            validator: [.notEmpty(), .length(.minimum(2)), .length(.maximum(45))],
//            textContentType: .middleName
//        )
//    }
//
//    public static var inn: Self {
//        Self(
//            placeholder: L10n.TextField.innPlaceholder,
//            formatter: MaskTextFormatter(mask: "XXXXXXXXXXXX", characters: .decimalDigits),
//            validator: [
//                .notEmpty(error: L10n.ValidationError.Inn.empty),
//                .characters(.decimalDigits),
//                .compound(L10n.ValidationError.Inn.length, rules: [.length(.exact(10)), .length(.exact(12))])
//            ],
//            keyboardType: .numberPad
//        )
//    }
//
//    public static var kpp: Self {
//        Self(
//            placeholder: L10n.TextField.kppPlaceholder,
//            formatter: MaskTextFormatter(mask: "XXXXXXXXX", characters: .decimalDigits),
//            validator: [
//                .characters(.decimalDigits),
//                .compound(L10n.ValidationError.Kpp.length, rules: [.length(.exact(0)), .length(.exact(9))])
//            ],
//            keyboardType: .numberPad
//        )
//    }
//
//    public static var comment: Self {
//        Self(placeholder: L10n.TextField.commentPlaceholder, validator: .length(.maximum(1024)))
//    }
//
//    public static var contactName: Self {
//        Self(
//            placeholder: L10n.TextField.namePlaceholder,
//            validator: [.notEmpty(), .length(.maximum(250))]
//        )
//    }
//
//    public static func coupons(limit: Int, error: String) -> Self {
//        Self(
//            formatter: NumberTextFormatter(allowsFloats: false),
//            validator: [.notEmpty(), .range(minimum: .value(1, error: error), maximum: .value(limit))],
//            keyboardType: .numberPad
//        )
//    }
//
//    public static var birthDate: Self {
//        Self(
//            placeholder: L10n.TextField.birthDatePlaceholder,
//            validator: .notEmpty(),
//            keyboardType: .decimalPad,
//            textContentType: .dateTime
//        )
//    }
//
//    public static var pincode: Self {
//        Self(
//            formatter: MaskTextFormatter(mask: "XXXX", characters: .decimalDigits),
//            validator: .notEmpty(),
//            keyboardType: .numberPad
//        )
//    }
}


/// Результат замены и форматирования текста
public enum TextFormatterResult {
    /// Замена на новый текст запрещена
    case deny
    /// Замена на новый текст разрешена
    case allow
    /// Нужно заменить на новый форматированный текст
    /// - Parameters:
    ///   - string: Новая отформатированная строка, на которую нужно произвести замену
    ///   - caret: Новая позиция курсора
    case replace(string: String, caret: Int)
}

/// Протокол, описывающий объект, который использует `TextField` для форматирования введённого текста
public protocol TextFormatter {
    /// Заменяет текст на новый и применяет к нему форматирование
    /// - Parameters:
    ///   - string: Исходная строка
    ///   - range: Диапазон символов, которые нужно заменить
    ///   - replacementString: Строка для замены
    /// - Returns: Результат замены и форматирования исходного текста
    func format(
        string: String,
        afterReplacingIn range: Range<String.Index>,
        with replacementString: String
    ) -> TextFormatterResult
    /// Применяет форматирование к заданной строке
    /// - Parameter string: Исходная строка, которую нужно отформатировать
    /// - Returns: Отформатированная строка
    func formatted(string: String) -> String
    /// Удаляет форматирование из заданной строки
    /// - Parameter string: Строка, из которой нужно удалить форматирование
    /// - Returns: Простая строка с удалённым форматированием
    func plain(string: String) -> String
}


extension ShadowView {
    struct Shadow {
        let color: UIColor
        let blur: CGFloat
        let offset: CGSize
        let spread: CGFloat
        let opacity: Float

        var radius: CGFloat {
            blur / 2
        }
    }

    /// Стиль тени
    public enum Style {
        /// Стандартная тень для всех элементов
        case main
        /// Тень для элементов управления
        case control
        /// Тень для шторок
        case sheet

        var shadows: [Shadow] {
            switch self {
            case .main:
                return [
                    Shadow(
                        color: UIColor.black.withAlphaComponent(0.06),
                        blur: 14,
                        offset: CGSize(width: 0, height: 2),
                        spread: 2,
                        opacity: 1
                    )
                ]
            case .control:
                return [
                    Shadow(
                        color: UIColor.black.withAlphaComponent(0.02),
                        blur: 1,
                        offset: CGSize(width: 0, height: 1),
                        spread: 0,
                        opacity: 1
                    ),
                    Shadow(
                        color: UIColor.black.withAlphaComponent(0.12),
                        blur: 6,
                        offset: CGSize(width: 0, height: 3),
                        spread: 0,
                        opacity: 1
                    )
                ]
            case .sheet:
                return [
                    Shadow(
                        color: UIColor.black.withAlphaComponent(0.06),
                        blur: 14,
                        offset: CGSize(width: 0, height: -2),
                        spread: 2,
                        opacity: 1
                    )
                ]
            }
        }
    }
}

/// Визуальный элемент для отображения тени
public final class ShadowView: UIView {
    private let layers: [(layer: CALayer, shadow: Shadow)]

    // MARK: Initialization

    /// Создаёт элемент для отображения тени
    /// - Parameter style: Стиль тени
    public init(style: Style) {
        layers = style.shadows.map { (CALayer(), $0) }
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layers.forEach { $0.layer.shadowColor = $0.shadow.color.cgColor }
        }
    }

    override public func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)

        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor)
        ])
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard let layer = subviews.last?.layer else {
            layers.forEach { $0.layer.shadowPath = nil }
            return
        }

        func bezierPath(spread: CGFloat) -> UIBezierPath? {
            let bounds = layer.bounds.insetBy(dx: -spread, dy: -spread)
            guard !bounds.isEmpty else {
                return nil
            }
            guard layer.cornerRadius > 0 else {
                return UIBezierPath(rect: bounds)
            }
            guard !layer.maskedCorners.isEmpty else {
                return UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
            }

            let maskedCorners: [(CACornerMask, UIRectCorner)] = [
                (.layerMinXMinYCorner, .topLeft),
                (.layerMaxXMinYCorner, .topRight),
                (.layerMaxXMaxYCorner, .bottomRight),
                (.layerMinXMaxYCorner, .bottomLeft)
            ]
            let corners: UIRectCorner = maskedCorners.reduce(into: UIRectCorner()) {
                if layer.maskedCorners.contains($1.0) {
                    $0.insert($1.1)
                }
            }
            let radii = CGSize(width: layer.cornerRadius, height: layer.cornerRadius)

            return UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: radii)
        }

        layers.forEach { $0.layer.shadowPath = bezierPath(spread: $0.shadow.spread)?.cgPath }
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        layers.forEach { $0.layer.frame = layer.bounds }
    }

    // MARK: Configuration

    private func configure() {
        layers.forEach { layer, shadow in
            layer.shadowColor = shadow.color.cgColor
            layer.shadowRadius = shadow.radius
            layer.shadowOffset = shadow.offset
            layer.shadowOpacity = shadow.opacity
            self.layer.addSublayer(layer)
        }
    }
}


/// Однострочное текстовое поле
public final class TextField: UITextField {
    private let backgroundLayer = CAShapeLayer().ui
        .fillColor(UIColor.white.cgColor)
        .lineWidth(Constants.borderWidth)
        .make()
    private let placeholderLabel = Label().ui
        .textStyle(.textBody)
        .textColor(UIColor.gray)
        .make()
    private let errorLabel = Label().ui
        .textStyle(.subheader)
        .textColor(UIColor.red)
        .numberOfLines(3)
        .make()

    // MARK: Properties

    /// Нужно ли показывать рамку вокруг текстового поля
    ///
    /// Значение по умолчанию `true`
    public var isBordered = true {
        didSet {
            backgroundLayer.lineWidth = isBordered ? Constants.borderWidth : 0
        }
    }

    /// Должна ли подсказка сдвигаться к верхней границе текстового поля при наличии текста или фокуса
    ///
    /// Значение по умолчанию `true`
    public var isFloatingPlaceholder = true {
        didSet {
            if isFloatingPlaceholder {
                attributedPlaceholder = nil
                placeholderLabel.isHidden = false
            } else {
                attributedPlaceholder = placeholderLabel.attributedText
                placeholderLabel.isHidden = true
                updatePlaceholder(animated: false)
            }
        }
    }

    /// Максимальное количество строк для вывода ошибки
    ///
    /// Если значение свойства равно 0, то выводится весь текст без ограничений.
    ///
    /// Значение по умолчанию 3
    public var numberOfLinesForError: Int = 3 {
        didSet {
            guard errorLabel.numberOfLines != numberOfLinesForError else {
                return
            }

            errorLabel.numberOfLines = numberOfLinesForError
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    /// Нужно ли автоматически проверять введённое значение при потере полем фокуса
    ///
    /// Значение по умолчанию `true`
    public var validatesTextAutomatically = true

    /// Проверяет введённое значение на корректность. При провале выводит текст ошибки
    ///
    /// Если возвращается `false`, то `errorMessage` содержит текст ошибки
    public var isValid: Bool {
        validateText()
        return !hasErrorMessage
    }

    /// Ошибка, которая отображается под текстовым полем
    ///
    /// Когда `isValid` возвращает `false`, это свойство содержит текст ошибки.
    ///
    /// Значение `nil` скрывает ошибку
    public var errorMessage: String? {
        didSet {
            guard errorMessage != oldValue else {
                return
            }

            updateState()
            errorLabel.text = errorMessage
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    /// Содержимое текстового поля с удалённым форматированием
    public var plainText: String {
        guard let formatter else {
            return text ?? ""
        }
        return formatter.plain(string: text ?? "")
    }

    private let style: Style
    private var formatter: TextFormatter?
    private var validator: TextValidator?
    private weak var _delegate: UITextFieldDelegate?
    private var cutSender: Any?
    private var preventPlaceholderUpdates = false
    private var isEditingMode: Bool {
        isEditing || hasText
    }
    private var hasErrorMessage: Bool {
        errorMessage != nil
    }

    override public var text: String? {
        get {
            super.text
        }
        set {
            super.text = formatter?.formatted(string: newValue ?? "") ?? newValue
            errorMessage = nil
            updateState()
        }
    }

    override public var placeholder: String? {
        get {
            placeholderLabel.text
        }
        set {
            placeholderLabel.text = newValue
            if !isFloatingPlaceholder {
                attributedPlaceholder = placeholderLabel.attributedText
            }
        }
    }

    override public var isSecureTextEntry: Bool {
        didSet {
            if let overlay = style.leftView {
                overlay.changed?(self)
            }
            if let overlay = style.rightView {
                overlay.changed?(self)
            }
            fixCaretPosition()
        }
    }

    override public var delegate: UITextFieldDelegate? {
        get {
            _delegate
        }
        set {
            _delegate = newValue
        }
    }

    override public var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = Constants.height
        if hasErrorMessage {
            size.height += errorRect(for: bounds).height + Constants.errorSpacing - Constants.singleLineErrorHeight
        }
        return size
    }

    override public var alignmentRectInsets: UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: Constants.singleLineErrorHeight, right: 0)
    }

    // MARK: Initialization

    public init(style: Style, placeholder: String? = nil) {
        self.style = style
        super.init(frame: .zero)
        configure(placeholder: placeholder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            backgroundLayer.fillColor = UIColor.lightGray.cgColor
            updateBorderColor()
        }
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard hasErrorMessage else {
            return bounds.inset(by: alignmentRectInsets).contains(point)
        }
        return super.point(inside: point, with: event)
    }

    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        textRect(for: super.textRect(forBounds: bounds))
    }

    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        textRect(for: super.editingRect(forBounds: bounds))
    }

    override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.clearButtonRect(forBounds: bounds)
        return clearButtonRect(rect, for: bounds)
    }

    override public func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.leftViewRect(forBounds: bounds)
        guard let view = style.leftView else {
            return rect
        }
        return overlayRect(view, with: rect, for: bounds)
    }

    override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.rightViewRect(forBounds: bounds)
        guard let view = style.rightView else {
            return rect
        }
        return overlayRect(view, with: rect, for: bounds)
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = Constants.height
        if hasErrorMessage {
            size.height += errorRect(for: bounds).height + Constants.errorSpacing
        }
        return size
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        placeholderLabel.frame = placeholderRect(for: bounds)

        let errorHeight = errorLabel.frame.height
        errorLabel.frame = errorRect(for: bounds)
        if errorLabel.frame.height != errorHeight {
            invalidateIntrinsicContentSize()
        }
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        backgroundLayer.frame = layer.bounds
        let inset = Constants.borderWidth / 2
        let rect = backgroundRect(for: layer.bounds).insetBy(dx: inset, dy: inset)
        backgroundLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: Constants.cornerRadius).cgPath
    }

    // MARK: Configuration

    private func configure(placeholder: String?) {
        super.delegate = self

        placeholderLabel.layer.anchorPoint = .zero
        placeholderLabel.text = placeholder ?? style.placeholder

        layer.addSublayer(backgroundLayer)
        addSubview(placeholderLabel)
        addSubview(errorLabel)

        let textStyle = TextStyle.textBody
        let attributes = textStyle.attributes(for: self).asDictionary
        defaultTextAttributes = attributes
        typingAttributes = attributes
        font = textStyle.font
        textColor = UIColor.lightGray
        tintColor = UIColor.blue
        keyboardType = style.keyboardType
        textContentType = style.textContentType
        autocorrectionType = style.autocorrectionType
        autocapitalizationType = style.autocapitalizationType
        isSecureTextEntry = style.isSecureTextEntry
        formatter = style.formatter
        validator = style.validator

        if let overlay = style.leftView {
            overlay.configure?(self)
            leftView = overlay.view
        }
        if let overlay = style.rightView {
            overlay.configure?(self)
            rightView = overlay.view
        }

        contentVerticalAlignment = .top
        updateState()

        let selector = "clearButton"
    }

    // MARK: Message forwarding

    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        if _delegate?.responds(to: aSelector) == true {
            return _delegate
        }
        return super.forwardingTarget(for: aSelector)
    }

    override public func responds(to aSelector: Selector!) -> Bool {
        if _delegate?.responds(to: aSelector) == true {
            return true
        }
        return super.responds(to: aSelector)
    }

    // MARK: First responder

    @discardableResult
    override public func becomeFirstResponder() -> Bool {
        defer {
            updateState()
        }
        return super.becomeFirstResponder()
    }

    @discardableResult
    override public func resignFirstResponder() -> Bool {
        defer {
            updateState()
        }
        return super.resignFirstResponder()
    }

    // MARK: Actions

    override public func cut(_ sender: Any?) {
        cutSender = sender
        super.cut(sender)
        cutSender = nil
    }

    // MARK: Validation

    private func validateText() {
        guard let validator else {
            return
        }

        do {
            try validator.validate(string: plainText)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Private

    private enum Constants {
        static let height: CGFloat = 56
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let textInset = UIEdgeInsets(top: 26, left: 14, bottom: 10, right: 14)
        static let centerTextInset = UIEdgeInsets(top: 18, left: 14, bottom: 18, right: 14)
        static let placeholderScale: CGFloat = 0.86
        static let errorSpacing: CGFloat = 4
        static let singleLineErrorHeight: CGFloat = errorSpacing + 16
    }
}

// MARK: - View updates

extension TextField {
    private func updateState() {
        updateBorderColor()
        updatePlaceholder(animated: true)
        updateOverlayViews()
    }

    private func updateBorderColor() {
        if hasErrorMessage {
            backgroundLayer.strokeColor = UIColor.red.cgColor
        } else if isEditing {
            backgroundLayer.strokeColor = UIColor.blue.cgColor
        } else {
            backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        }
    }

    private func updatePlaceholder(animated: Bool) {
        if preventPlaceholderUpdates {
            preventPlaceholderUpdates = false
            return
        }

        guard !placeholderLabel.isHidden else {
            return
        }

        let scale = isEditingMode ? Constants.placeholderScale : 1.0
        let transform = CATransform3DMakeScale(scale, scale, scale)
        guard !CATransform3DEqualToTransform(placeholderLabel.transform3D, transform) else {
            return
        }

        let animated = animated && window != nil
        let frame = placeholderRect(for: bounds)
        let animations = {
            self.placeholderLabel.transform3D = transform
            self.placeholderLabel.frame = frame
        }
        if animated {
            UIView.animate(withDuration: isEditingMode ? 0.2 : 0.3, animations: animations)
        } else {
            animations()
        }
    }

    private func updateOverlayViews() {
        if let overlayView = style.leftView {
            switch overlayView.viewMode {
            case .always:
                leftViewMode = .always
            case .whenEditing:
                leftViewMode = isEditingMode ? .always : .never
            case .manual:
                break
            }
        }
        if let overlayView = style.rightView {
            switch overlayView.viewMode {
            case .always:
                rightViewMode = .always
            case .whenEditing:
                rightViewMode = isEditingMode ? .always : .never
            case .manual:
                break
            }
        }
    }
}

// MARK: - Positioning

extension TextField {
    private func backgroundRect(for bounds: CGRect) -> CGRect {
        CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: Constants.height)
    }

    private func textRect(for bounds: CGRect) -> CGRect {
        var inset = isFloatingPlaceholder ? Constants.textInset : Constants.centerTextInset
        if let overlay = style.leftView {
            switch overlay.viewMode {
            case .always,
                .whenEditing where isEditingMode,
                .manual:
                inset.left = overlay.spacing
            case .whenEditing:
                break
            }
        }
        if let overlay = style.rightView {
            switch overlay.viewMode {
            case .always,
                .whenEditing where isEditingMode,
                .manual:
                inset.right = overlay.spacing
            case .whenEditing:
                break
            }
        }
        return backgroundRect(for: bounds).inset(by: inset)
    }

    private func placeholderRect(for bounds: CGRect) -> CGRect {
        let height = placeholderLabel.sizeThatFits(bounds.size).height
        var rect = CGRect(x: Constants.textInset.left, y: 7.5, width: 0, height: height)
        if isFloatingPlaceholder, isEditingMode {
            let width = bounds.width - Constants.textInset.left - Constants.textInset.right
            rect.size.width = width / Constants.placeholderScale
        } else {
            rect.origin.y = (Constants.height - rect.height) / 2
            rect.size.width = textRect(forBounds: bounds).width
        }
        return rect
    }

    private func clearButtonRect(_ rect: CGRect, for bounds: CGRect) -> CGRect {
        var rect = rect
        rect.origin.x -= 8
        rect.origin.y = backgroundRect(for: bounds).midY - rect.height / 2
        return rect
    }

    private func overlayRect(_ view: TextField.OverlayView, with rect: CGRect, for bounds: CGRect) -> CGRect {
        var rect = rect
        switch view.alignment {
        case .text:
            rect.origin.y = textRect(for: bounds).midY - rect.height / 2
        case .center:
            rect.origin.y = backgroundRect(for: bounds).midY - rect.height / 2
        }
        return rect.offsetBy(dx: view.offset.x, dy: view.offset.y)
    }

    private func errorRect(for bounds: CGRect) -> CGRect {
        guard hasErrorMessage else {
            return CGRect(x: 0, y: Constants.height, width: bounds.width, height: 0)
        }

        let height = errorLabel.sizeThatFits(bounds.size).height
        return CGRect(x: 0, y: Constants.height + Constants.errorSpacing, width: bounds.width, height: height)
    }
}

// MARK: - Helpers

extension TextField {
    private func fixCaretPosition() {
        // Moving the caret to the correct position by removing the trailing whitespace
        // http://stackoverflow.com/questions/14220187
        let beginning = beginningOfDocument
        selectedTextRange = textRange(from: beginning, to: beginning)
        let end = endOfDocument
        selectedTextRange = textRange(from: end, to: end)
    }
}

// MARK: - UITextFieldDelegate

extension TextField: UITextFieldDelegate {
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if validatesTextAutomatically {
            validateText()
        }
        _delegate?.textFieldDidEndEditing?(textField)
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if _delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) == false {
            return false
        }

        guard let formatter, let text = textField.text, let range = Range(range, in: text) else {
            errorMessage = nil
            return true
        }

        switch formatter.format(string: text, afterReplacingIn: range, with: string) {
        case .deny:
            return false
        case .allow:
            errorMessage = nil
            return true
        case let .replace(string, caret):
            if let cutSender {
                // Операция контекстного меню "Вырезать" вызывает этот метод для изменения текста.
                // Так как мы возвращаем false, то она прерывается.
                // Поэтому мы дополнительно вызываем copy(_:) с sender, полученным в cut(_:),
                // чтобы записать выбранный текст в буфер обмена
                copy(cutSender)
            }
            super.text = string
            if let position = textField.position(from: textField.beginningOfDocument, offset: caret) {
                DispatchQueue.main.async {
                    let textRange = textField.textRange(from: position, to: position)
                    if textField.selectedTextRange != textRange {
                        textField.selectedTextRange = textRange
                    }
                }
            }
            errorMessage = nil
            sendActions(for: .editingChanged)
            return false
        }
    }

    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if _delegate?.textFieldShouldClear?(textField) == false {
            return false
        }

        preventPlaceholderUpdates = !textField.isFirstResponder
        return true
    }
}

import UIKit

extension Button {
    /// Размер кнопки
    public enum Size {
        /// Большая кнопка
        case medium
        /// Маленькая кнопка
        case small
    }

    /// Объект, описывающий стиль отображения кнопки
    public struct Style {
        /// Замыкание принимает флаги наличия заголовка, подзаголовка и изображения.
        /// Возвращает отступы контента от границ кнопки
        public typealias ContentInsetsResolver =
            (_ title: Bool, _ subtitle: Bool, _ image: Bool) -> NSDirectionalEdgeInsets

        /// Базовая конфигурация кнопки
        public let configuration: UIButton.Configuration
        /// Цвет фона кнопки
        public let backgroundColor: UIColor?
        /// Цвет границы вокруг кнопки
        public let borderColor: UIColor?
        /// Ширина границы вокруг кнопки
        public let borderWidth: CGFloat
        /// Размер скругления углов
        public let cornerRadius: CGFloat
        /// Отступ контента от границы кнопки
        public let contentInsets: ContentInsetsResolver
        /// Дополнительная область вокруг кнопки, которая должна считаться её частью при обработке нажатий
        public let additionalTouchInsets: UIEdgeInsets
        /// Стиль отображения заголовка
        public let titleTextStyle: TextStyle
        /// Стиль отображения подзаголовка
        public let subtitleTextStyle: TextStyle
        /// Выравнивание заголовка и подзаголовка относительно друг друга
        public let titleAlignment: UIButton.Configuration.TitleAlignment
        /// Расстояние между заголовком и подзаголовком
        public let titlePadding: CGFloat
        /// Цвет текста и изображения
        public let color: UIColor
        /// Цвет текста и изображения, когда кнопка выделена
        public let highlightedColor: UIColor
        /// Граница, у которой кнопка располагает изображение
        public let imagePlacement: NSDirectionalRectEdge
        /// Расстояние между изображением и заголовком
        public let imagePadding: CGFloat
        /// Стиль индикатора загрузки
        public let indicatorStyle: IndicatorView.Style

        // MARK: Initialization

        /// Создаёт объект, описывающий стиль отображения кнопки
        /// - Parameters:
        ///   - configuration: Базовая конфигурация кнопки
        ///   - backgroundColor: Цвет фона кнопки
        ///   - borderColor: Цвет границы вокруг кнопки
        ///   - borderWidth: Ширина границы вокруг кнопки
        ///   - cornerRadius: Размер скругления углов
        ///   - contentInsets: Отступ контента от границы кнопки
        ///   - additionalTouchInsets: Дополнительная область вокруг кнопки,
        ///   которая должна считаться её частью при обработке нажатий
        ///   - titleTextStyle: Стиль отображения заголовка
        ///   - subtitleTextStyle: Стиль отображения подзаголовка
        ///   - titleAlignment: Выравнивание заголовка и подзаголовка относительно друг друга
        ///   - titlePadding: Расстояние между заголовком и подзаголовком
        ///   - color: Цвет текста и изображения
        ///   - highlightedColor: Цвет текста и изображения, когда кнопка выделена
        ///   - imagePlacement: Граница, у которой кнопка располагает изображение
        ///   - imagePadding: Расстояние между изображением и заголовком
        ///   - indicatorStyle: Стиль индикатора загрузки
        public init(
            configuration: UIButton.Configuration = .plain(),
            backgroundColor: UIColor? = nil,
            borderColor: UIColor? = nil,
            borderWidth: CGFloat = 1,
            cornerRadius: CGFloat = 6,
            contentInsets: @escaping ContentInsetsResolver = { _, _, _ in .zero },
            additionalTouchInsets: UIEdgeInsets = UIEdgeInsets(top: -12, left: -16, bottom: -12, right: -16),
            titleTextStyle: TextStyle = .textBody,
            subtitleTextStyle: TextStyle = .caption,
            titleAlignment: UIButton.Configuration.TitleAlignment = .center,
            titlePadding: CGFloat = -2,
            color: UIColor = UIColor.gray,
            highlightedColor: UIColor = UIColor.gray.withAlphaComponent(0.45),
            imagePlacement: NSDirectionalRectEdge = .leading,
            imagePadding: CGFloat = 8,
            indicatorStyle: IndicatorView.Style = .black
        ) {
            self.configuration = configuration
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.borderWidth = borderWidth
            self.cornerRadius = cornerRadius
            self.contentInsets = contentInsets
            self.additionalTouchInsets = additionalTouchInsets
            self.titleTextStyle = titleTextStyle
            self.subtitleTextStyle = subtitleTextStyle
            self.titleAlignment = titleAlignment
            self.titlePadding = titlePadding
            self.color = color
            self.highlightedColor = highlightedColor
            self.imagePlacement = imagePlacement
            self.imagePadding = imagePadding
            self.indicatorStyle = indicatorStyle
        }
    }
}

import Foundation

/// Объект, который поддерживает обновление неизменяемых свойств
public protocol Changeable {
    /// Создаёт новый экземпляр из объекта, предоставляющего новые значения для всех свойств
    /// - Parameter changed: Объект, предоставляющего новые значения для всех свойств
    init(_ changed: ChangeableWrapper<Self>)
}

extension Changeable {
    /// Создаёт копию объекта с изменёнными свойствами
    /// - Parameter changes: Замыкание, изменяющее свойства объекта
    /// - Returns: Новый объект с изменёнными свойствами
    public func changing(_ changes: (inout ChangeableWrapper<Self>) -> Void) -> Self {
        var wrapper = ChangeableWrapper(self)
        changes(&wrapper)
        return Self(wrapper)
    }

    /// Изменяет свойства объекта
    /// - Parameter changes: Замыкание, изменяющее свойства объекта
    public mutating func change(_ changes: (inout ChangeableWrapper<Self>) -> Void) {
        var wrapper = ChangeableWrapper(self)
        changes(&wrapper)
        self = Self(wrapper)
    }
}

// MARK: -

extension Array where Element: Changeable {
    /// Возвращает новый массив, состоящий из обновлённых элементов
    /// - Parameter changes: Замыкание, которое изменяет свойства объекта. Применяется к каждому элементу массива
    /// - Returns: Новый массив, состоящий из обновлённых элементов
    public func changing(_ changes: (inout ChangeableWrapper<Element>) -> Void) -> Self {
        map { $0.changing(changes) }
    }

    /// Обновляет элементы массива
    /// - Parameter changes: Замыкание, которое изменяет свойства объекта. Применяется к каждому элементу массива
    public mutating func change(_ changes: (inout ChangeableWrapper<Element>) -> Void) {
        self = map { $0.changing(changes) }
    }
}

import Foundation

/// Обёртка, которая хранит новые значения для свойств объекта
@dynamicMemberLookup
public struct ChangeableWrapper<Wrapped> {
    private let wrapped: Wrapped
    private var changes = [PartialKeyPath<Wrapped>: Any]()

    // MARK: Initialization

    init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    // MARK: Dynamic member lookup

    public subscript<Value>(dynamicMember keyPath: KeyPath<Wrapped, Value>) -> Value {
        get {
            changes[keyPath].flatMap { $0 as? Value } ?? wrapped[keyPath: keyPath]
        }
        set {
            changes[keyPath] = newValue
        }
    }

    public subscript<Value: Changeable>(dynamicMember keyPath: KeyPath<Wrapped, Value>) -> ChangeableWrapper<Value> {
        get {
            ChangeableWrapper<Value>(self[dynamicMember: keyPath])
        }
        set {
            self[dynamicMember: keyPath] = Value(newValue)
        }
    }
}


// MARK: - Changeable

extension Button.Style: Changeable {
    public init(_ changed: ChangeableWrapper<Button.Style>) {
        configuration = changed.configuration
        backgroundColor = changed.backgroundColor
        borderColor = changed.borderColor
        borderWidth = changed.borderWidth
        cornerRadius = changed.cornerRadius
        contentInsets = changed.contentInsets
        additionalTouchInsets = changed.additionalTouchInsets
        titleTextStyle = changed.titleTextStyle
        subtitleTextStyle = changed.subtitleTextStyle
        titleAlignment = changed.titleAlignment
        titlePadding = changed.titlePadding
        color = changed.color
        highlightedColor = changed.highlightedColor
        imagePlacement = changed.imagePlacement
        imagePadding = changed.imagePadding
        indicatorStyle = changed.indicatorStyle
    }
}

// MARK: - Default styles

extension Button.Style {
    /// Жёлтая кнопка
    /// - Parameter size: Размер кнопки
    /// - Returns: Стиль для отображения жёлтой кнопки
    public static func yellow(_ size: Button.Size) -> Self {
        Button.Style(
            configuration: .filled(),
            backgroundColor: UIColor.yellow,
            contentInsets: contentInsetsResolver(for: size),
            additionalTouchInsets: additionalTouchInsets(for: size),
            titleTextStyle: titleTextStyle(for: size),
            color: UIColor.systemOrange,
            highlightedColor: UIColor.systemOrange.withAlphaComponent(0.7)
        )
    }

    /// Серая кнопка
    /// - Parameter size: Размер кнопки
    /// - Returns: Стиль для отображения серой кнопки
    public static func gray(_ size: Button.Size) -> Self {
        Button.Style(
            configuration: .filled(),
            backgroundColor: .gray,
            contentInsets: contentInsetsResolver(for: size),
            additionalTouchInsets: additionalTouchInsets(for: size),
            titleTextStyle: titleTextStyle(for: size),
            color: .gray,
            highlightedColor: .lightGray
        )
    }

    /// Кнопка с границей
    public static var bordered: Self {
        Button.Style(
            configuration: .filled(),
            backgroundColor: .white,
            borderColor: .darkGray,
            contentInsets: { _, _, _ in NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10) },
            additionalTouchInsets: UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8),
            titleTextStyle: .title4,
            color: .gray,
            highlightedColor: .lightGray
        )
    }

    /// Кнопка для открытия ссылок
    public static var link: Self {
        Button.Style(
            titleTextStyle: .btnLink,
            color: UIColor.blue,
            highlightedColor: UIColor.blue.withAlphaComponent(0.45)
        )
    }

    /// Простая кнопка
    public static var plain: Self {
        Button.Style()
    }

    public static func white(_ size: Button.Size) -> Self {
        .yellow(size).changing {
            $0.backgroundColor = .white
        }
    }

    // MARK: Private

    private static func contentInsetsResolver(for size: Button.Size) -> ContentInsetsResolver {
        switch size {
        case .medium:
            return { title, subtitle, image in
                if !title, image {
                    return NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                } else if subtitle {
                    return NSDirectionalEdgeInsets(top: 3, leading: 20, bottom: 7, trailing: 20)
                } else {
                    return NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                }
            }
        case .small:
            return { title, _, image in
                if title, image {
                    return NSDirectionalEdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16)
                } else if image {
                    return NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
                } else {
                    return NSDirectionalEdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 16)
                }
            }
        }
    }

    private static func additionalTouchInsets(for size: Button.Size) -> UIEdgeInsets {
        switch size {
        case .medium:
            return .zero
        case .small:
            return UIEdgeInsets(top: -5, left: -8, bottom: -5, right: -8)
        }
    }

    private static func titleTextStyle(for size: Button.Size) -> TextStyle {
        switch size {
        case .medium:
            return .btnL
        case .small:
            return .btnM
        }
    }
}

import UIKit

/// Кнопка, настроенная для проекта
public final class Button: UIButton {
    private let indicatorView = IndicatorView(style: .black).ui.forAutoLayout()

    // MARK: Properties

    /// Стиль отображения кнопки
    public var style: Style {
        didSet {
            apply(style: style)
            setNeedsUpdateConfiguration()
        }
    }

    /// Заголовок кнопки
    public var title: String? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    /// Подзаголовок кнопки
    public var subtitle: String? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    /// Изображение, отображаемое в кнопке
    public var image: UIImage? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    /// Изображение, отображаемое в кнопке, когда она выделена
    ///
    /// Если значение равно `nil`, то используется изображение из `image`
    ///
    /// Значение по умолчанию `nil`
    public var highlightedImage: UIImage? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    /// Выравнивание текста, которое применяет к заголовку и подзаголовку
    ///
    /// Значение по умолчанию `.center`
    public var textAlignment: NSTextAlignment = .center {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    /// Нужно ли показывать состояние загрузки в кнопке
    ///
    /// Значение по умолчанию `false`
    public var isLoading = false {
        didSet {
            guard isLoading != oldValue else {
                return
            }

            if isLoading {
                indicatorView.startAnimating()
            } else {
                indicatorView.stopAnimating()
            }
            updateLayout()
            setNeedsUpdateConfiguration()
        }
    }

    /// Дополнительная область вокруг кнопки, которая должна считаться её частью при обработке нажатий
    ///
    /// Значение по умолчанию `.zero`
    public var additionalTouchInsets: UIEdgeInsets = .zero

    // MARK: Initialization

    public init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        return isLoading ? indicatorView : view
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let insets = additionalTouchInsets != .zero ? additionalTouchInsets : style.additionalTouchInsets
        return bounds.inset(by: insets).contains(point)
    }

    override public func updateConfiguration() {
        super.updateConfiguration()

        guard var config = configuration else {
            return
        }

        let color: UIColor
        switch (state, isLoading) {
        case (_, true):
            color = .clear
        case (.highlighted, _):
            color = style.highlightedColor
        default:
            color = style.color
        }

        config.contentInsets = style.contentInsets(title?.isNotEmpty ?? false, subtitle?.isNotEmpty ?? false, image != nil)

        var attributes = style.titleTextStyle.attributes(textAlignment: textAlignment)
        attributes.uiKit.foregroundColor = color
        config.attributedTitle = AttributedString(title ?? "", attributes: attributes)

        if let subtitle, subtitle.isNotEmpty {
            var attributes = style.subtitleTextStyle.attributes(textAlignment: textAlignment)
            attributes.uiKit.foregroundColor = color
            config.attributedSubtitle = AttributedString(subtitle, attributes: attributes)
        } else {
            config.attributedSubtitle = nil
        }

        if state.contains(.highlighted), let image = highlightedImage {
            config.image = image
            config.imageColorTransformer = nil
        } else {
            config.image = image?.renderingMode == .automatic ? image?.withRenderingMode(.alwaysTemplate) : image
            config.imageColorTransformer = UIConfigurationColorTransformer { _ in
                color
            }
        }

        configuration = config
    }

    // MARK: Configuration

    private func configure() {
//        indicatorView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        apply(style: style)
    }

    private func updateLayout() {
        if isLoading, indicatorView.superview == nil {
            addSubview(indicatorView)
            NSLayoutConstraint.activate([
                indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
                indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
                indicatorView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.55)
            ])
        }
        if !isLoading, indicatorView.superview != nil {
            indicatorView.removeFromSuperview()
        }
    }

    private func apply(style: Style) {
        var config = style.configuration
        if let backgroundColor = style.backgroundColor {
            config.background.backgroundColor = backgroundColor
        }
        if let borderColor = style.borderColor {
            config.background.strokeColor = borderColor
            config.background.strokeWidth = style.borderWidth
        }
        config.background.cornerRadius = style.cornerRadius
        config.titleAlignment = style.titleAlignment
        config.titlePadding = style.titlePadding
        config.imagePlacement = style.imagePlacement
        config.imagePadding = style.imagePadding

        configuration = config

        indicatorView.style = style.indicatorStyle
    }
}

import UIKit

// swiftlint:disable attributed_string

/// Текстовое поле с поддержкой интерактивных элементов
public final class InteractiveLabel: UILabel {
    /// Массив интерактивных элементов в текстовом поле
    public var elements: [Element] = [] {
        didSet {
            updateTextStorage(detect: true)
        }
    }

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
            updateTextStorage()
        }
    }

    private let textContainer = NSTextContainer()
    private let layoutManager = NSLayoutManager()
    private let textStorage = NSTextStorage()

    private var interactiveElements = [InteractiveElement]()
    private var selectedElement: InteractiveElement? {
        willSet {
            highlightSelectedElement(false)
        }
        didSet {
            highlightSelectedElement(true)
        }
    }
    private var cachedRegexes = [String: NSRegularExpression]()

    // MARK: Properties (Override)

    override public var text: String? {
        didSet {
            updateTextStorage(detect: true)
        }
    }

    override public var attributedText: NSAttributedString? {
        didSet {
            updateTextStorage(detect: true)
        }
    }

    override public var font: UIFont! {
        didSet {
            updateTextStorage()
        }
    }

    override public var textColor: UIColor! {
        didSet {
            updateTextStorage()
        }
    }

    override public var textAlignment: NSTextAlignment {
        didSet {
            updateTextStorage()
        }
    }

    override public var lineBreakMode: NSLineBreakMode {
        didSet {
            textContainer.lineBreakMode = lineBreakMode
        }
    }

    override public var numberOfLines: Int {
        didSet {
            textContainer.maximumNumberOfLines = numberOfLines
        }
    }

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        textContainer.size = rect.insetBy(dx: -rect.origin.x, dy: -rect.origin.y).size
    }

    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard
            gestureRecognizer is UITapGestureRecognizer,
            let view = gestureRecognizer.view,
            isDescendant(of: view)
        else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        return interactiveElement(at: gestureRecognizer.location(in: self)) == nil
    }

    // MARK: Configuration

    private func configure() {
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        isUserInteractionEnabled = true
    }

    // MARK: Touches

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let touch = touches.first,
            let element = interactiveElement(at: touch.location(in: self))
        else {
            super.touchesBegan(touches, with: event)
            return
        }

        selectedElement = element
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            super.touchesMoved(touches, with: event)
            return
        }

        guard let element = interactiveElement(at: touch.location(in: self)) else {
            self.selectedElement = nil
            return
        }

        if element != selectedElement {
            self.selectedElement = element
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let selectedElement else {
            super.touchesEnded(touches, with: event)
            return
        }

        self.selectedElement = nil
        selectedElement.data.handler(selectedElement.text)
    }

    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard selectedElement != nil else {
            super.touchesCancelled(touches, with: event)
            return
        }

        selectedElement = nil
    }
}

// MARK: - Private

extension InteractiveLabel {
    private func updateTextStorage(detect: Bool = false) {
        guard let attributedText, attributedText.length > 0 else {
            clearInteractiveElements()
            textStorage.setAttributedString(NSAttributedString())
            return
        }

        if detect {
            clearInteractiveElements()
            detectInteractiveElements(in: attributedText)
        }

        textStorage.setAttributedString(storageAttributedText(from: attributedText))
        super.attributedText = labelAttributedText(from: attributedText)
    }

    private func interactiveElement(at location: CGPoint) -> InteractiveElement? {
        guard !interactiveElements.isEmpty, textStorage.length > 0 else {
            return nil
        }

        if let element = element(at: location) {
            return element
        }

        for radius in [2.5, 5, 7.5] {
            if let element = element(atRadius: radius, around: location) {
                return element
            }
        }
        return nil
    }

    private func element(atRadius radius: CGFloat, around location: CGPoint) -> InteractiveElement? {
        let diagonal = sqrt(2 * pow(radius, 2))
        let deltas: [CGPoint] = [
            CGPoint(x: diagonal, y: diagonal),
            CGPoint(x: 0, y: radius),
            CGPoint(x: -diagonal, y: diagonal),
            CGPoint(x: radius, y: 0),
            CGPoint(x: -radius, y: 0),
            CGPoint(x: diagonal, y: -diagonal),
            CGPoint(x: 0, y: -radius),
            CGPoint(x: -diagonal, y: -diagonal)
        ]

        for delta in deltas {
            if let element = element(at: CGPoint(x: location.x + delta.x, y: location.y + delta.y)) {
                return element
            }
        }
        return nil
    }

    private func element(at location: CGPoint) -> InteractiveElement? {
        let range = NSRange(location: 0, length: textStorage.length)
        let boundingRect = layoutManager.boundingRect(forGlyphRange: range, in: textContainer)
        guard boundingRect.contains(location) else {
            return nil
        }

        let index = layoutManager.glyphIndex(for: location, in: textContainer)
        return interactiveElements.first { $0.range.contains(index) }
    }
}

// MARK: - Attributes

extension InteractiveLabel {
    private func textAttributes(for style: TextStyle?) -> [NSAttributedString.Key: Any] {
        style?.attributes(for: self).asDictionary ?? [:]
    }

    private func storageAttributedText(from string: NSAttributedString) -> NSAttributedString {
        var attributes = textAttributes(for: textStyle)
        attributes[.font] = font

        var paragraph: NSMutableParagraphStyle
        if let paragraphStyle = attributes[.paragraphStyle] as? NSMutableParagraphStyle {
            paragraph = paragraphStyle
        } else {
            paragraph = NSMutableParagraphStyle()
        }
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = textAlignment

        attributes[.paragraphStyle] = paragraph

        let string = NSMutableAttributedString(attributedString: string)
        string.addAttributes(attributes, range: NSRange(location: 0, length: string.length))
        applyElementsAttributes(to: string)
        return string
    }

    private func labelAttributedText(from string: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: string)
        string.addAttributes(textAttributes(for: textStyle), range: NSRange(location: 0, length: string.length))
        applyElementsAttributes(to: string)
        return string
    }

    private func applyElementsAttributes(to string: NSMutableAttributedString) {
        for element in interactiveElements {
            let config = element.data.configuration
            var attributes = textAttributes(for: config.textStyle)
            if let font = config.textStyle?.font {
                attributes[.font] = font
            }
            if let color = config.textColor {
                attributes[.foregroundColor] = color
            }
            string.addAttributes(attributes, range: element.range)
        }
    }

    private func highlightSelectedElement(_ highlighted: Bool) {
        guard let selectedElement, let attributedText else {
            return
        }

        let config = selectedElement.data.configuration
        guard let color = highlighted ? config.highlightedTextColor : config.textColor else {
            return
        }

        let string = NSMutableAttributedString(attributedString: attributedText)
        string.addAttribute(.foregroundColor, value: color, range: selectedElement.range)
        super.attributedText = string
    }
}

// MARK: - Interactive elements

extension InteractiveLabel {
    private func clearInteractiveElements() {
        selectedElement = nil
        interactiveElements.removeAll()
    }

    private func detectInteractiveElements(in string: NSAttributedString) {
        let string = string.string
        let range = NSRange(string.startIndex..<string.endIndex, in: string)

        for element in elements {
            guard let matches = regex(for: element.pattern)?.matches(in: string, range: range) else {
                continue
            }

            for match in matches {
                if let range = Range(match.range, in: string) {
                    interactiveElements.append(
                        InteractiveElement(range: match.range, data: element, text: String(string[range]))
                    )
                }
            }
        }
    }

    private func regex(for pattern: String) -> NSRegularExpression? {
        if let regex = cachedRegexes[pattern] {
            return regex
        } else if let regex = try? NSRegularExpression(pattern: pattern) {
            cachedRegexes[pattern] = regex
            return regex
        }
        return nil
    }
}

// MARK: - Element

extension InteractiveLabel {
    /// Объект, описывающий интерактивный элемент в текстовом поле
    public struct Element {
        let pattern: String
        let configuration: Configuration
        let handler: (String) -> Void

        // MARK: Initialization

        /// Создаёт объект, описывающий интерактивный элемент в текстовом поле
        /// - Parameters:
        ///   - pattern: Шаблон, которому должен соответствовать интерактивный элемент.
        ///   Поддерживаются регулярные выражения
        ///   - configuration: Конфигурация интерактивного элемента
        ///   - handler: Замыкание вызывается, когда пользователь нажал на интерактивный элемент.
        ///   Получает текст из поля, который соответствует элементу
        public init(pattern: String, configuration: Configuration, handler: @escaping (String) -> Void) {
            self.pattern = pattern
            self.configuration = configuration
            self.handler = handler
        }
    }

    private struct InteractiveElement: Equatable {
        let range: NSRange
        let data: Element
        let text: String

        static func == (lhs: InteractiveElement, rhs: InteractiveElement) -> Bool {
            lhs.range == rhs.range
        }
    }
}

extension InteractiveLabel.Element {
    /// Конфигурация интерактивного элемента
    public struct Configuration {
        let textStyle: TextStyle?
        let textColor: UIColor?
        let highlightedTextColor: UIColor?

        // MARK: Initialization

        /// Создаёт конфигурацию интерактивного элемента
        /// - Parameters:
        ///   - textStyle: Стиль текста, который должен быть использован для интерактивного элемента.
        ///   Если `nil`, то будет использоваться стиль от текстового поля
        ///   - textColor: Цвет текста, который должен быть использован для интерактивного элемента.
        ///   Если `nil`, то будет использоваться цвет от текстового поля
        ///   - highlightedTextColor: Цвет текста, который должен быть использован для интерактивного элемента,
        ///   когда он выделен
        public init(textStyle: TextStyle? = nil, textColor: UIColor? = nil, highlightedTextColor: UIColor? = nil) {
            self.textStyle = textStyle
            self.textColor = textColor
            self.highlightedTextColor = highlightedTextColor ?? textColor?.withAlphaComponent(0.45)
        }
    }
}

extension InteractiveLabel.Element.Configuration {
    /// Конфигурация для интерактивного элемента в виде ссылки
    public static var link: Self {
        Self(textStyle: .btnLink, textColor: UIColor.blue)
    }
    public static var editLink: Self {
        Self(textStyle: .subheader, textColor: UIColor.gray)
    }
}

// swiftlint:enable attributed_string


import Foundation
import UniformTypeIdentifiers

extension URL {
    /// Создаёт ссылку на локальный файл
    /// - Parameter file: Путь к файлу в локальном хранилище
    public init(file: String) {
        if #available(iOS 16, *) {
            self.init(filePath: file)
        } else {
            self.init(fileURLWithPath: file)
        }
    }

    /// Возвращает ссылку с добавленным компонентом пути
    /// - Parameter path: Компонент пути
    public func appendingPath(_ path: String) -> URL {
        if #available(iOS 16, *) {
            return appending(path: path)
        } else {
            return appendingPathComponent(path)
        }
    }

    /// Компонент пути в ссылке
    public func getPath() -> String {
        if #available(iOS 16, *) {
            return path()
        } else {
            return path
        }
    }

    /// MIME-тип
    public var mimeType: String {
        UTType(filenameExtension: pathExtension)?.preferredMIMEType ?? "application/octet-stream"
    }

    /// Добавляет к ссылке параметры `pet_content_only` и `from=app_iOS`
    public var contentOnly: URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        var queryItems = components.percentEncodedQueryItems ?? []
        let hasContentOnly = queryItems.contains { $0.name == "pet_content_only" }
        let hasFrom = queryItems.contains { $0.name == "from" }
        if hasContentOnly, hasFrom {
            return self
        }

        if !hasContentOnly {
            queryItems.append(URLQueryItem(name: "pet_content_only", value: "1"))
        }
        if !hasFrom {
            queryItems.append(URLQueryItem(name: "from", value: "app_iOS"))
        }
        components.percentEncodedQueryItems = queryItems
        return components.url ?? self
    }
}

import UIKit

/// Протокол описывает элемент управления, который поддерживает выполнение основного действия
public protocol PrimaryActionControl {
    /// Основное действие, которое позволяет выполнить элемент управления
    var primaryAction: UIControl.Event { get }

    /// Добавляет действие, связанное с элементом
    /// - Parameter handler: Замыкание вызывается, когда выполняется основное действие элемента управления
    func addAction(_ handler: @escaping () -> Void)
}

extension PrimaryActionControl where Self: UIControl {
    public func addAction(_ handler: @escaping () -> Void) {
        let action = UIAction { _ in handler() }
        addAction(action, for: primaryAction)
    }

    /// Добавляет действие, связанное с элементом
    /// - Parameter handler: Замыкание принимает элемент управления и вызывается, когда он выполняет основное действие
    public func addAction(_ handler: @escaping (Self) -> Void) {
        let action = UIAction { action in
            if let sender = action.sender as? Self {
                handler(sender)
            }
        }
        addAction(action, for: primaryAction)
    }
}


import UIKit

extension NSLayoutConstraint {
    /// Устанавливает приоритет констрейнта
    /// - Parameter priority: Приоритет констрейнта
    /// - Returns: Констрейнт с новым приоритетом
    public func priority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }

    /// Устанавливает приоритет констрейнта
    /// - Parameter priority: Приоритет констрейнта
    /// - Returns: Констрейнт с новым приоритетом
    public func priority(_ priority: Float) -> Self {
        self.priority = UILayoutPriority(priority)
        return self
    }
}

import Kingfisher

/// Представление, которое используется для отображения вместо изображения
public final class PlaceholderView: UIView, Placeholder {
    // MARK: Initialization

    /// Создаёт заглушку для отображения вместо изображения
    /// - Parameters:
    ///   - fill: Нужно ли заполнять фон заглушки цветом
    ///   - color: Цвет, которым нужно заполнить фон заглушки
    ///   - image: Изображение, которое должно отображаться заглушкой
    public init(
        fill: Bool,
        color: UIColor = UIColor.gray,
        image: UIImage = UIImage()
    ) {
        super.init(frame: .zero)
        configure(fill: fill, color: color, image: image)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Configuration

    private func configure(fill: Bool, color: UIColor, image: UIImage) {
        if fill {
            backgroundColor = color
        }
        addSubview(
            ImageView(frame: bounds).ui.image(image).autoresizingMask([.flexibleWidth, .flexibleHeight]).make()
        )
    }
}

import UIKit

@objc
private class CGSVGDocument: NSObject {}

final class SVGImageCoder {
    private typealias ImageWithCGSVGDocumentType = @convention(c) (AnyObject, Selector, CGSVGDocument?) -> UIImage
    private typealias CGSVGDocumentType = @convention(c) (AnyObject, Selector) -> Unmanaged<CGSVGDocument>?

    static let shared = SVGImageCoder()

    private let cgSVGDocumentRelease: @convention(c) (CGSVGDocument?) -> Void
    private let cgSVGDocumentCreateFromData: @convention(c) (CFData?, CFDictionary?) -> Unmanaged<CGSVGDocument>?
    private let cgSVGDocumentWriteToData: @convention(c) (CGSVGDocument?, CFData?, CFDictionary?) -> Void
    private let cgContextDrawSVGDocument: @convention(c) (CGContext?, CGSVGDocument?) -> Void
    private let cgSVGDocumentGetCanvasSize: @convention(c) (CGSVGDocument?) -> CGSize
    private let imageWithCGSVGDocumentSEL = NSSelectorFromString("X2ltYWdlV2l0aENHU1ZHRG9jdW1lbnQ6".base64Decoded)
    private let cgSVGDocumentSEL = NSSelectorFromString("X0NHU1ZHRG9jdW1lbnQ=".base64Decoded)

    // MARK: Initialization

    private init() {
        let rtldDefault = UnsafeMutableRawPointer(bitPattern: -2)

        func loadFunc<T>(_ name: String) -> T {
            unsafeBitCast(dlsym(rtldDefault, name.base64Decoded), to: T.self)
        }

        cgSVGDocumentRelease = loadFunc("Q0dTVkdEb2N1bWVudFJlbGVhc2U=")
        cgSVGDocumentCreateFromData = loadFunc("Q0dTVkdEb2N1bWVudENyZWF0ZUZyb21EYXRh")
        cgSVGDocumentWriteToData = loadFunc("Q0dTVkdEb2N1bWVudFdyaXRlVG9EYXRh")
        cgContextDrawSVGDocument = loadFunc("Q0dDb250ZXh0RHJhd1NWR0RvY3VtZW50")
        cgSVGDocumentGetCanvasSize = loadFunc("Q0dTVkdEb2N1bWVudEdldENhbnZhc1NpemU=")
    }

    // MARK: Internal

    func image(with data: Data) -> UIImage? {
        guard
            data.isNotEmpty,
            let document = cgSVGDocumentCreateFromData(data as CFData, nil)?.takeUnretainedValue()
        else {
            return nil
        }

        let method = UIImage.method(for: imageWithCGSVGDocumentSEL)
        let imageWithCGSVGDocument = unsafeBitCast(method, to: ImageWithCGSVGDocumentType.self)
        let image = imageWithCGSVGDocument(UIImage.self, imageWithCGSVGDocumentSEL, document)
        cgSVGDocumentRelease(document)
        return image
    }

    func bitmapImage(with data: Data, targetSize: CGSize) -> UIImage? {
        guard
            data.isNotEmpty,
            let document = cgSVGDocumentCreateFromData(data as CFData, nil)?.takeUnretainedValue()
        else {
            return nil
        }
        defer {
            cgSVGDocumentRelease(document)
        }

        let size = cgSVGDocumentGetCanvasSize(document)
        guard size.width > 0 && size.height > 0 else {
            return nil
        }

        var targetSize = targetSize
        let scale: (x: CGFloat, y: CGFloat)
        if targetSize == .zero {
            targetSize = size
            scale = (1, 1)
        } else {
            let ratio = (x: targetSize.width / size.width, y: targetSize.height / size.height)
            if targetSize.width.isZeroValue {
                scale = (ratio.y, ratio.y)
                targetSize.width = size.width * scale.x
            } else if targetSize.height.isZeroValue {
                scale = (ratio.x, ratio.x)
                targetSize.height = size.height * scale.y
            } else {
                let min = min(ratio.x, ratio.y)
                scale = (min, min)
                targetSize = CGSize(width: size.width * scale.x, height: size.height * scale.y)
            }
        }

        let scaleTransform = CGAffineTransform(scaleX: scale.x, y: scale.y)
        let translationTransform = CGAffineTransform(
            translationX: (targetSize.width / scale.x - size.width) / 2,
            y: (targetSize.height / scale.y - size.height) / 2
        )

        return UIGraphicsImageRenderer(size: targetSize).image {
            $0.cgContext.translateBy(x: 0, y: targetSize.height)
            $0.cgContext.scaleBy(x: 1, y: -1)
            $0.cgContext.concatenate(scaleTransform)
            $0.cgContext.concatenate(translationTransform)
            cgContextDrawSVGDocument($0.cgContext, document)
        }
    }

    func data(of image: UIImage) -> Data? {
        let cgSVGDocument = unsafeBitCast(image.method(for: cgSVGDocumentSEL), to: CGSVGDocumentType.self)
        guard let document = cgSVGDocument(image, cgSVGDocumentSEL)?.takeUnretainedValue() else {
            return nil
        }

        var data = NSMutableData()
        cgSVGDocumentWriteToData(document, data as CFData, nil)
        return data as Data
    }
}

extension String {
    var base64Decoded: String {
        Data(base64Encoded: self, options: .ignoreUnknownCharacters).flatMap { String(data: $0, encoding: .utf8) } ?? ""
    }
}

import UIKit

import UIKit

final class ThumbView: UIView {
    private let shadowView = ShadowView(style: .control)
    private lazy var label = Label().ui
        .textStyle(.textBody.monospacedDigit)
        .textColor(UIColor.gray)
        .make()

    // MARK: Properties

    var isHighlighted = false {
        didSet {
            shadowView.transform3D = isHighlighted ? CATransform3DMakeScale(0.95, 0.95, 0.95) : CATransform3DIdentity
        }
    }

    var text: String? {
        didSet {
            label.text = text
            label.isHidden = text?.isEmpty ?? false
            if label.superview == nil {
                addSubview(label)
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        Constants.size
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

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        Constants.size
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let size = Constants.size
        let origin = CGPoint(x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2)
        shadowView.frame = CGRect(origin: origin, size: size)

        guard text?.isNotEmpty ?? false else {
            return
        }

        let textSize = label.sizeThatFits(bounds.size)
        let textOrigin = CGPoint(x: (bounds.width - textSize.width) / 2, y: bounds.maxY + 4)
        label.frame = CGRect(origin: textOrigin, size: textSize)
    }

    // MARK: Configuration

    private func configure() {
        let view = UIView().ui
            .backgroundColor(UIColor.lightGray)
            .cornerRadius(Constants.size.height / 2)
            .make()
        shadowView.addSubview(view)
        addSubview(shadowView)
    }

    // MARK: Private

    private enum Constants {
        static let size = CGSize(width: 24, height: 24)
    }
}



import Foundation

extension Collection {
    /// Логическое значение, показывающее, что коллекция не пустая
    public var isNotEmpty: Bool {
        !isEmpty
    }
}


/// Ползунок для выбора значений
public final class Slider: UIControl {
    private let trackLayer = CAShapeLayer().ui.lineCap(.round).lineWidth(2).cornerRadius(1).make()
    private lazy var lowerThumbView = ThumbView()
    private let upperThumbView = ThumbView()

    // MARK: Properties

    /// Минимальное значение ползунка
    ///
    /// Значение по умолчанию 0
    public var minimumValue: CGFloat = 0 {
        didSet {
            guard minimumValue.isNotEqualTo(value: oldValue) else {
                return
            }

            if maximumValue.isLessThan(value: minimumValue) {
                maximumValue = minimumValue
            }
            if value.lower.isLessThan(value: minimumValue) {
                value = Value(lower: minimumValue, upper: value.upper)
            }
            setNeedsLayout()
        }
    }

    /// Максимальное значение ползунка
    ///
    /// Значение по умолчанию 100
    public var maximumValue: CGFloat = 100 {
        didSet {
            guard maximumValue.isNotEqualTo(value: oldValue) else {
                return
            }

            if minimumValue.isGreaterThan(value: maximumValue) {
                minimumValue = maximumValue
            }
            if value.upper.isGreaterThan(value: maximumValue) {
                value = Value(lower: value.lower, upper: maximumValue)
            }
            setNeedsLayout()
        }
    }

    /// Текущее значение ползунка
    ///
    /// Если ползунку задан стиль `.single`, то текущее значение хранится в `Value.upper`
    public var value: Value {
        didSet {
            let range = minimumValue...maximumValue
            if !range.contains(value.lower) || !range.contains(value.upper) {
                value = Value(
                    lower: max(min(value.lower, maximumValue), minimumValue),
                    upper: max(min(value.upper, maximumValue), minimumValue)
                )
            }
            updateText()
            setNeedsLayout()
        }
    }

    /// Замыкание, используемое для отображения подписей под выбранными значениями
    ///
    /// Принимает числовое значение и преобразует его в строковое. `nil` скрывает подписи
    public var valueTransformer: ((CGFloat) -> String)? {
        didSet {
            updateText()
            setNeedsLayout()
        }
    }

    /// Значение, указывающее, генерируется ли событие `.valueChanged` при каждом перемещении ползунка
    ///
    /// Если `true`, ползунок генерирует событие `.valueChanged` при каждом перемещении ползунка.
    /// Если `false`, то событие генерируется только один раз,
    /// когда пользователь заканчивает взаимодействие с ползунком, чтобы установить конечное значение.
    ///
    /// Значение по умолчанию `true`
    public var isContinuous = true

    /// Цветовая схема ползунка
    ///
    /// Значение по умолчанию `.yellow`
    public var color: Color = .yellow {
        didSet {
            updateColors()
        }
    }

    private let style: Style
    private var trackWidth: CGFloat = 0
    private var trackingValue: TrackingValue? {
        didSet {
            oldValue?.thumbView.isHighlighted = false
            trackingValue?.thumbView.isHighlighted = true
        }
    }
    private var speeds: [Speed] = [
        Constants.speed,
        Speed(value: 0.5, distance: 50),
        Speed(value: 0.25, distance: 100),
        Speed(value: 0.1, distance: 150),
        Speed(value: 0.01, distance: 200)
    ]

    private var boundsInsets: UIEdgeInsets {
        valueTransformer != nil ? UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0) : .zero
    }

    override public var intrinsicContentSize: CGSize {
        let height = upperThumbView.intrinsicContentSize.height + boundsInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    // MARK: Initialization

    /// Создаём ползунок
    /// - Parameter style: Стиль ползунка
    public init(style: Style) {
        self.style = style
        switch style {
        case .single:
            value = Value(lower: minimumValue, upper: minimumValue)
        case .range:
            value = Value(lower: minimumValue, upper: maximumValue)
        }

        super.init(frame: .zero)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColors()
        }
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if upperThumbView.frame.inset(by: Constants.thumbInset).contains(point) {
            return true
        }
        switch style {
        case .single:
            break
        case .range:
            if lowerThumbView.frame.inset(by: Constants.thumbInset).contains(point) {
                return true
            }
        }
        return super.point(inside: point, with: event)
    }

    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard
            gestureRecognizer is UITapGestureRecognizer,
            let view = gestureRecognizer.view,
            isDescendant(of: view)
        else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        return false
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let bounds = bounds.inset(by: boundsInsets)

        upperThumbView.frame = rect(for: upperThumbView, bounds: bounds, value: value.upper)
        switch style {
        case .single:
            trackWidth = bounds.width - upperThumbView.frame.width
        case .range:
            lowerThumbView.frame = rect(for: lowerThumbView, bounds: bounds, value: value.lower)
            trackWidth = bounds.width - lowerThumbView.frame.width - upperThumbView.frame.width
        }
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let bounds = layer.bounds.inset(by: boundsInsets)

        trackLayer.frame = CGRect(x: 1, y: (bounds.height - 2) / 2, width: bounds.width - 2, height: 2)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 1))
        path.addLine(to: CGPoint(x: trackLayer.bounds.width, y: 1))
        trackLayer.path = path.cgPath

        switch style {
        case .single:
            break
        case .range:
            trackLayer.strokeStart = lowerThumbView.center.x / bounds.width
        }
        trackLayer.strokeEnd = upperThumbView.center.x / bounds.width

        CATransaction.commit()
    }

    // MARK: Configuration

    private func configure() {
        layer.addSublayer(trackLayer)
        switch style {
        case .single:
            break
        case .range:
            addSubview(lowerThumbView)
        }
        addSubview(upperThumbView)

        updateColors()
    }

    private func updateColors() {
        trackLayer.backgroundColor = color.trackColor.cgColor
        trackLayer.strokeColor = color.trackTintColor.cgColor
    }

    // MARK: Tracking

    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        switch style {
        case .single:
            if distanceTo(upperThumbView, from: location) != nil {
                trackingValue = TrackingValue(value, thumbView: upperThumbView, isUpper: true)
            }
        case .range:
            switch (distanceTo(lowerThumbView, from: location), distanceTo(upperThumbView, from: location)) {
            case (.none, .none):
                trackingValue = nil
            case (.some, .none):
                trackingValue = TrackingValue(value, thumbView: lowerThumbView, isUpper: false)
            case (.none, .some):
                trackingValue = TrackingValue(value, thumbView: upperThumbView, isUpper: true)
            case let (lower?, upper?):
                if lower.isLessThan(value: upper) {
                    trackingValue = TrackingValue(value, thumbView: lowerThumbView, isUpper: false)
                } else {
                    trackingValue = TrackingValue(value, thumbView: upperThumbView, isUpper: true)
                }
            }
        }

        return trackingValue != nil
    }

    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard var trackingValue else {
            return false
        }

        let location = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        let center = trackingValue.thumbView.frame.midY

        let previousValue = trackingValue.isUpper ? value.upper : value.lower
        let valueAdjustment = valueAdjustment(for: location, relativeTo: previousLocation)
        let speed = speed(for: location, relativeTo: center)
        let speedAdjustment = speed.value * valueAdjustment
        let thumbAdjustment = thumbAdjustment(
            for: location,
            relativeTo: previousLocation,
            center: center,
            unadjustedValue: trackingValue.unadjusted,
            value: previousValue
        )

        trackingValue.unadjusted += valueAdjustment
        self.trackingValue = trackingValue

        let currentValue = value
        let adjustment = speedAdjustment + thumbAdjustment
        let isNormalSpeed = speed.value.isEqualTo(value: 1)
        if trackingValue.isUpper {
            // Если ползунок перемещается без замедления, а палец находится левее нижнего значения,
            // но перемещается вправо, то игнорируем это изменение, чтобы положение пальца и ползунка не отличались
            let ignore = isNormalSpeed
                && trackingValue.unadjusted.isLessThan(value: value.lower)
                && adjustment.isGreaterThan(value: 0)
            if !ignore {
                let newValue = max(min(previousValue + adjustment, maximumValue), value.lower)
                value = Value(lower: value.lower, upper: newValue)
            }
        } else {
            // Если ползунок перемещается без замедления, а палец находится правее верхнего значения,
            // но перемещается влево, то игнорируем это изменение, чтобы положение пальца и ползунка не отличались
            let ignore = isNormalSpeed
                && trackingValue.unadjusted.isGreaterThan(value: value.upper)
                && adjustment.isLessThan(value: 0)
            if !ignore {
                let newValue = max(min(previousValue + adjustment, value.upper), minimumValue)
                value = Value(lower: newValue, upper: value.upper)
            }
        }

        if isContinuous, value != currentValue {
            sendActions(for: .valueChanged)
        }

        return true
    }

    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        guard let trackingValue else {
            return
        }

        if isContinuous || value != trackingValue.initial {
            sendActions(for: .valueChanged)
        }
        self.trackingValue = nil
    }

    override public func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        guard let trackingValue else {
            return
        }

        if value != trackingValue.initial {
            value = trackingValue.initial
            if isContinuous {
                sendActions(for: .valueChanged)
            }
        }
        self.trackingValue = nil
    }
}

extension Slider {
    /// Цветовая схема ползунка
    public struct Color {
        let trackColor: UIColor
        let trackTintColor: UIColor

        // MARK: Initialization

        /// Создаёт цветовую схему ползунка
        /// - Parameters:
        ///   - trackColor: Цвет трека
        ///   - trackTintColor: Цвет выбранной части трека
        public init(trackColor: UIColor, trackTintColor: UIColor) {
            self.trackColor = trackColor
            self.trackTintColor = trackTintColor
        }
    }
}

// MARK: - Default colors

extension Slider.Color {
    /// Ползунок с жёлтым треком
    public static var yellow: Self {
        Slider.Color(
            trackColor: UIColor.black,
            trackTintColor: UIColor.yellow
        )
    }

    /// Ползунок с оранжевым треком
    public static var orange: Self {
        Slider.Color(
            trackColor: UIColor.white,
            trackTintColor: UIColor.orange
        )
    }
}


// MARK: - Private

extension Slider {
    private enum Constants {
        static let thumbInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        static let speed = Speed(value: 1, distance: 0)
    }

    private func updateText() {
        guard let valueTransformer else {
            return
        }

        upperThumbView.text = valueTransformer(value.upper)
        switch style {
        case .single:
            break
        case .range:
            lowerThumbView.text = valueTransformer(value.lower)
        }
    }

    private func rect(for thumbView: ThumbView, bounds: CGRect, value: CGFloat) -> CGRect {
        let upperSize = upperThumbView.sizeThatFits(bounds.size)
        switch style {
        case .single:
            let width = bounds.width - upperSize.width
            return rect(forBounds: bounds, trackWidth: width, thumbSize: upperSize, value: value, inset: 0)
        case .range:
            let lowerSize = lowerThumbView.sizeThatFits(bounds.size)
            let width = bounds.width - lowerSize.width - upperSize.width
            if thumbView === upperThumbView {
                let inset = (lowerSize.width + upperSize.width) / 2
                return rect(forBounds: bounds, trackWidth: width, thumbSize: upperSize, value: value, inset: inset)
            } else {
                return rect(forBounds: bounds, trackWidth: width, thumbSize: lowerSize, value: value, inset: 0)
            }
        }
    }

    private func rect(
        forBounds bounds: CGRect,
        trackWidth width: CGFloat,
        thumbSize: CGSize,
        value: CGFloat,
        inset: CGFloat
    ) -> CGRect {
        let diff = maximumValue - minimumValue
        let offset = (diff.isGreaterThan(value: 0) ? width / diff * (value - minimumValue) : 0) + inset
        let origin = CGPoint(x: offset, y: (bounds.height - thumbSize.height) / 2)
        return CGRect(origin: origin, size: thumbSize)
    }

    private func distanceTo(_ view: UIView, from location: CGPoint) -> CGFloat? {
        view.frame.inset(by: Constants.thumbInset).contains(location) ? abs(location.x - view.frame.midX) : nil
    }

    private func speed(for location: CGPoint, relativeTo center: CGFloat) -> Speed {
        let verticalDistance = abs(location.y - center)
        return speeds.last { $0.distance.isLessThanOrEqualTo(value: verticalDistance) } ?? Constants.speed
    }

    private func valueAdjustment(for location: CGPoint, relativeTo previousLocation: CGPoint) -> CGFloat {
        let distance = location.x - previousLocation.x
        let relativeDistance = distance / trackWidth
        let range = maximumValue - minimumValue
        return relativeDistance * range
    }

    private func thumbAdjustment(
        for location: CGPoint,
        relativeTo previousLocation: CGPoint,
        center: CGFloat,
        unadjustedValue: CGFloat,
        value: CGFloat
    ) -> CGFloat {
        // палец перемещается к центру
        let fromDown = center.isLessThan(value: location.y) && location.y.isLessThan(value: previousLocation.y)
        let fromUp = center.isGreaterThan(value: location.y) && location.y.isGreaterThan(value: previousLocation.y)
        guard fromDown || fromUp else {
            return 0
        }

        let distance = abs(location.y - center)
        let valueDistance = unadjustedValue - value
        return valueDistance / (1 + distance)
    }
}

// MARK: - Types

extension Slider {
    /// Стиль ползунка
    public enum Style {
        /// Ползунок для выбора одиночного значения
        case single
        /// Ползунок для выбора диапазона значений
        case range
    }

    /// Текущее значение ползунка
    public struct Value: Hashable {
        /// Минимальное значение
        public let lower: CGFloat
        /// Максимальное значение
        public let upper: CGFloat

        // MARK: Initialization

        /// Создаёт диапазон значений для ползунка
        /// - Parameters:
        ///   - lower: Минимальное значение
        ///   - upper: Максимальное значение
        public init(lower: CGFloat, upper: CGFloat) {
            self.lower = lower
            self.upper = upper
        }

        /// Создаёт значение для ползунка
        /// - Parameter value: Значение для ползунка
        public init(value: CGFloat) {
            lower = 0
            upper = value
        }

        // MARK: Equatable

        public static func == (lhs: Value, rhs: Value) -> Bool {
            lhs.lower.isEqualTo(value: rhs.lower) && lhs.upper.isEqualTo(value: rhs.upper)
        }
    }

    private struct Speed {
        let value: CGFloat
        let distance: CGFloat
    }

    private struct TrackingValue {
        let initial: Value
        var unadjusted: CGFloat
        let thumbView: ThumbView
        let isUpper: Bool

        // MARK: Initialization

        init(_ value: Value, thumbView: ThumbView, isUpper: Bool) {
            initial = value
            unadjusted = isUpper ? value.upper : value.lower
            self.thumbView = thumbView
            self.isUpper = isUpper
        }
    }
}
//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

/// Протокол, который должен реализовывать дополнительный элемент
public protocol SupplementaryView: UICollectionReusableView {
    /// Тип модели данных, которая используется дополнительным элементом
    associatedtype Model: SupplementaryModel

    /// Метод для обновления данных
    /// - Parameter model: Данные,с помощью которых нужно выполнить обновление
    func update(with model: Model)
}


/// Протокол, описывающий модель данных для дополнительного элемента
public protocol SupplementaryModel: AnyObject where View.Model == Self {
    /// Тип дополнительного элемента, который использует модель
    associatedtype View: SupplementaryView

    /// Замыкание, которое используется для обновления элемента
    typealias UpdateDataHandler = (String) -> Void

    /// Тип дополнительного элемента
    static var elementKind: String { get }

    /// Отличительные черты дополнительного элемента. Используются для определения, что контент в элементе изменился
    var traits: Set<AnyHashable> { get }
    /// Логическое значение, показывающее, что в дополнительном элементе есть элементы управления,
    /// которые взаимодействуют с моделью
    ///
    /// Значение по умолчанию `false`
    /// - Important: Если элемент сохраняет ссылку на модель, то это свойство должно возвращать `true`
    var hasActions: Bool { get }

    /// Используется для обновления элемента. Не вызывайте его напрямую, используйте метод `setNeedsUpdateData`
    ///
    /// Замыкание устанавливает `CollectionManager`
    /// - Note: Не поддерживается для `Decoration view`
    var updateDataHandler: UpdateDataHandler? { get set }
}

// MARK: - Internal

extension SupplementaryModel {
    func hasDifference(comparedTo other: some SupplementaryModel) -> Bool {
        other.updateDataHandler != nil || traits != other.traits || other.hasActions
    }
}

// MARK: - Default implementation

extension SupplementaryModel {
    public static var elementKind: String {
        String(describing: Self.self)
    }

    public var traits: Set<AnyHashable> {
        []
    }

    public var hasActions: Bool {
        false
    }

    public var updateDataHandler: UpdateDataHandler? {
        get { nil }
        set {} // swiftlint:disable:this unused_setter_value
    }

    /// Метод инициирует обновление элемента
    ///
    /// Если размер элемента зависит от контента, то происходит его пересчёт. Когда элемент не отображается,
    /// то он обновится при следующем появлении
    /// - Note: Не поддерживается для `Decoration view`
    /// - Important: Метод должен применяться только в ситуациях, когда обновление данных происходит внутри модели.
    /// Если изменения производятся в контроллере, то используйте методы `updateAllSupplementaries()`
    /// или `updateSupplementary(_:)` слепка секции
    public func setNeedsUpdateData() {
        updateDataHandler?(elementKind)
    }
}

// MARK: - Internal

extension SupplementaryModel {
    var elementKind: String {
        Self.elementKind
    }
}

public protocol ExpressibleByArrayLiteral {

    /// The type of the elements of an array literal.
    associatedtype ArrayLiteralElement

    /// Creates an instance initialized with the given elements.
    init(arrayLiteral elements: Self.ArrayLiteralElement...)
}
import Foundation

/// Набор моделей дополнительных элементов коллекции.
/// Может быть у коллекции, секции или ячейки
public struct Supplementaries: ExpressibleByArrayLiteral {
    private var models: [String: any SupplementaryModel]

    // MARK: Initialization

    /// Создаёт набор моделей дополнительных элементов из заданного списка
    /// - Parameter models: Список моделей дополнительных элементов
    public init(_ models: [any SupplementaryModel]) {
        self.models = Dictionary(uniqueKeysWithValues: models.map { ($0.elementKind, $0) })
    }

    public init(arrayLiteral elements: (any SupplementaryModel)...) {
        self.init(elements)
    }

    // MARK: Public

    /// Добавляет в набор модель дополнительного элемента
    /// - Parameter model: Модель дополнительного элемента
    public mutating func append<Model: SupplementaryModel>(_ model: Model) {
        models[model.elementKind] = model
    }

    // MARK: Internal

    var isEmpty: Bool {
        models.isEmpty
    }

    func callAsFunction() -> Dictionary<String, any SupplementaryModel>.Values {
        models.values
    }

    func callAsFunction(ofKind elementKind: String) -> (any SupplementaryModel)? {
        models[elementKind]
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Режим выбора ячейки
public enum SelectionMode {
    /// Запрещён выбор ячеек
    case none
    /// Разрешён выбор только одной ячейки
    case single
    /// Поддерживается одновременный выбор нескольких ячеек
    case multi
}


//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

/// Псевдоним для `UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider`
public typealias SwipeActionsProvider = UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider

/// Протокол, описывающий модель для секции
public protocol SectionModel: AnyObject {
    /// Тип идентификатора секции
    associatedtype ID: Hashable

    /// Уникальный идентификатор секции
    var id: ID { get }
    /// Модели всех дополнительных элементов, которые должны отображаться вместе с ячейками или секцией.
    ///
    /// Если в моделях секции и ячейки имеются одинаковые типы, то предпочтение отдаётся ячейке
    var supplementaries: Supplementaries { get }
    /// Модели фоновых элементов секции
    var decorations: Supplementaries { get }

    /// Режим выбора ячеек в секции. По умолчаннию используется `none`
    /// Игнорируется, если выбором ячеек управляет коллекция, а не секция
    var selectionMode: SelectionMode { get }

    /// Заголовок секции, используемый для быстрого перемещения между секциями
    var indexTitle: String? { get }

    /// Обработчик пагинации
    ///
    /// Управляет показом индикатора загрузки, состоянием ошибки и запросом следующей порции данных.
    /// По умолчанию секция не поддерживает пагинацию
//    var pagination: PaginationHandler? { get }

    /// Используется для конфигурации действий с помощью свайпа от левой границы ячеек.
    /// Сами действия настраиваются в соответствующей ячейке
    ///
    /// Замыкание устанавливает `CollectionManager`
    var leadingSwipeActionsProvider: SwipeActionsProvider? { get set }
    /// Используется для конфигурации действий с помощью свайпа от правой границы ячеек.
    /// Сами действия настраиваются в соответствующей ячейке
    ///
    /// Замыкание устанавливает `CollectionManager`
    var trailingSwipeActionsProvider: SwipeActionsProvider? { get set }

    /// Определяет расположение элементов внутри секции.
    /// Используется, если у `CollectionManager` для свойства `layout` установлено значение `compositional`
    /// - Parameter environment: Информация об окружении. Например, размер контейнера
    /// - Returns: Конфигурация вёрстки секции
    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
}

// MARK: - Internal

extension SectionModel {
    func updatedSupplementaries(comparedTo other: some SectionModel) -> [String] {
        if supplementaries.isEmpty || other.supplementaries.isEmpty {
            return []
        }
        return supplementaries().compactMap { newSupplementary -> String? in
            guard let oldSupplementary = other.supplementaries(ofKind: newSupplementary.elementKind) else {
                return nil
            }
            return newSupplementary.hasDifference(comparedTo: oldSupplementary) ? newSupplementary.elementKind : nil
        }
    }
}

// MARK: - Default implementation

extension SectionModel {
    public var supplementaries: Supplementaries {
        Supplementaries([])
    }

    public var decorations: Supplementaries {
        Supplementaries([])
    }

    public var selectionMode: SelectionMode {
        .none
    }

    public var indexTitle: String? {
        nil
    }

//    public var pagination: PaginationHandler? {
//        nil
//    }

    public var leadingSwipeActionsProvider: SwipeActionsProvider? {
        get { nil }
        set {} // swiftlint:disable:this unused_setter_value
    }

    public var trailingSwipeActionsProvider: SwipeActionsProvider? {
        get { nil }
        set {} // swiftlint:disable:this unused_setter_value
    }

    // swiftlint:disable:next unavailable_function
    public func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        fatalError("The \(Self.self) section doesn't support compositional layout")
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

/// Протокол, который должна реализовывать ячейка
public protocol CollectionCell: UICollectionViewCell {
    /// Тип модели данных, которая используется ячейкой
    associatedtype Model: ItemModel

    /// Метод для обновления данных в ячейке
    /// - Parameter model: Данные,с помощью которых нужно выполнить обновление
    func update(with model: Model)
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Объект элемента секции со стертым типом
public class AnyItem {
    let id: ItemID
    let anyModel: any ItemModel

    // MARK: Initialization

    init(id: ItemID, model: some ItemModel) {
        self.id = id
        anyModel = model
    }
}

// MARK: - Casting

extension AnyItem {
    /// Приводит модель элемента секции к конкретному типу, если она удовлетворяет заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей элемент секции
    ///   - predicate: Условие, которому должна удовлетворять модель элемента секции
    /// - Returns: Возвращает элемент секции с конкретным типом модели `Item<Model>`.
    /// Когда тип модели не соответствует параметру `type` или
    /// сама модель не удовлетворяет условию из параметра `predicate`, если он задан, то возвращает `nil`
    public func `as`<Model: ItemModel>(_ type: Model.Type, where predicate: ((Model) -> Bool)? = nil) -> Item<Model>? {
        guard let model = anyModel as? Model, predicate?(model) ?? true else {
            return nil
        }
        return Item(id: id, model: model)
    }

    /// Проверяет, что модель элемента секции является нужного типа и удовлетворяет заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей элемент секции
    ///   - predicate: Условие, которому должна удовлетворять модель элемента секции
    /// - Returns: Возвращает `true`, когда тип модели соответствует параметру `type` и
    /// сама модель удовлетворяет условию из параметра `predicate`, если он задан
    public func `is`<Model: ItemModel>(_ type: Model.Type, where predicate: ((Model) -> Bool)? = nil) -> Bool {
        guard let model = anyModel as? Model else {
            return false
        }
        return predicate?(model) ?? true
    }
}


import Foundation

/// Объект элемента секции с моделью конкретного типа
@dynamicMemberLookup
public final class Item<Model: ItemModel>: AnyItem {
    /// Модель, описывающая данный элемент секции
    public let model: Model

    // MARK: Initialization

    init(id: ItemID, model: Model) {
        self.model = model
        super.init(id: id, model: model)
    }

    // MARK: DynamicMemberLookup

    public subscript<Value>(dynamicMember keyPath: KeyPath<Model, Value>) -> Value {
        model[keyPath: keyPath]
    }

    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Model, Value>) -> Value {
        get {
            model[keyPath: keyPath]
        }
        set {
            model[keyPath: keyPath] = newValue
        }
    }
}


import UIKit

/// Протокол, описывающий модель данных для ячейки
public protocol ItemModel: AnyObject where Cell.Model == Self {
    /// Тип ячейки, который использует модель
    associatedtype Cell: CollectionCell
    /// Тип идентификатора ячейки
    associatedtype ID: Hashable

    /// Замыкание, которое используется для обновления ячейки
    typealias UpdateDataHandler = (Bool) -> Void

    /// Уникальный идентификатор ячейки в секции
    var id: ID { get }
    /// Отличительные черты ячейки. Используются для определения, что контент в ячейке изменился
    var traits: Set<AnyHashable> { get }
    /// Логическое значение, показывающее, что в ячейке есть элементы управления, которые взаимодействуют с моделью
    ///
    /// Значение по умолчанию `false`
    /// - Important: Если ячейка сохраняет ссылку на модель, то это свойство должно возвращать `true`
    var hasActions: Bool { get }

    /// Можно ли выбрать ячейку. Возвращает `true`, если свойство не определено
    var isSelectable: Bool { get }
    /// Сообщает, что ячейка выделена
    var didHighlight: ((Item<Self>) -> Void)? { get }
    /// Сообщает, что с ячейки сняли выделение
    var didUnhighlight: ((Item<Self>) -> Void)? { get }
    /// Действие, которые вызывается, когда пользователь выбирает ячейку
    var didSelect: ((Item<Self>) -> Void)? { get }
    /// Можно ли снять выбор с ячейки. Доступно только в режиме множественного выбора, в других игнорируется.
    /// Возвращает `true`, если свойство не определено
    var shouldDeselect: Bool { get }
    /// Действие, которое вызывается, когда пользователь снимает выбор с ячейки
    var didDeselect: ((Item<Self>) -> Void)? { get }
    /// Действие, которое вызывается, когда ячейка появится на экране
    var willDisplay: (() -> Void)? { get }
    /// Действие, которое вызывается, когда ячейка исчезла с экрана
    var didEndDisplaying: (() -> Void)? { get }

    /// Модели всех дополнительных элементов, которые должны отображаться вместе с ячейкой
    var supplementaries: Supplementaries { get }
    /// Используется для обновления ячейки. Не вызывайте его напрямую, используйте метод `setNeedsUpdateData(animated:)`
    ///
    /// Замыкание устанавливает `CollectionManager`
    var updateDataHandler: UpdateDataHandler? { get set }

    /// Конфигурация действий с помощью свайпа от левой границы ячейки
    var leadingSwipeActions: UISwipeActionsConfiguration? { get }
    /// Конфигурация действий с помощью свайпа от правой границы ячейки
    var trailingSwipeActions: UISwipeActionsConfiguration? { get }

    /// Вызывается, когда коллекция запрашивает предварительную загрузку для ячейки
    func prefetch()
    /// Вызывается, когда коллекция сообщает, что данные ячейки больше не нужны
    func cancelPrefetching()
}

// MARK: - Internal

extension ItemModel {
    func hasDifference(comparedTo other: some ItemModel) -> Bool {
        other.updateDataHandler != nil || traits != other.traits || other.hasActions
    }
}

// MARK: - Default implementation

extension ItemModel {
    public var traits: Set<AnyHashable> {
        []
    }

    public var hasActions: Bool {
        false
    }

    public var isSelectable: Bool {
        true
    }

    public var didHighlight: ((Item<Self>) -> Void)? {
        nil
    }

    public var didUnhighlight: ((Item<Self>) -> Void)? {
        nil
    }

    public var didSelect: ((Item<Self>) -> Void)? {
        nil
    }

    public var shouldDeselect: Bool {
        true
    }

    public var didDeselect: ((Item<Self>) -> Void)? {
        nil
    }

    public var willDisplay: (() -> Void)? {
        nil
    }

    public var didEndDisplaying: (() -> Void)? {
        nil
    }

    public var supplementaries: Supplementaries {
        Supplementaries([])
    }

    public var updateDataHandler: UpdateDataHandler? {
        get { nil }
        set {} // swiftlint:disable:this unused_setter_value
    }

    /// Метод инициирует обновление ячейки
    ///
    /// Если размер ячейки зависит от контента, то происходит его пересчёт. Когда ячейка не отображается,
    /// то она обновится при следующем появлении
    /// - Important: Метод должен применяться только в ситуациях, когда обновление данных происходит внутри модели.
    /// Если изменения производятся в контроллере,то используйте метод `update(items:)` слепка данных коллекции
    /// или секции
    /// - Parameter animated: `true`, если нужно выполнить обновление с анимацией
    public func setNeedsUpdateData(animated: Bool = true) {
        updateDataHandler?(animated)
    }

    // swiftlint:disable:next empty_method
    public func prefetch() {}

    // swiftlint:disable:next empty_method
    public func cancelPrefetching() {}

    public var leadingSwipeActions: UISwipeActionsConfiguration? {
        nil
    }

    public var trailingSwipeActions: UISwipeActionsConfiguration? {
        nil
    }
}

// MARK: - Internal

extension ItemModel {
    var hasDidSelect: Bool {
        didSelect != nil
    }

    func highlight(id: ItemID) {
        didHighlight?(Item(id: id, model: self))
    }

    func unhighlight(id: ItemID) {
        didUnhighlight?(Item(id: id, model: self))
    }

    func select(id: ItemID) {
        didSelect?(Item(id: id, model: self))
    }

    func deselect(id: ItemID) {
        didDeselect?(Item(id: id, model: self))
    }
}


//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

struct SectionID: Hashable {
    private let value: AnyHashable

    // MARK: Initialization

    init(_ model: any SectionModel) {
        value = AnyHashable(model.id)
    }

    init<ID: Hashable>(_ id: ID) {
        value = AnyHashable(id)
    }
}

// MARK: -

struct ItemID: Hashable {
    private let value: AnyHashable
    let sectionID: SectionID

    // MARK: Initialization

    init(_ item: some ItemModel, inSection sectionID: SectionID) {
        self.init(item.id, inSection: sectionID)
    }

    init<ID: Hashable>(_ itemID: ID, inSection sectionID: SectionID) {
        value = AnyHashable(itemID)
        self.sectionID = sectionID
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class DiffableDataSource: UICollectionViewDiffableDataSource<SectionID, ItemID> {
    typealias IndexTitleProvider = (_ collectionView: UICollectionView, _ section: SectionID) -> String?

    var indexTitleProvider: IndexTitleProvider?
    var indexTitles: [SectionID]?

    override func indexTitles(for collectionView: UICollectionView) -> [String]? {
        guard let indexTitleProvider else {
            indexTitles = nil
            return nil
        }

        var titles = [String]()
        var sections = [SectionID]()

        (0..<numberOfSections(in: collectionView))
            .compactMap { sectionIdentifier(for: $0) }
            .forEach {
                if let title = indexTitleProvider(collectionView, $0) {
                    titles.append(title)
                    sections.append($0)
                }
            }

        guard !sections.isEmpty else {
            indexTitles = nil
            return nil
        }

        indexTitles = sections
        return titles
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        indexPathForIndexTitle title: String,
        at index: Int
    ) -> IndexPath {
        guard let sections = indexTitles else {
            return IndexPath(item: 0, section: 0)
        }

        let section = sections[index]
        guard let sectionIndex = self.index(for: section) else {
            return IndexPath(item: 0, section: 0)
        }

        return IndexPath(item: 0, section: sectionIndex)
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class PrefetchDataSource: NSObject, UICollectionViewDataSourcePrefetching {
    private weak var manager: CollectionManager?

    // MARK: Initialization

    init(manager: CollectionManager) {
        self.manager = manager
    }

    // MARK: UICollectionViewDataSourcePrefetching

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let manager else {
            return
        }

        indexPaths.forEach { manager.item(at: $0)?.anyModel.prefetch() }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let manager else {
            return
        }

        indexPaths.forEach { manager.item(at: $0)?.anyModel.cancelPrefetching() }
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class CollectionViewDelegate: NSObject, UICollectionViewDelegate {
    weak var scrollDelegate: UIScrollViewDelegate?
    weak var flowLayoutDelegate: UICollectionViewDelegateFlowLayout?
    private weak var manager: CollectionManager?

    // MARK: Initialization

    init(manager: CollectionManager) {
        self.manager = manager
    }

    // MARK: UICollectionViewDelegate

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let manager else {
            return
        }

        manager.item(at: indexPath)?.anyModel.willDisplay?()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let manager, let model = manager.item(at: indexPath)?.anyModel else {
            return
        }

        model.didEndDisplaying?()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard let manager else {
            return
        }

        if let decoration = manager.decoration(ofKind: elementKind, at: indexPath) {
            update(view: view, with: decoration)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let manager, let item = manager.item(at: indexPath) else {
            return true
        }
        guard case .section = manager.selection, let section = manager.section(at: indexPath) else {
            return item.anyModel.isSelectable
        }

        switch section.selectionMode {
        case .none:
            return item.anyModel.hasDidSelect
        case .single, .multi:
            return item.anyModel.isSelectable
        }
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let manager, let item = manager.item(at: indexPath) else {
            return
        }

        item.anyModel.highlight(id: item.id)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let manager, let item = manager.item(at: indexPath) else {
            return
        }

        item.anyModel.unhighlight(id: item.id)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let manager, case .section = manager.selection, let section = manager.section(at: indexPath) else {
            return true
        }

        switch section.selectionMode {
        case .none:
            self.collectionView(collectionView, didSelectItemAt: indexPath)
            return false
        case .single, .multi:
            return true
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let manager, let item = manager.item(at: indexPath) else {
            return
        }

        if
            case .section = manager.selection,
            let section = manager.section(at: indexPath),
            section.selectionMode == .single
        {
            collectionView.indexPathsForSelectedItems?
                .filter { $0 != indexPath && $0.section == indexPath.section }
                .forEach {
                    collectionView.deselectItem(at: $0, animated: false)
                    self.collectionView(collectionView, didDeselectItemAt: $0)
                }
        }

        item.anyModel.select(id: item.id)
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard let manager, let item = manager.item(at: indexPath) else {
            return true
        }
        guard case .section = manager.selection, let section = manager.section(at: indexPath) else {
            return item.anyModel.shouldDeselect
        }

        switch section.selectionMode {
        case .none:
            return true
        case .single:
            self.collectionView(collectionView, didSelectItemAt: indexPath)
            return false
        case .multi:
            return item.anyModel.shouldDeselect
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let manager, let item = manager.item(at: indexPath) else {
            return
        }
        item.anyModel.deselect(id: item.id)
    }

    // MARK: Private

    private func update<Model: SupplementaryModel>(view: UICollectionReusableView, with model: Model) {
        (view as? Model.View)?.update(with: model)
    }
}

// MARK: - UIScrollViewDelegate

extension CollectionViewDelegate: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidZoom?(scrollView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        scrollDelegate?.scrollViewWillEndDragging?(
            scrollView,
            withVelocity: velocity,
            targetContentOffset: targetContentOffset
        )
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        scrollDelegate?.viewForZooming?(in: scrollView)
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        scrollDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScrollToTop?(scrollView)
    }

    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        flowLayoutDelegate?.collectionView?(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        ) ?? flowLayout(collectionViewLayout).itemSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        flowLayoutDelegate?.collectionView?(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        ) ?? flowLayout(collectionViewLayout).sectionInset
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        flowLayoutDelegate?.collectionView?(
            collectionView,
            layout: collectionViewLayout,
            minimumLineSpacingForSectionAt: section
        ) ?? flowLayout(collectionViewLayout).minimumLineSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        flowLayoutDelegate?.collectionView?(
            collectionView,
            layout: collectionViewLayout,
            minimumInteritemSpacingForSectionAt: section
        ) ?? flowLayout(collectionViewLayout).minimumInteritemSpacing
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        flowLayoutDelegate?.collectionView?(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderInSection: section
        ) ?? flowLayout(collectionViewLayout).headerReferenceSize
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        flowLayoutDelegate?.collectionView?(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForFooterInSection: section
        ) ?? flowLayout(collectionViewLayout).footerReferenceSize
    }

    private func flowLayout(_ layout: UICollectionViewLayout) -> UICollectionViewFlowLayout {
        layout as! UICollectionViewFlowLayout
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class CellRegistration<Cell: CollectionCell> {
    typealias Registration = UICollectionView.CellRegistration<Cell, Cell.Model>

    private let value: Registration

    // MARK: Initialization

    init() {
        value = Registration { cell, _, item in
            cell.update(with: item)
        }
    }

    // MARK: Internal

    func callAsFunction() -> Registration {
        value
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class SupplementaryRegistration<Supplementary: SupplementaryView> {
    typealias Registration = UICollectionView.SupplementaryRegistration<Supplementary>

    private let value: Registration

    // MARK: Initialization

    init(elementKind: String) {
        value = Registration(elementKind: elementKind) { _, _, _ in }
    }

    // MARK: Internal

    func callAsFunction() -> Registration {
        value
    }
}


import UIKit

final class CollectionManagerPlaceholderCell: UICollectionViewCell {}

final class ViewProvider {
    private var registrations = [String: Any]()
    private var registeredDecorations = Set<String>()
    private let placeholder = UICollectionView.CellRegistration<CollectionManagerPlaceholderCell, Int> { _, _, _ in }

    // MARK: Registration

    func register<Item: ItemModel>(cell item: Item) {
        if registration(for: item) == nil {
            registrations[item.registrationKey] = CellRegistration<Item.Cell>()
        }
    }

    func register<Model: SupplementaryModel>(supplementary model: Model) {
        if registration(for: model) == nil {
            registrations[model.registrationKey] = SupplementaryRegistration<Model.View>(elementKind: model.elementKind)
        }
    }

    func register(supplementaries: Supplementaries) {
        supplementaries().forEach { register(supplementary: $0) }
    }

    func register<Model: SupplementaryModel>(decoration model: Model, for layout: UICollectionViewLayout) {
        let key = model.registrationKey
        guard !registeredDecorations.contains(key) else {
            return
        }

        layout.register(Model.View.self, forDecorationViewOfKind: Model.elementKind)
        registeredDecorations.insert(key)
    }

    func register(decorations: Supplementaries, for layout: UICollectionViewLayout) {
        decorations().forEach { register(decoration: $0, for: layout) }
    }

    // MARK: Dequeue

    func dequeueCell(
        from collectionView: UICollectionView,
        for item: some ItemModel,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let registration = registration(for: item) else {
            return dequeuePlaceholderCell(from: collectionView, at: indexPath)
        }
        return collectionView.dequeueConfiguredReusableCell(using: registration(), for: indexPath, item: item)
    }

    func dequeuePlaceholderCell(
        from collectionView: UICollectionView,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        collectionView.dequeueConfiguredReusableCell(using: placeholder, for: indexPath, item: 0)
    }

    func dequeueSupplementary(
        from collectionView: UICollectionView,
        for model: some SupplementaryModel,
        at indexPath: IndexPath
    ) -> UICollectionReusableView? {
        guard let registration = registration(for: model) else {
            return nil
        }

        let supplementary = collectionView.dequeueConfiguredReusableSupplementary(using: registration(), for: indexPath)
        supplementary.update(with: model)
        return supplementary
    }

    // MARK: Private

    private func registration<Item: ItemModel>(for item: Item) -> CellRegistration<Item.Cell>? {
        registrations[item.registrationKey] as? CellRegistration
    }

    private func registration<Model: SupplementaryModel>(for model: Model) -> SupplementaryRegistration<Model.View>? {
        registrations[model.registrationKey] as? SupplementaryRegistration
    }
}

// MARK: -

extension ItemModel {
    var registrationKey: String {
        String(describing: Cell.self)
    }
}

extension SupplementaryModel {
    var registrationKey: String {
        String(describing: View.self)
    }
}


//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Объект секции с моделью конкретного типа
@dynamicMemberLookup
public final class Section<Model: SectionModel>: AnySection {
    /// Модель, описывающая данную секцию
    public let model: Model

    // MARK: Initialization

    init(id: SectionID, model: Model, dataSource: DataSource) {
        self.model = model
        super.init(id: id, model: model, dataSource: dataSource)
    }

    // MARK: DynamicMemberLookup

    public subscript<Value>(dynamicMember keyPath: KeyPath<Model, Value>) -> Value {
        model[keyPath: keyPath]
    }

    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Model, Value>) -> Value {
        get {
            model[keyPath: keyPath]
        }
        set {
            model[keyPath: keyPath] = newValue
        }
    }
}


//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Объект секции со стёртым типом
public class AnySection {
    let id: SectionID
    private let anyModel: any SectionModel
    private let dataSource: DataSource

    // MARK: Initialization

    init(id: SectionID, model: some SectionModel, dataSource: DataSource) {
        self.id = id
        anyModel = model
        self.dataSource = dataSource
    }
}

// MARK: - Casting

extension AnySection {
    /// Приводит модель секции к конкретному типу, если она удовлетворяет заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей секцию
    ///   - predicate: Условие, которому должна удовлетворять модель секции
    /// - Returns: Возвращает секцию с конкретным типом модели `Section<Model>`.
    /// Когда тип модели не соответствует параметру `type` или
    /// сама модель не удовлетворяет условию из параметра `predicate`, если он задан, то возвращает `nil`
    public func `as`<Model: SectionModel>(
        _ type: Model.Type,
        where predicate: ((Model) -> Bool)? = nil
    ) -> Section<Model>? {
        guard let model = anyModel as? Model, predicate?(model) ?? true else {
            return nil
        }
        return Section(id: id, model: model, dataSource: dataSource)
    }

    /// Проверяет, что модель секции является нужного типа и удовлетворяет заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей секцию
    ///   - predicate: Условие, которому должна удовлетворять модель секции
    /// - Returns: Возвращает `true`, когда тип модели соответствует параметру `type` и
    /// сама модель удовлетворяет условию из параметра `predicate`, если он задан
    public func `is`<Model: SectionModel>(_ type: Model.Type, where predicate: ((Model) -> Bool)? = nil) -> Bool {
        guard let model = anyModel as? Model else {
            return false
        }
        return predicate?(model) ?? true
    }
}

// MARK: - Supplementaries

extension AnySection {
    /// Обновляет все дополнительные элементы секции
    public func updateAllSupplementaries() {
        dataSource.updatedSupplementaries.append(anyModel.supplementaries, for: id)
    }

    /// Обновляет дополнительный элемент секции заданного типа
    /// - Parameter type: Тип дополнительного элемента
    public func updateSupplementary<Supplementary: SupplementaryModel>(_ type: Supplementary.Type) {
        dataSource.updatedSupplementaries.append(elementKind: type.elementKind, for: id)
    }
}

// MARK: - Items

extension AnySection {
    /// Количество элементов в секции
    public var numberOfItems: Int {
        dataSource.snapshot.numberOfItems(inSection: id)
    }

    /// Список всех элементов со стёртым типом в секции
    public var items: [AnyItem] {
        dataSource.snapshot.itemIdentifiers(inSection: id).compactMap {
            dataSource.item(for: $0)
        }
    }

    /// Список элементов в секции, которые соответствуют заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей элемент секции
    ///   - predicate: Условие, которому должна удовлетворять модель элемента секции
    /// - Returns: Возвращает список элементов с типом модели, заданным в параметре `type`,
    /// и удовлетворяющих условию `predicate`, если оно задано
    public func items<Model: ItemModel>(
        of type: Model.Type,
        where predicate: ((Model) -> Bool)? = nil
    ) -> [Item<Model>] {
        dataSource.snapshot.itemIdentifiers(inSection: id).compactMap {
            guard let item = dataSource.items[$0] as? Model, predicate?(item) ?? true else {
                return nil
            }
            return Item(id: $0, model: item)
        }
    }

    /// Возвращает первый элемент в секции, удовлетворяющий заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей элемент секции
    ///   - predicate: Условие, которому должна удовлетворять модель элемента секции
    /// - Returns: Элемент секции с типом `type`, который удовлетворяет условию `predicate`, если оно задано
    public func firstItem<Model: ItemModel>(
        of type: Model.Type,
        where predicate: ((Model) -> Bool)? = nil
    ) -> Item<Model>? {
        for id in dataSource.snapshot.itemIdentifiers(inSection: id) {
            if let item = dataSource.items[id] as? Model, predicate?(item) ?? true {
                return Item(id: id, model: item)
            }
        }
        return nil
    }

    /// Добавляет новые элементы в секцию
    /// - Parameter items: Список моделей новых элементов
    public func append(items: [any ItemModel]) {
        dataSource.append(items: items, toSection: id)
    }

    /// Добавляет и возвращает новый элемент в секцию
    /// - Parameter item: Модель, описывающая новый элемент
    /// - Returns: Элемент, добавленный в секцию
    @discardableResult
    public func append<Model: ItemModel>(item: Model) -> Item<Model> {
        let id = dataSource.append(items: [item], toSection: id)[0]
        return Item(id: id, model: item)
    }

    /// Вставляет новые элементы в секцию перед заданным
    /// - Parameters:
    ///   - items: Список моделей новых элементов
    ///   - item: Элемент секции, перед которым нужно вставить новые элементы
    public func insert(items: [any ItemModel], before item: AnyItem) {
        guard dataSource.contains(item: item) else {
            return
        }

        dataSource.insert(items: items, beforeItem: item.id, inSection: id)
    }

    /// Вставляет и возвращает новый элемент в секцию перед указанным
    /// - Parameters:
    ///   - item: Модель, описывающая новый элемент
    ///   - beforeItem: Элемент секции, перед которым нужно вставить новый элемент
    /// - Returns: Элемент, добавленный в секцию. `nil`, если указанный элемент отсутствует в коллекции
    @discardableResult
    public func insert<Model: ItemModel>(item: Model, beforeItem: AnyItem) -> Item<Model>? {
        guard dataSource.contains(item: beforeItem) else {
            return nil
        }

        let id = dataSource.insert(items: [item], beforeItem: beforeItem.id, inSection: id)[0]
        return Item(id: id, model: item)
    }

    /// Вставляет новые элементы в секцию после заданным
    /// - Parameters:
    ///   - items: Список моделей новых элементов
    ///   - item: Элемент секции, после которого нужно вставить новые элементы
    public func insert(items: [any ItemModel], after item: AnyItem) {
        guard dataSource.contains(item: item) else {
            return
        }

        dataSource.insert(items: items, afterItem: item.id, inSection: id)
    }

    /// Вставляет и возвращает новый элемент в секцию после указанного
    /// - Parameters:
    ///   - item: Модель, описывающая новый элемент
    ///   - afterItem: Элемент секции, после которого нужно вставить новый элемент
    /// - Returns: Элемент, добавленный в секцию. `nil`, если указанный элемент отсутствует в коллекции
    @discardableResult
    public func insert<Model: ItemModel>(item: Model, afterItem: AnyItem) -> Item<Model>? {
        guard dataSource.contains(item: afterItem) else {
            return nil
        }

        let id = dataSource.insert(items: [item], afterItem: afterItem.id, inSection: id)[0]
        return Item(id: id, model: item)
    }

    /// Удаляет заданные элементы в секции
    /// - Parameter items: Список элементов, которые нужно удалить
    public func delete(items: [AnyItem]) {
        dataSource.delete(items: items.map(\.id))
    }

    /// Удаляет все элементы из секции
    public func deleteAllItems() {
        let identifiers = dataSource.snapshot.itemIdentifiers(inSection: id)
        dataSource.delete(items: identifiers)
    }

    /// Перемещает элемент в новую позицию в секции до заданного элемента
    /// - Parameters:
    ///   - item: Элемент, который нужно переместить
    ///   - toItem: Элемент, перед которым нужно вставить перемещаемый элемент
    public func move(item: AnyItem, before toItem: AnyItem) {
        guard dataSource.contains(item: item), dataSource.contains(item: toItem) else {
            return
        }

        dataSource.snapshot.moveItem(item.id, beforeItem: toItem.id)
    }

    /// Перемещает элемент в новую позицию в секции после заданного элемента
    /// - Parameters:
    ///   - item: Элемент, который нужно переместить
    ///   - toItem: Элемент, после которого нужно вставить перемещаемый элемент
    public func move(item: AnyItem, after toItem: AnyItem) {
        guard dataSource.contains(item: item), dataSource.contains(item: toItem) else {
            return
        }

        dataSource.snapshot.moveItem(item.id, afterItem: toItem.id)
    }

    /// Перезагружает заданные элементы в секции
    /// - Parameter items: Список элементов, которые нужно перезагрузить
    public func reload(items: [AnyItem]) {
        let ids = items.compactMap { dataSource.contains(item: $0) ? $0.id : nil }
        guard !ids.isEmpty else {
            return
        }

        dataSource.snapshot.reloadItems(ids)
    }

    /// Обновляет заданные элементы в секции
    ///
    /// В отличии от `reload(items:)` обновляет данные в текущей ячейке, а не запрашивает новую
    /// - Parameter items: Список элементов, которые нужно обновить
    public func update(items: [AnyItem]) {
        let ids = items.compactMap { dataSource.contains(item: $0) ? $0.id : nil }
        guard !ids.isEmpty else {
            return
        }

        dataSource.snapshot.reconfigureItems(ids)
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Объект, описывающий новую секцию для добавления в коллекцию. Состоит из модели секции и списка моделей элементов
public struct NewSection {
    let id: SectionID
    let model: any SectionModel
    private(set) var items: [any ItemModel]

    // MARK: Properties

    /// Количество элементов в секции
    public var numberOfItems: Int {
        items.count
    }

    // MARK: Initialization

    /// Создаёт новую секцию для добавления в коллекцию
    /// - Parameters:
    ///   - model: Модель секции
    ///   - items: Список элементов в секции
    public init(_ model: some SectionModel, items: [any ItemModel] = []) {
        id = SectionID(model)
        self.model = model
        self.items = items
    }

    // MARK: Populating

    /// Добавляет новый элемент в секцию в конец списка
    /// - Parameter item: Модель нового элемента
    public mutating func append(item: some ItemModel) {
        items.append(item)
    }

    /// Добавляет набор новых элементов в секцию в конец списка
    /// - Parameter items: Список моделей новых моделей
    public mutating func append(items: [any ItemModel]) {
        self.items.append(contentsOf: items)
    }
}



import Foundation

final class DataSource {
    var snapshot: Snapshot
    var sections: SectionsType
    var items: ItemsType
    var views = UniqueViews()
    var updatedSupplementaries = UpdatedSupplementaries()

    // MARK: Initialization

    init(_ snapshot: Snapshot, sections: SectionsType, items: ItemsType) {
        self.snapshot = snapshot
        self.sections = sections
        self.items = items
    }

    // MARK: Data

    func contains(section: AnySection) -> Bool {
        sections[section.id] != nil
    }

    func contains(item: AnyItem) -> Bool {
        items[item.id] != nil
    }

    func item(for itemID: ItemID) -> AnyItem? {
        guard let item = items[itemID] else {
            return nil
        }
        return AnyItem(id: itemID, model: item)
    }

    func add(sections: [CollectionManager.NewSection]) {
        for section in sections {
            register(supplementaries: section.model.supplementaries)
            register(decorations: section.model.decorations)
            self.sections[section.id] = section.model
            append(items: section.items, toSection: section.id)
        }
    }

    func delete(sections identifiers: [SectionID]) {
        let itemIdentifiers = identifiers.flatMap { snapshot.itemIdentifiers(inSection: $0) }
        identifiers.forEach { sections.removeValue(forKey: $0) }
        itemIdentifiers.forEach { items.removeValue(forKey: $0) }
        snapshot.deleteSections(identifiers)
    }

    @discardableResult
    func append(items: [any ItemModel], toSection section: SectionID) -> [ItemID] {
        let identifiers = add(items: items, toSection: section)
        snapshot.appendItems(identifiers, toSection: section)
        return identifiers
    }

    @discardableResult
    func insert(items: [any ItemModel], beforeItem item: ItemID, inSection section: SectionID) -> [ItemID] {
        let identifiers = add(items: items, toSection: section)
        snapshot.insertItems(identifiers, beforeItem: item)
        return identifiers
    }

    @discardableResult
    func insert(items: [any ItemModel], afterItem item: ItemID, inSection section: SectionID) -> [ItemID] {
        let identifiers = add(items: items, toSection: section)
        snapshot.insertItems(identifiers, afterItem: item)
        return identifiers
    }

    func delete(items identifiers: [ItemID]) {
        identifiers.forEach { items.removeValue(forKey: $0) }
        snapshot.deleteItems(identifiers)
    }

    private func add(items: [any ItemModel], toSection section: SectionID) -> [ItemID] {
        items.map { item in
            register(supplementaries: item.supplementaries)
            register(cell: item)
            let itemId = ItemID(item, inSection: section)
            self.items[itemId] = item
            return itemId
        }
    }

    // MARK: Registration

    private func register(cell: some ItemModel) {
        views.add(cell: cell)
    }

    private func register(supplementaries: Supplementaries) {
        supplementaries().forEach { views.add(supplementary: $0) }
    }

    private func register(decorations: Supplementaries) {
        decorations().forEach { views.add(decoration: $0) }
    }
}

// MARK: -

extension DataSource {
    struct UniqueViews {
        var cells = [String: any ItemModel]()
        var supplementaries = [String: any SupplementaryModel]()
        var decorations = [String: any SupplementaryModel]()

        mutating func add(cell: some ItemModel) {
            let key = cell.registrationKey
            if cells[key] == nil {
                cells[key] = cell
            }
        }

        mutating func add(supplementary: some SupplementaryModel) {
            let key = supplementary.registrationKey
            if supplementaries[key] == nil {
                supplementaries[key] = supplementary
            }
        }

        mutating func add(decoration: some SupplementaryModel) {
            let key = decoration.registrationKey
            if decorations[key] == nil {
                decorations[key] = decoration
            }
        }

        mutating func removeAll() {
            cells.removeAll()
            supplementaries.removeAll()
            decorations.removeAll()
        }
    }

    struct UpdatedSupplementaries: Sequence {
        var isEmpty: Bool {
            storage.isEmpty
        }

        private var storage = [SectionID: Set<String>]()

        mutating func append(elementKind: String, for sectionID: SectionID) {
            storage[sectionID, default: []].insert(elementKind)
        }

        mutating func append(_ supplementaries: Supplementaries, for sectionID: SectionID) {
            storage[sectionID, default: []].formUnion(supplementaries().map(\.elementKind))
        }

        func makeIterator() -> AnyIterator<(sectionID: SectionID, elementKinds: Set<String>)> {
            var iterator = storage.makeIterator()
            return AnyIterator {
                guard let element = iterator.next() else {
                    return nil
                }
                return (element.key, element.value)
            }
        }
    }
}


import UIKit

typealias Snapshot = NSDiffableDataSourceSnapshot<SectionID, ItemID>
typealias SectionsType = [SectionID: any SectionModel]
typealias ItemsType = [ItemID: any ItemModel]

/// Класс, управляющий коллекцией
public final class CollectionManager {
    /// Класс коллекции, которую должен создать менеджер
    public var collectionViewClass: UICollectionView.Type = UICollectionView.self
    /// Тип класса компоновки коллекции
    ///
    /// Изменения не применяются, если происходят после вызова свойства `collectionView`
    public var layout: Layout = .compositional(UICollectionViewCompositionalLayoutConfiguration())
    /// Настройка, определяющая объект, управляющий выбором ячеек. Это может быть коллекция или секция.
    /// По умолчанию выбором управляет секция
    ///
    /// Изменения не применяются, если происходят после вызова свойства `collectionView`
    public var selection: Selection = .section

    /// Модели дополнительных элементов для всей коллекции. Например, глобальный заголовок
//    public var supplementaries: Supplementaries = [] {
//        didSet {
//            viewProvider.register(supplementaries: supplementaries)
//        }
//    }
    /// Обработчик пагинации для всей коллекции
    ///
    /// Элементом пагинации является вся секция.
    ///
    /// Управляет показом индикатора загрузки, состоянием ошибки и запросом следующей порции данных.
    /// По умолчанию пагинация для всей коллекции отключена.
    /// - Note: Если задан обработчик пагинации для всей коллекции, то обработчики в секциях игнорируются
//    public var pagination: PaginationHandler? {
//        didSet {
//            if let pagination {
//                configure(pagination: pagination, for: pagination.sectionID())
//            }
//        }
//    }

    /// Делегат scroll view
    public weak var scrollDelegate: UIScrollViewDelegate? {
        get { delegate.scrollDelegate }
        set { delegate.scrollDelegate = newValue }
    }

    /// Список всех выбранных элементов
    public var selectedItems: [AnyItem] {
        (collectionView.indexPathsForSelectedItems ?? []).compactMap { item(at: $0) }
    }

    /// Список видимых элементов коллеции
    ///
    /// Список является несортированным
    public var visibleItems: [AnyItem] {
        collectionView.indexPathsForVisibleItems.compactMap { item(at: $0) }
    }

    /// Указывает, является ли коллекция пустой
    public var isEmpty: Bool {
        sections.isEmpty
    }

    /// Объект класса `UICollectionView`, которым управляет менеджер
    public private(set) lazy var collectionView = configureCollectionView()

    private lazy var dataSource: DiffableDataSource = configureDataSource()
    private lazy var prefetchDataSource = PrefetchDataSource(manager: self)
    private lazy var delegate = CollectionViewDelegate(manager: self)

    private let viewProvider = ViewProvider()
    private var sections: SectionsType = [:]
    private var items: ItemsType = [:]

    // MARK: Initialization

    /// Создаёт экземпляр класса, управляющего коллекцией
    public init() {}

    // MARK: Configuration

    private func configureCollectionView() -> UICollectionView {
        let collectionView = collectionViewClass.init(frame: .zero, collectionViewLayout: configureLayout())

        switch selection {
        case .collectionView(.none):
            collectionView.allowsSelection = false
        case .collectionView(.single):
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = false
        case .collectionView(.multi), .section:
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
        }

        collectionView.prefetchDataSource = prefetchDataSource
        collectionView.delegate = delegate
        return collectionView
    }

    private func configureLayout() -> UICollectionViewLayout {
        switch layout {
        case let .compositional(configuration):
            return UICollectionViewCompositionalLayout(
                sectionProvider: { [weak self] section, environment in
                    guard let self, let section = self.section(at: section) else {
                        // Если слепок содержит удаление секции и обновление ячеек через `reconfigureItems`,
                        // то коллекция может запросить макет для удалённой секции. Если вернуть `nil`,
                        // то приложение упадёт
                        let size = NSCollectionLayoutSize(widthDimension: .absolute(1), heightDimension: .absolute(1))
                        let item = NSCollectionLayoutItem(layoutSize: size)
                        return NSCollectionLayoutSection(group: .horizontal(layoutSize: size, subitems: [item]))
                    }

                    section.leadingSwipeActionsProvider = { [weak self] in
                        guard let item = self?.item(at: $0) else {
                            return nil
                        }
                        return item.anyModel.leadingSwipeActions
                    }
                    section.trailingSwipeActionsProvider = { [weak self] in
                        guard let item = self?.item(at: $0) else {
                            return nil
                        }
                        return item.anyModel.trailingSwipeActions
                    }

                    return section.layout(environment: environment)
                },
                configuration: configuration
            )
        case let .flow(layout, flowLayoutDelegate):
            delegate.flowLayoutDelegate = flowLayoutDelegate
            return layout
        case let .custom(layout):
            return layout
        }
    }

    private func configureDataSource() -> DiffableDataSource {
        let dataSource = DiffableDataSource(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else {
                return UICollectionViewCell()
            }
            if let item = self.items[itemIdentifier] {
                return self.viewProvider.dequeueCell(from: collectionView, for: item, at: indexPath)
            } else {
                // Если слепок содержит удаление и обновление ячеек через `reconfigureItems`,
                // то коллекция может запросить удалённую ячейку. Если вернуть `UICollectionViewCell()`,
                // то приложение упадёт
                return self.viewProvider.dequeuePlaceholderCell(from: collectionView, at: indexPath)
            }
        }
//        dataSource.supplementaryViewProvider = { [weak self] collectionView, elementKind, indexPath in
//            guard let self, let supplementary = self.supplementary(ofKind: elementKind, at: indexPath) else {
//                return nil
//            }
//            return self.viewProvider.dequeueSupplementary(from: collectionView, for: supplementary, at: indexPath)
//        }
        dataSource.indexTitleProvider = { [weak self] _, section in
            self?.sections[section]?.indexTitle
        }
        return dataSource
    }

    // MARK: Internal

    func section(at indexPath: IndexPath) -> (any SectionModel)? {
        section(at: indexPath.section)
    }

    func item(at indexPath: IndexPath) -> AnyItem? {
        guard let itemID = dataSource.itemIdentifier(for: indexPath), let item = items[itemID] else {
            return nil
        }
        return AnyItem(id: itemID, model: item)
    }

//    func supplementary(ofKind elementKind: String, at indexPath: IndexPath) -> (any SupplementaryModel)? {
//        if indexPath.count == 1 {
//            return supplementaries(ofKind: elementKind)
//        }
//
//        if
//            let itemID = dataSource.itemIdentifier(for: indexPath),
//            let supplementary = self.items[itemID]?.supplementaries(ofKind: elementKind)
//        {
//            return supplementary
//        }
//
//        guard
//            let sectionID = dataSource.sectionIdentifier(for: indexPath.section),
//            let supplementary = self.sections[sectionID]?.supplementaries(ofKind: elementKind)
//        else {
//            return nil
//        }
//
//        return supplementary
//    }

    func decoration(ofKind elementKind: String, at indexPath: IndexPath) -> (any SupplementaryModel)? {
        guard let sectionID = dataSource.sectionIdentifier(for: indexPath.section) else {
            return nil
        }
        return sections[sectionID]?.decorations(ofKind: elementKind)
    }
    
    //
    //  petrovich
    //  Copyright © 2023 Heads and Hands. All rights reserved.
    //

    /// Объект, описывающий новую секцию для добавления в коллекцию. Состоит из модели секции и списка моделей элементов
    public struct NewSection {
        let id: SectionID
        let model: any SectionModel
        private(set) var items: [any ItemModel]

        // MARK: Properties

        /// Количество элементов в секции
        public var numberOfItems: Int {
            items.count
        }

        // MARK: Initialization

        /// Создаёт новую секцию для добавления в коллекцию
        /// - Parameters:
        ///   - model: Модель секции
        ///   - items: Список элементов в секции
        public init(_ model: some SectionModel, items: [any ItemModel] = []) {
            id = SectionID(model)
            self.model = model
            self.items = items
        }

        // MARK: Populating

        /// Добавляет новый элемент в секцию в конец списка
        /// - Parameter item: Модель нового элемента
        public mutating func append(item: some ItemModel) {
            items.append(item)
        }

        /// Добавляет набор новых элементов в секцию в конец списка
        /// - Parameter items: Список моделей новых моделей
        public mutating func append(items: [any ItemModel]) {
            self.items.append(contentsOf: items)
        }
    }


    // MARK: Private

    private func makeSnapshot(
        for sections: [NewSection],
        reload: Bool
    ) -> (snapshot: Snapshot, supplementaries: DataSource.UpdatedSupplementaries, paginationItems: [ItemID]) {
        var snapshot = Snapshot()
        var supplementaries = DataSource.UpdatedSupplementaries()
        var paginationItems: [ItemID] = []
        if sections.isEmpty {
            return (snapshot, supplementaries, paginationItems)
        }

        var newSections = SectionsType()
        var newItems = ItemsType()

        var sections = sections

        snapshot.appendSections(sections.map(\.id))
        for section in sections {
            viewProvider.register(supplementaries: section.model.supplementaries)
            viewProvider.register(decorations: section.model.decorations, for: collectionView.collectionViewLayout)
            newSections[section.id] = section.model
            if !reload, let oldSection = self.sections[section.id] {
                section.model.updatedSupplementaries(comparedTo: oldSection).forEach {
                    supplementaries.append(elementKind: $0, for: section.id)
                }
            }

            var items = section.items

            var reconfiguredItems = [ItemID]()
            let itemIds = items.map { item in
                viewProvider.register(supplementaries: item.supplementaries)
                viewProvider.register(cell: item)
                let itemId = ItemID(item, inSection: section.id)
                newItems[itemId] = item
                if !reload, let oldItem = self.items[itemId], item.hasDifference(comparedTo: oldItem) {
                    reconfiguredItems.append(itemId)
                }
                return itemId
            }
            snapshot.appendItems(itemIds, toSection: section.id)
            snapshot.reconfigureItems(reconfiguredItems)
        }

        self.sections = newSections
        self.items = newItems
        setUpdateDataHandlers()
        return (snapshot, supplementaries, paginationItems)
    }

    private func setUpdateDataHandlers() {
        for (sectionID, model) in sections {
            for supplementary in model.supplementaries() {
                supplementary.updateDataHandler = { [weak self] elementKind in
                    guard let self else {
                        return
                    }

                    var supplementaries = DataSource.UpdatedSupplementaries()
                    supplementaries.append(elementKind: elementKind, for: sectionID)
                    self.updateSupplementaries(supplementaries)
                }
            }
        }
        for (itemID, model) in items {
            model.updateDataHandler = { [weak self] animated in
                guard let self else {
                    return
                }

                var snapshot = self.dataSource.snapshot()
                guard self.items[itemID] != nil else {
                    return
                }

                snapshot.reconfigureItems([itemID])
                self.dataSource.apply(snapshot, animatingDifferences: animated)
            }
        }
    }

    private func updateSupplementaries(_ supplementaries: DataSource.UpdatedSupplementaries) {
        if supplementaries.isEmpty {
            return
        }

        for (sectionID, elementKinds) in supplementaries {
            guard let index = dataSource.index(for: sectionID) else {
                continue
            }

            let indexPath = IndexPath(item: 0, section: index)
            for elementKind in elementKinds {
                guard
                    collectionView.indexPathsForVisibleSupplementaryElements(ofKind: elementKind).contains(indexPath),
//                    let supplementary = supplementary(ofKind: elementKind, at: indexPath),
                    let view = collectionView.supplementaryView(forElementKind: elementKind, at: indexPath)
                else {
                    continue
                }

//                updateSupplementary(view, with: supplementary)
            }
        }
    }

    private func updateSupplementary<Model: SupplementaryModel>(_ view: UICollectionReusableView, with model: Model) {
        if let view = view as? Model.View {
            view.update(with: model)
            view.layoutIfNeeded()
        }
    }

    private func registerViewsIfNeeded(_ dataSource: DataSource) {
        dataSource.views.supplementaries.values.forEach { viewProvider.register(supplementary: $0) }
        dataSource.views.decorations.values.forEach {
            viewProvider.register(decoration: $0, for: collectionView.collectionViewLayout)
        }
        dataSource.views.cells.values.forEach { viewProvider.register(cell: $0) }
    }

    private func section(at index: Int) -> (any SectionModel)? {
        guard let sectionID = dataSource.sectionIdentifier(for: index) else {
            return nil
        }
        return sections[sectionID]
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

/// Представление состояния данных в коллекции в определенный момент времени
public struct DataSourceSnapshot {
    let dataSource: DataSource
}

// MARK: - Sections

extension DataSourceSnapshot {
    /// Количество секций в коллекции
    public var numberOfSections: Int {
        dataSource.snapshot.numberOfSections
    }

    /// Список всех секций со стёртым типом в коллекции
    public var sections: [AnySection] {
        dataSource.snapshot.sectionIdentifiers.compactMap {
            guard let section = dataSource.sections[$0] else {
                return nil
            }
            return AnySection(id: $0, model: section, dataSource: dataSource)
        }
    }

    /// Список всех секций, которые соответствуют заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей секцию
    ///   - predicate: Условие, которому должна удовлетворять модель секции
    /// - Returns: Возвращает список секций с типом модели, заданным в параметре `type`,
    /// и удовлетворяющих условию `predicate`, если оно задано
    public func sections<Model: SectionModel>(
        of type: Model.Type,
        where predicate: ((Model) -> Bool)? = nil
    ) -> [Section<Model>] {
        dataSource.snapshot.sectionIdentifiers.compactMap {
            guard let section = dataSource.sections[$0] as? Model, predicate?(section) ?? true else {
                return nil
            }
            return Section(id: $0, model: section, dataSource: dataSource)
        }
    }

    /// Возвращает первую секцию, удовлетворяющую заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей секцию
    ///   - predicate: Условие, которому должна удовлетворять модель секции
    /// - Returns: Секция с типом `type`, которая удовлетворяет условию `predicate`, если оно задано
    public func firstSection<Model: SectionModel>(
        of type: Model.Type,
        where predicate: ((Model) -> Bool)? = nil
    ) -> Section<Model>? {
        for id in dataSource.snapshot.sectionIdentifiers {
            if let section = dataSource.sections[id] as? Model, predicate?(section) ?? true {
                return Section(id: id, model: section, dataSource: dataSource)
            }
        }
        return nil
    }

    /// Возвращает секцию со стёртым типом, которая содержит заданный элемент
    /// - Parameter item: Элемент коллекции, по которому нужно найти секцию
    /// - Returns: Секцию со стёртым типом
    public func section(containingItem item: AnyItem) -> AnySection? {
        guard
            let sectionID = dataSource.snapshot.sectionIdentifier(containingItem: item.id),
            let section = dataSource.sections[sectionID]
        else {
            return nil
        }
        return AnySection(id: sectionID, model: section, dataSource: dataSource)
    }

    /// Добавляет новые секции в коллекцию
    /// - Parameter sections: Список новых секций
    public func append(sections: [CollectionManager.NewSection]) {
        dataSource.snapshot.appendSections(sections.map(\.id))
        dataSource.add(sections: sections)
    }

    /// Вставляет новые секции в коллекцию перед заданной
    /// - Parameters:
    ///   - sections: Список новых секций
    ///   - section: Секция, до которой нужно вставить новые секции
    public func insert(sections: [CollectionManager.NewSection], before section: AnySection) {
        guard dataSource.contains(section: section) else {
            return
        }

        dataSource.snapshot.insertSections(sections.map(\.id), beforeSection: section.id)
        dataSource.add(sections: sections)
    }

    /// Вставляет новые секции в коллекцию после заданной
    /// - Parameters:
    ///   - sections: Список новых секций
    ///   - section: Секция, после которой нужно вставить новые секции
    public func insert(sections: [CollectionManager.NewSection], after section: AnySection) {
        guard dataSource.contains(section: section) else {
            return
        }

        dataSource.snapshot.insertSections(sections.map(\.id), afterSection: section.id)
        dataSource.add(sections: sections)
    }

    /// Удаляет заданные секции из коллекции
    /// - Parameter sections: Список секций, которые нужно удалить
    public func delete(sections: [AnySection]) {
        dataSource.delete(sections: sections.map(\.id))
    }

    /// Перемещает секцию в позицию до заданной секции
    /// - Parameters:
    ///   - section: Секция, которую нужно переместить
    ///   - toSection: Секция, перед которой нужно вставить перемещаемую секцию
    public func move(section: AnySection, before toSection: AnySection) {
        guard dataSource.contains(section: section), dataSource.contains(section: toSection) else {
            return
        }

        dataSource.snapshot.moveSection(section.id, beforeSection: toSection.id)
    }

    /// Перемещает секцию в позицию после заданной секции
    /// - Parameters:
    ///   - section: Секция, которую нужно переместить
    ///   - toSection: Секция, после которой нужно вставить перемещаемую секцию
    public func move(section: AnySection, after toSection: AnySection) {
        guard dataSource.contains(section: section), dataSource.contains(section: toSection) else {
            return
        }

        dataSource.snapshot.moveSection(section.id, afterSection: toSection.id)
    }

    /// Перезагружает заданные секции
    /// - Parameter sections: Список секций, которые нужно перезагрузить
    public func reload(sections: [AnySection]) {
        let ids = sections.compactMap { dataSource.contains(section: $0) ? $0.id : nil }
        guard !ids.isEmpty else {
            return
        }

        dataSource.snapshot.reloadSections(ids)
    }
}

// MARK: - Items

extension DataSourceSnapshot {
    /// Количество элементов в коллекции
    public var numberOfItems: Int {
        dataSource.snapshot.numberOfItems
    }

    /// Список всех элементов со стёртым типом в коллекции
    public var items: [AnyItem] {
        dataSource.snapshot.itemIdentifiers.compactMap {
            dataSource.item(for: $0)
        }
    }

    /// Список всех элементов в коллекции, которые соответствуют заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей элемент коллекции
    ///   - predicate: Условие, которому должна удовлетворять модель элемента коллекции
    /// - Returns: Возвращает список элементов с типом модели, заданным в параметре `type`,
    /// и удовлетворяющих условию `predicate`, если оно задано
    public func items<Model: ItemModel>(
        of type: Model.Type,
        where predicate: ((Model) -> Bool)? = nil
    ) -> [Item<Model>] {
        dataSource.snapshot.itemIdentifiers.compactMap {
            guard let item = dataSource.items[$0] as? Model, predicate?(item) ?? true else {
                return nil
            }
            return Item(id: $0, model: item)
        }
    }

    /// Возвращает первый элемент в коллекции, удовлетворяющий заданным условиям
    /// - Parameters:
    ///   - type: Тип модели, описывающей элемент коллекции
    ///   - predicate: Условие, которому должна удовлетворять модель элемента коллекции
    /// - Returns: Элемент коллекции с типом `type`, который удовлетворяет условию `predicate`, если оно задано
    public func firstItem<Model: ItemModel>(
        of type: Model.Type,
        where predicate: ((Model) -> Bool)? = nil
    ) -> Item<Model>? {
        for id in dataSource.snapshot.itemIdentifiers {
            if let item = dataSource.items[id] as? Model, predicate?(item) ?? true {
                return Item(id: id, model: item)
            }
        }
        return nil
    }

    /// Добавляет новые элементы в коллекцию
    /// - Parameter items: Список моделей новых элементов
    public func append(items: [any ItemModel]) {
        guard let section = dataSource.snapshot.sectionIdentifiers.last else {
            return
        }

        dataSource.append(items: items, toSection: section)
    }

    /// Добавляет и возвращает новый элемент в коллекцию
    ///
    /// Если в коллекции нет секций, то добавления не происходит
    /// - Parameter item: Модель, описывающая новый элемент
    /// - Returns: Элемент, добавленный в коллекцию. Если в коллекции нет секций, то метод возвращает `nil`
    @discardableResult
    public func append<Model: ItemModel>(item: Model) -> Item<Model>? {
        guard let section = dataSource.snapshot.sectionIdentifiers.last else {
            return nil
        }

        let id = dataSource.append(items: [item], toSection: section)[0]
        return Item(id: id, model: item)
    }

    /// Вставляет новые элементы перед заданным
    /// - Parameters:
    ///   - items: Список моделей новых элементов
    ///   - item: Элемент коллекции, перед которым нужно вставить новые элементы
    public func insert(items: [any ItemModel], before item: AnyItem) {
        guard
            dataSource.contains(item: item),
            let section = dataSource.snapshot.sectionIdentifier(containingItem: item.id)
        else {
            return
        }

        dataSource.insert(items: items, beforeItem: item.id, inSection: section)
    }

    /// Вставляет и возвращает новый элемент перед указанным
    /// - Parameters:
    ///   - item: Модель, описывающая новый элемент
    ///   - beforeItem: Элемент коллекции, перед которым нужно вставить новый элемент
    /// - Returns: Элемент, добавленный в коллекцию.
    /// Если указанный элемент отсутствует в коллекции, то метод возвращает `nil`
    @discardableResult
    public func insert<Model: ItemModel>(item: Model, beforeItem: AnyItem) -> Item<Model>? {
        guard
            dataSource.contains(item: beforeItem),
            let section = dataSource.snapshot.sectionIdentifier(containingItem: beforeItem.id)
        else {
            return nil
        }

        let id = dataSource.insert(items: [item], beforeItem: beforeItem.id, inSection: section)[0]
        return Item(id: id, model: item)
    }

    /// Вставляет новые элементы после заданным
    /// - Parameters:
    ///   - items: Список моделей новых элементов
    ///   - item: Элемент коллекции, после которого нужно вставить новые элементы
    public func insert(items: [any ItemModel], after item: AnyItem) {
        guard
            dataSource.contains(item: item),
            let section = dataSource.snapshot.sectionIdentifier(containingItem: item.id)
        else {
            return
        }

        dataSource.insert(items: items, afterItem: item.id, inSection: section)
    }

    /// Вставляет и возвращает новый элемент после указанного
    /// - Parameters:
    ///   - item: Модель, описывающая новый элемент
    ///   - afterItem: Элемент коллекции, после которого нужно вставить новый элемент
    /// - Returns: Элемент, добавленный в коллекцию.
    /// Если указанный элемент отсутствует в коллекции, то метод возвращает `nil`
    @discardableResult
    public func insert<Model: ItemModel>(item: Model, afterItem: AnyItem) -> Item<Model>? {
        guard
            dataSource.contains(item: afterItem),
            let section = dataSource.snapshot.sectionIdentifier(containingItem: afterItem.id)
        else {
            return nil
        }

        let id = dataSource.insert(items: [item], afterItem: afterItem.id, inSection: section)[0]
        return Item(id: id, model: item)
    }

    /// Удаляет заданные элементы
    /// - Parameter items: Список элементов, которые нужно удалить
    public func delete(items: [AnyItem]) {
        dataSource.delete(items: items.map(\.id))
    }

    /// Удаляет все секции и элементы из коллекции
    public func deleteAllItems() {
        dataSource.snapshot.deleteAllItems()
        dataSource.sections.removeAll()
        dataSource.items.removeAll()
        dataSource.views.removeAll()
    }

    /// Перемещает элемент в новую позицию до заданного элемента
    /// - Parameters:
    ///   - item: Элемент, который нужно переместить
    ///   - toItem: Элемент, перед которым нужно вставить перемещаемый элемент
    public func move(item: AnyItem, before toItem: AnyItem) {
        guard dataSource.contains(item: item), dataSource.contains(item: toItem) else {
            return
        }

        dataSource.snapshot.moveItem(item.id, beforeItem: toItem.id)
    }

    /// Перемещает элемент в новую позицию после заданного элемента
    /// - Parameters:
    ///   - item: Элемент, который нужно переместить
    ///   - toItem: Элемент, после которого нужно вставить перемещаемый элемент
    public func move(item: AnyItem, after toItem: AnyItem) {
        guard dataSource.contains(item: item), dataSource.contains(item: toItem) else {
            return
        }

        dataSource.snapshot.moveItem(item.id, afterItem: toItem.id)
    }

    /// Перезагружает заданные элементы
    /// - Parameter items: Список элементов, которые нужно перезагрузить
    public func reload(items: [AnyItem]) {
        let ids = items.compactMap { dataSource.contains(item: $0) ? $0.id : nil }
        guard !ids.isEmpty else {
            return
        }

        dataSource.snapshot.reloadItems(ids)
    }

    /// Обновляет заданные элементы
    ///
    /// В отличии от `reload(items:)` обновляет данные в текущей ячейке, а не запрашивает новую
    /// - Parameter items: Список элементов, которые нужно обновить
    public func update(items: [AnyItem]) {
        let ids = items.compactMap { dataSource.contains(item: $0) ? $0.id : nil }
        guard !ids.isEmpty else {
            return
        }

        dataSource.snapshot.reconfigureItems(ids)
    }
}


// MARK: - Pagination (Private)

extension CollectionManager {
//    private func configure(pagination: PaginationHandler, for sectionID: SectionID) {
//        pagination.reloadHandler = { [weak self] pagination in
//            guard let self else {
//                return
//            }
//
//            let paginationIDs = pagination.itemIDs(inSection: sectionID).filter { self.items[$0] != nil }
//            var snapshot = self.dataSource.snapshot()
//            defer {
//                self.dataSource.apply(snapshot)
//            }
//
//            guard let itemVM = pagination.itemModel() else {
//                paginationIDs.forEach { self.items.removeValue(forKey: $0) }
//                if self.pagination == nil {
//                    snapshot.deleteItems(paginationIDs)
//                } else {
//                    self.sections.removeValue(forKey: sectionID)
//                    snapshot.deleteSections([sectionID])
//                }
//                return
//            }
//
//            self.viewProvider.register(supplementaries: itemVM.supplementaries)
//            self.viewProvider.register(cell: itemVM)
//
//            let itemID = pagination.itemID(itemVM, inSection: sectionID)
//
//            snapshot.deleteItems(paginationIDs)
//            snapshot.appendItems([itemID], toSection: sectionID)
//
//            if let oldItem = self.items[itemID], itemVM.hasDifference(comparedTo: oldItem) {
//                snapshot.reconfigureItems([itemID])
//            }
//
//            paginationIDs.forEach { self.items.removeValue(forKey: $0) }
//            self.items[itemID] = itemVM
//        }
//    }
//
//    private func updatePaginationCells(_ dataSource: DataSource) -> [ItemID] {
//        let paginationHandlers: [(SectionID, PaginationHandler)]
//        if let pagination {
//            let sectionID = pagination.sectionID()
//            if let section = pagination.sectionModel() {
//                if dataSource.snapshot.indexOfSection(sectionID) == nil {
//                    dataSource.snapshot.appendSections([sectionID])
//                    dataSource.add(sections: [section])
//                } else if let lastSection = dataSource.snapshot.sectionIdentifiers.last, lastSection != sectionID {
//                    dataSource.snapshot.moveSection(sectionID, afterSection: lastSection)
//                }
//                paginationHandlers = [(sectionID, pagination)]
//            } else {
//                if dataSource.snapshot.indexOfSection(sectionID) != nil {
//                    dataSource.delete(sections: [sectionID])
//                }
//                paginationHandlers = []
//            }
//        } else {
//            paginationHandlers = dataSource.snapshot.sectionIdentifiers.compactMap {
//                guard let pagination = dataSource.sections[$0]?.pagination else {
//                    return nil
//                }
//                return ($0, pagination)
//            }
//        }
//
//        var paginationItems: [ItemID] = []
//        var reconfiguredItems: [ItemID] = []
//        for (sectionID, pagination) in paginationHandlers {
//            let paginationIDs = pagination.itemIDs(inSection: sectionID).filter { dataSource.items[$0] != nil }
//            guard let itemVM = pagination.itemModel() else {
//                dataSource.delete(items: paginationIDs)
//                continue
//            }
//
//            let itemID = pagination.itemID(itemVM, inSection: sectionID)
//            if let oldItem = dataSource.items[itemID], itemVM.hasDifference(comparedTo: oldItem) {
//                reconfiguredItems.append(itemID)
//            }
//
//            dataSource.delete(items: paginationIDs)
//            dataSource.append(items: [itemVM], toSection: sectionID)
//
//            configure(pagination: pagination, for: sectionID)
//            if itemVM.hasActions {
//                paginationItems.append(itemID)
//            }
//        }
//        dataSource.snapshot.reconfigureItems(reconfiguredItems)
//        return paginationItems
//    }

    private func scrollToPaginationCell(_ items: [ItemID], animated: Bool) {
        guard !items.isEmpty else {
            return
        }

        let visibleIndexPaths = Set(collectionView.indexPathsForVisibleItems)
        let indexPath = items.lazy
            .compactMap { self.dataSource.indexPath(for: $0) }
            .first { visibleIndexPaths.contains($0) }
        if let indexPath {
            collectionView.scrollToItem(at: indexPath, at: [], animated: animated)
        }
    }
}

// MARK: - Data

extension CollectionManager {
    /// Заменяет все данные в коллекции, вычисляет разницу между текущим и новым состояниями,
    /// опционально анимирует изменения
    /// - Parameters:
    ///   - sections: Список секций
    ///   - animated: `true`, если нужно анимировать изменения
    ///   - completion: Блок, который вызывается после применения всех изменений
    public func set(sections: [NewSection], animated: Bool = true, completion: (() -> Void)? = nil) {
        let data = makeSnapshot(for: sections, reload: false)
        dataSource.apply(data.snapshot, animatingDifferences: animated) {
            self.updateSupplementaries(data.supplementaries)
            self.scrollToPaginationCell(data.paginationItems, animated: animated)
            completion?()
        }
    }

    /// Заменяет все данные в коллекции на новые без вычисления разницы и анимации
    /// - Parameters:
    ///   - sections: Список секций
    ///   - completion: Блок, который вызывается после применения всех изменений
    public func reload(sections: [NewSection], completion: (() -> Void)? = nil) {
        let data = makeSnapshot(for: sections, reload: true)
        dataSource.applySnapshotUsingReloadData(data.snapshot) {
            self.scrollToPaginationCell(data.paginationItems, animated: false)
            completion?()
        }
    }

    /// Обновляет данные в коллекции, вычисляет разницу между текущим и новым состояниями,
    /// опционально анимирует изменения
    /// - Parameters:
    ///   - changes: Блок, который изменяет данные в коллекции
    ///   - animated: `true`, если нужно анимировать изменения
    ///   - completion: Блок, который вызывается после применения всех изменений
    public func update(
        changes: (_ snapshot: inout DataSourceSnapshot) -> Void,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        var snapshot = snapshot()
        changes(&snapshot)
        apply(snapshot, animated: animated, completion: completion)
    }

    /// Возвращает данные, соответствующие текущему состоянию коллекции
    /// - Returns: Объект, содержащий слепок секций и ячеек в том порядке, в котором они отображаются
    public func snapshot() -> DataSourceSnapshot {
        let dataSource = DataSource(dataSource.snapshot(), sections: sections, items: items)
        return DataSourceSnapshot(dataSource: dataSource)
    }

    /// Обновляет данные в коллекции, вычисляет разницу между текущим и новым состояниями,
    /// опционально анимирует изменения
    /// - Parameters:
    ///   - snapshot: Объект, содержащий новые секции и ячейки в том порядке, в котором они отображаются
    ///   - animated: `true`, если нужно анимировать изменения
    ///   - completion: Блок, который вызывается после применения всех изменений
    public func apply(_ snapshot: DataSourceSnapshot, animated: Bool = true, completion: (() -> Void)? = nil) {
//        let paginationItems = updatePaginationCells(snapshot.dataSource)
        registerViewsIfNeeded(snapshot.dataSource)
        sections = snapshot.dataSource.sections
        items = snapshot.dataSource.items
        setUpdateDataHandlers()
        dataSource.apply(snapshot.dataSource.snapshot, animatingDifferences: animated) {
            self.updateSupplementaries(snapshot.dataSource.updatedSupplementaries)
//            self.scrollToPaginationCell(paginationItems, animated: animated)
            completion?()
        }
    }

    /// Очищает коллекцию без анимации
    /// - Parameter completion: Блок, который вызывается после применения всех изменений
    public func clear(completion: (() -> Void)? = nil) {
        reload(sections: [], completion: completion)
    }
}

// MARK: - Selection

extension CollectionManager {
    /// Возвращает список выбранных элементов, состоящих в секциях, удовлетворяющих заданным условиям
    /// - Parameters:
    ///   - sectionModel: Класс секции
    ///   - predicate: Условия, которым должна удовлетворять секция
    /// - Returns: Список выбранных элементов
    public func selectedItems<Section: SectionModel>(
        inSection: Section.Type,
        where predicate: ((Section) -> Bool)? = nil
    ) -> [AnyItem] {
        (collectionView.indexPathsForSelectedItems ?? []).compactMap {
            guard let section = section(at: $0) as? Section, predicate?(section) ?? true else {
                return nil
            }
            return item(at: $0)
        }
    }

    /// Выбирает элемент в коллекции
    ///
    /// Если элемент не найден в коллекции, то метод ничего не делает
    /// - Parameters:
    ///   - item: Элемент, который нужно выбрать
    ///   - animated: `true`, если нужно анимировать изменения
    ///   - scrollPosition: Определяет позицию, в которой должен располагаться элемент после завершения прокрутки
    public func select(item: AnyItem, animated: Bool = false, scrollPosition: UICollectionView.ScrollPosition = []) {
        guard let indexPath = dataSource.indexPath(for: item.id), items[item.id]?.isSelectable == true else {
            return
        }

        guard case .section = selection, let section = sections[item.id.sectionID] else {
            collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
            return
        }

        switch section.selectionMode {
        case .none:
            return
        case .single:
            collectionView.indexPathsForSelectedItems?
                .filter { $0 != indexPath && $0.section == indexPath.section }
                .forEach {
                    collectionView.deselectItem(at: $0, animated: false)
                }
        case .multi:
            break
        }

        collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }

    /// Выбирает заданные элементы в коллекции
    ///
    /// Если элемент отсутствует в коллекции, то он игнорируется
    /// - Parameter items: Список элементов, которые нужно выбрать
    public func select(items: [AnyItem]) {
        items.forEach { select(item: $0) }
    }

    /// Снимает выбор с элемента
    ///
    /// Если элемент не найден в коллекции, то метод ничего не делает
    /// - Parameters:
    ///   - item: Элемент, с которого нужно снять выбор
    ///   - animated: true, если нужно анимировать изменения
    public func deselect(item: AnyItem, animated: Bool = false) {
        guard let indexPath = dataSource.indexPath(for: item.id) else {
            return
        }

        collectionView.deselectItem(at: indexPath, animated: animated)
    }

    /// Снимает выбор с заданных элементов
    ///
    /// Если элемент отсутствует в коллекции, то он игнорируется
    /// - Parameter items: Список элементов, с которых нужно снять выбор
    public func deselect(items: [AnyItem]) {
        items.forEach { deselect(item: $0) }
    }
}

// MARK: - Scrolling

extension CollectionManager {
    /// Прокручивает содержимое коллекции до тех пор, пока не станет виден указанный элемент
    /// - Parameters:
    ///   - item: Элемент, который нужно показать
    ///   - position: Параметр, который указывает, где должен располагаться элемент по завершении прокрутки
    ///   - animated: Задайте `true`, чтобы анимировать прокрутку, или `false`, чтобы немедленно переместиться
    public func scrollTo(item: AnyItem, at position: UICollectionView.ScrollPosition = [], animated: Bool = true) {
        guard let indexPath = dataSource.indexPath(for: item.id) else {
            return
        }
        collectionView.scrollToItem(at: indexPath, at: position, animated: animated)
    }

    /// Прокручивает содержимое коллекции так, чтобы была видна определенная область
    ///
    /// Если область уже видна, то метод ничего не делает
    /// - Parameters:
    ///   - rect: Прямоугольник, определяющий видимую область.
    ///   Он должен находиться в координатном пространстве коллекции
    ///   - animated: Задайте `true`, чтобы анимировать прокрутку, или `false`, чтобы немедленно переместиться
    public func scrollTo(rect: CGRect, animated: Bool = true) {
        collectionView.scrollRectToVisible(rect, animated: animated)
    }

    /// Прокручивает содержимое коллекции до самого начала
    /// - Parameter animated: Задайте `true`, чтобы анимировать прокрутку, или `false`, чтобы немедленно переместиться
    public func scrollToTop(animated: Bool = true) {
        let rect = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 1)
        collectionView.scrollRectToVisible(rect, animated: animated)
    }
}

// MARK: - Layout

extension CollectionManager {
    /// Возвращает ячейку для указанного элемента
    /// - Parameter item: Элемент, для которого нужно получить ячейку
    /// - Returns: Ячейка, соответствующая указанному элементу.
    /// Метод вернёт `nil`, если ячейка не видна и не находится в кэше подготовленных ячеек
    public func cell(for item: AnyItem) -> UICollectionViewCell? {
        guard let indexPath = dataSource.indexPath(for: item.id) else {
            return nil
        }
        return collectionView.cellForItem(at: indexPath)
    }

    /// Получает информацию о компоновке указанного элемента
    /// - Parameter item: Элемент, компоновку которого нужно получить
    /// - Returns: Информация о компоновке или `nil`, если указанного элемента не существует
    public func layoutAttributes(for item: AnyItem) -> UICollectionViewLayoutAttributes? {
        guard let indexPath = dataSource.indexPath(for: item.id) else {
            return nil
        }
        return collectionView.layoutAttributesForItem(at: indexPath)
    }

    /// Возвращает элемент в указанной точке коллекции
    /// - Parameter point: Точка в системе координат коллекции
    /// - Returns: Элемент в указанной точке или `nil`, если он не был найден
    public func item(at point: CGPoint) -> AnyItem? {
        guard let indexPath = collectionView.indexPathForItem(at: point) else {
            return nil
        }
        return item(at: indexPath)
    }
}

// MARK: -

extension CollectionManager {
    /// Тип компоновки коллекции
    public enum Layout {
        /// UICollectionViewCompositionalLayout
        case compositional(_ configuration: UICollectionViewCompositionalLayoutConfiguration)
        /// UICollectionViewFlowLayout или его наследник
        case flow(_ layout: UICollectionViewFlowLayout, delegate: UICollectionViewDelegateFlowLayout?)
        /// UICollectionViewLayout или его наследник
        case custom(_ layout: UICollectionViewLayout)
    }

    /// Режим управления выделением ячеек в коллекции
    public enum Selection {
        /// Выбором ячеек управляет коллекция
        case collectionView(SelectionMode)
        /// Выбором ячеек управляет секция
        case section
    }
}


//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Объект, ограничивающий количество вызовов в заданный промежуток времени
public final class Throttler {
    /// Код, который должен быть выполнен
    public typealias Block = () -> Void

    /// Логическое значение, показывающее, что есть код, ожидающий выполнения
    public var isPending: Bool { workItem != nil }

    private let delay: TimeInterval
    private let queue = DispatchQueue.main
    private var workItem: DispatchWorkItem?
    private var block: Block?

    // MARK: Initialization

    /// Создаёт объект для ограничения количества вызовов в заданный промежуток времени
    /// - Parameter delay: Промежуток времени, используемый для ограничения количества вызовов
    public init(delay: TimeInterval = 0.5) {
        self.delay = delay
    }

    // MARK: Public

    /// Ограничивает количество вызовов заданного кода в установленный промежуток времени
    ///
    /// При первом вызове данного метода устанавливается задержка, по истечению которой будет выполнен заданный код.
    /// Если за это время метод будет вызван несколько раз, то выполнится код,
    /// который был передан в самый последний вызов
    /// - Note: В отличии от `debounce(_:)`, каждый повторный вызов метода не откладывает выполнение кода,
    /// а заменяет его. Но он будет выполнен, когда пройдёт установленный промежуток времени после первого вызова,
    /// независимо от количества вызовов метода `throttle(_:)`
    /// - Parameter block: Код, который должен быть выполнен
    public func throttle(_ block: @escaping Block) {
        self.block = block
        if workItem == nil {
            addWorkItem()
        }
    }

    /// Вызывает заданный код с задержкой
    ///
    /// Каждый новый вызов данного метода откладывает выполнение кода на установленный промежуток времени.
    /// По его истечению будет выполнен код из самого последнего вызова метода `debounce(_:)`
    /// - Parameter block: Код, который должен быть выполнен
    public func debounce(_ block: @escaping Block) {
        workItem?.cancel()
        self.block = block
        addWorkItem()
    }

    /// Отменяет выполнение кода
    ///
    /// Если нет кода, ожидающего выполнения, то метод ничего не делает
    public func cancel() {
        guard isPending else {
            return
        }

        workItem?.cancel()
        workItem = nil
        block = nil
    }

    // MARK: Private

    private func addWorkItem() {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else {
                return
            }

            let block = self.block
            self.workItem = nil
            self.block = nil
            block?()
        }
        self.workItem = workItem
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Задача, которая может быть отменена
public protocol CancellableTask {
    /// Свойство, показывающее, что задача была отменена
    var isCancelled: Bool { get }

    /// Отменить выполнение задачи
    func cancel()
}

// MARK: -

extension Task: CancellableTask {
    /// Добавить задачу в хранилище активных задач
    /// - Parameter storage: Хранилище активных задач
    /// - Returns: Объект, который отменяет задачу, когда удаляется из памяти
    @discardableResult
    public func store(in storage: CancellableTaskStorage) -> CancellableTaskToken {
        let token = CancellableTaskToken(self)
        token.addCancellation { [weak storage, weak token] in
            if let storage, let token {
                storage.remove(token)
            }
        }
        storage.append(token)
        return token
    }

    /// Начать отслеживание активности задачи
    /// - Parameters:
    ///   - monitor: Объект, отслеживающий активность задачи
    ///   - cancelPrevious: Отменить все ранее добавленные активные задачи
    /// - Returns: Объект, который отменяет задачу, когда удаляется из памяти
    @discardableResult
    public func store(in monitor: ActivityMonitor, cancelPrevious: Bool = false) -> CancellableTaskToken {
        let token = CancellableTaskToken(self)
        token.addCancellation { [weak monitor, weak token] in
            if let monitor, let token {
                monitor.remove(token)
            }
        }
        monitor.append(token, replace: cancelPrevious)
        return token
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Хранилище активных задач
public final class CancellableTaskStorage {
    private var tokens = [CancellableTaskToken]()

    // MARK: Public

    /// Отменить все задачи, находящиеся в хранилище
    public func cancelAll() {
        let cancellables = tokens
        tokens.removeAll()
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }

    // MARK: Internal

    func append(_ token: CancellableTaskToken) {
        tokens.append(token)
    }

    func remove(_ token: CancellableTaskToken) {
        tokens.removeAll { $0 === token }
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Объект, который отменяет задачу, когда удаляется из памяти
public final class CancellableTaskToken: CancellableTask {
    private var innerTask: Task<(), Never>!
    private var cancellations = [() -> Void]()
    private var isCompleted = false

    // MARK: Initialization

    init<Success, Failure>(_ task: Task<Success, Failure>) {
        innerTask = Task { [weak self] in
            await withTaskCancellationHandler(
                operation: {
                    _ = await task.result
                    if let self {
                        self.isCompleted = true
                        self.cancelAll()
                    }
                },
                onCancel: {
                    task.cancel()
                }
            )
        }
    }

    deinit {
        cancel()
    }

    // MARK: CancellableTask

    public var isCancelled: Bool {
        innerTask.isCancelled
    }

    public func cancel() {
        if !isCompleted, !innerTask.isCancelled {
            innerTask.cancel()
        }
        cancelAll()
    }

    // MARK: Internal

    func addCancellation(_ cancellation: @escaping () -> Void) {
        cancellations.append(cancellation)
    }

    // MARK: Private

    private func cancelAll() {
        guard !cancellations.isEmpty else {
            return
        }

        cancellations.forEach { $0() }
        cancellations.removeAll()
    }
}

// MARK: -

extension CancellableTaskToken {
    /// Добавить задачу в хранилище активных задач
    /// - Parameter storage: Хранилище активных задач
    /// - Returns: Объект, который отменяет задачу, когда удаляется из памяти
    @discardableResult
    public func store(in storage: CancellableTaskStorage) -> Self {
        addCancellation { [weak storage, weak token = self] in
            if let storage, let token {
                storage.remove(token)
            }
        }
        storage.append(self)
        return self
    }

    /// Начать отслеживание активности задачи
    /// - Parameters:
    ///   - monitor: Объект, отслеживающий активность задачи
    ///   - cancelPrevious: Отменить все ранее добавленные активные задачи
    /// - Returns: Объект, который отменяет задачу, когда удаляется из памяти
    @discardableResult
    public func store(in monitor: ActivityMonitor, cancelPrevious: Bool = false) -> Self {
        addCancellation { [weak monitor, weak token = self] in
            if let monitor, let token {
                monitor.remove(token)
            }
        }
        monitor.append(self, replace: cancelPrevious)
        return self
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

/// Следит за активностью задач. Информирует, когда добавлена первая задача или удалена последняя
public final class ActivityMonitor {
    /// Показывает, есть ли активные задачи
    public private(set) var isActive = false {
        didSet {
            if isActive != oldValue, handler != nil {
                DispatchQueue.main.async { [weak self] in
                    if let self, let handler = self.handler {
                        handler(self.isActive)
                    }
                }
            }
        }
    }

    private var handler: ((Bool) -> Void)?
    private var count = 0 {
        didSet {
            isActive = count > 0
        }
    }
    private var tokens = [CancellableTaskToken]()

    // MARK: Initialization

    /// Создаёт объект, который следит за активностью задач
    public init() {}

    // MARK: Public

    /// Установить обработчик, который будет вызван при изменении активности задач
    /// - Parameter handler: Замыкание вызывается, когда добавляется первая задача или удаляется последняя
    public func addAction(handler: @escaping (_ isActive: Bool) -> Void) {
        self.handler = handler
    }

    // MARK: Internal

    func append(_ token: CancellableTaskToken, replace: Bool) {
        count += 1
        guard replace else {
            tokens.append(token)
            return
        }

        let cancellables = tokens
        tokens = [token]
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }

    func remove(_ token: CancellableTaskToken) {
        count = max(count - 1, 0)
        tokens.removeAll { $0 === token }
    }
}

//
//  petrovich
//  Copyright © 2022 Heads and Hands. All rights reserved.
//

import CoreLocation

/// Объект для работы с местоположением пользователя
public final class LocationManager: NSObject, CLLocationManagerDelegate {
    /// Причина, по которой необходимо точное определение местоположения
    public enum FullAccuraсyPurpose: String {
        /// Точное местоположение пользователя
        case user = "UserLocationUsageDescription"
    }

    // MARK: Properties

    /// Показывает, включены ли службы геолокации на устройстве
    public var locationServicesEnabled: Bool {
        CLLocationManager.locationServicesEnabled()
    }

    /// Текущий статус разрешения на определение местоположения
    public var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    /// Уровень точности, с которым приложение определяет местоположение
    public var accuracyAuthorization: CLAccuracyAuthorization {
        manager.accuracyAuthorization
    }

    /// Самое последнее местоположение
    ///
    /// Это свойство вернёт `nil`, если нет разрешения на доступ к геолокации или ещё не были получены координаты
    public var lastLocation: CLLocation? {
        manager.location
    }

    private let manager: CLLocationManager
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>? {
        willSet {
            if newValue != nil {
                authorizationContinuation?.resume(returning: .notDetermined)
            }
        }
    }
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>? {
        willSet {
            if newValue != nil {
                locationContinuation?.resume(returning: nil)
            }
        }
    }
    private var streamContinuation: AsyncStream<CLLocation>.Continuation?

    // MARK: Initialization

    override public init() {
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 50

        super.init()

        manager.delegate = self
    }

    // MARK: Authorization

    /// Запрашивает разрешение на определение местоположения.
    /// Если задан параметр `fullAccuracy`, а пользователь не дал доступ к точному местоположению,
    /// то будет запрошено дополнительное разрешение
    /// - Parameter fullAccuracy: Причина, по которой необходимо точное определение местоположения
    /// - Returns: Статус разрешения на определение местоположения
    @discardableResult
    public func requestAuthorization(fullAccuracy: FullAccuraсyPurpose? = nil) async -> CLAuthorizationStatus {
        let status = await withCheckedContinuation { continuation in
            guard authorizationStatus == .notDetermined else {
                continuation.resume(returning: authorizationStatus)
                return
            }

            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }

        guard status == .authorizedWhenInUse, accuracyAuthorization == .reducedAccuracy, let fullAccuracy else {
            return status
        }

        try? await manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: fullAccuracy.rawValue)
        return status
    }

    /// Запрашивает разрешение на временное использование точного местоположения
    /// - Parameter purpose: Причина, по которой необходимо точное определение местоположения
    public func requestTemporaryFullAccuracyAuthorization(purpose: FullAccuraсyPurpose) async {
        guard accuracyAuthorization == .reducedAccuracy else {
            return
        }

        try? await manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purpose.rawValue)
    }

    // MARK: Location

    /// Получает самое последнее местоположение.
    /// Будет запрошено разрешение на доступ к геолокации, если это не было сделано раньше
    ///
    /// Метод вернёт `nil`, если нет разрешения на доступ к геолокации или ещё не были получены координаты
    ///
    /// - Note: Если необходимо, чтобы пользователь дал доступ к точному местоположению,
    /// то используйте дополнительно методы
    /// ```
    /// func requestAuthorization(fullAccuracy: FullAccuraсyPurpose? = nil) async -> CLAuthorizationStatus
    /// ```
    /// или
    /// ```
    /// func requestTemporaryFullAccuracyAuthorization(purpose: FullAccuraсyPurpose) async
    /// ```
    /// - Returns: Самое последнее местоположение
    public func requestLastLocation() async -> CLLocation? {
        guard locationServicesEnabled else {
            return nil
        }

        if authorizationStatus == .notDetermined {
            await requestAuthorization()
            if Task.isCancelled {
                return nil
            }
        }

        return lastLocation
    }

    /// Однократно получает текущее местоположение.
    /// Будет запрошено разрешение на доступ к геолокации, если это не было сделано раньше
    ///
    /// Если не удалось получить местоположение, то возвращается `nil`
    ///
    /// - Note: Если необходимо, чтобы пользователь дал доступ к точному местоположению,
    /// то используйте дополнительно методы
    /// ```
    /// func requestAuthorization(fullAccuracy: FullAccuraсyPurpose? = nil) async -> CLAuthorizationStatus
    /// ```
    /// или
    /// ```
    /// func requestTemporaryFullAccuracyAuthorization(purpose: FullAccuraсyPurpose) async
    /// ```
    /// - Returns: Текущее местоположение
    public func requestLocation() async -> CLLocation? {
        guard locationServicesEnabled else {
            return nil
        }

        if authorizationStatus == .notDetermined {
            await requestAuthorization()
            if Task.isCancelled {
                return nil
            }
        }

        guard authorizationStatus == .authorizedWhenInUse else {
            return lastLocation
        }

        return await withTaskCancellationHandler(
            operation: {
                await withCheckedContinuation { continuation in
                    locationContinuation = continuation
                    manager.requestLocation()
                }
            },
            onCancel: {
                locationContinuation?.resume(returning: nil)
                locationContinuation = nil
            }
        )
    }

    /// Начать отслеживание за изменением текущего местоположения
    ///
    /// Метод сразу возвращает асинхронную последовательность текущих координат.
    ///
    /// Когда менеджер получает событие об изменении местоположения, он генерирует новое значение в последовательности.
    /// Для извлечения координат можно использовать цикл `for-in`:
    /// ```
    /// for await location in locationManager.startUpdatingLocation() {
    ///     // Обработать новые координаты
    /// }
    /// ```
    /// - Returns: Асинхронная последовательность текущих координат
    public func startUpdatingLocation() -> AsyncStream<CLLocation> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            streamContinuation = continuation
            continuation.onTermination = { @Sendable _ in
                self.stopUpdatingLocation()
            }
            manager.startUpdatingLocation()
        }
    }

    /// Остановить отслеживание изменений текущего местоположения
    ///
    /// Вызов этого метода прекращает генерацию новых значений и завершает последовательность,
    /// полученную в методе `startUpdatingLocation()`
    public func stopUpdatingLocation() {
        streamContinuation?.finish()
        streamContinuation = nil
        manager.stopUpdatingLocation()
    }

    // MARK: CLLocationManagerDelegate

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status != .notDetermined, let continuation = authorizationContinuation {
            continuation.resume(returning: status)
            authorizationContinuation = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        if let continuation = locationContinuation {
            continuation.resume(returning: location)
            locationContinuation = nil
        }
        if let streamContinuation {
            streamContinuation.yield(location)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let continuation = locationContinuation {
            continuation.resume(returning: nil)
            locationContinuation = nil
        }
        if streamContinuation != nil {
            stopUpdatingLocation()
        }
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

public struct Coordinates: Codable {
    let longitude: Double
    let latitude: Double

    var isInitial: Bool {
        longitude == 0.0 && latitude == 0.0
    }

    init(longitude: Double = 0, latitude: Double = 0) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

import UIKit
import YandexMapsMobile

final class AddressSuggestionVM: ItemModel {
    typealias Cell = AddressSuggestionCell

    private let suggestItem: YMKSuggestItem?
    let title: String

    var subtitle: String? {
        suggestItem?.subtitle?.text
    }
    var action: YMKSuggestItemAction? {
        suggestItem?.action
    }
    var coordinates: Coordinates {
        Coordinates(
            longitude: suggestItem?.center?.longitude ?? 0,
            latitude: suggestItem?.center?.latitude ?? 0
        )
    }

    // MARK: ItemModel

    let id: SuggestionType
    let didSelect: ((Item<AddressSuggestionVM>) -> Void)?

    // MARK: Initialization

    init(title: String, suggestItem: YMKSuggestItem?, type: SuggestionType, didSelect: @escaping (Item<AddressSuggestionVM>) -> Void) {
        self.title = title
        self.suggestItem = suggestItem

        id = type
        self.didSelect = didSelect
    }
}

extension AddressSuggestionVM {
    enum SuggestionType: Hashable {
        case history
        case search
    }
}


//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class AddressSuggestioSection: SectionModel {
    // MARK: SectionModel

    let id = UUID()

    func layout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
        let item = NSCollectionLayoutItem(layoutSize: size)
        return NSCollectionLayoutSection(group: .horizontal(layoutSize: size, subitems: [item]))
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class AddressSuggestionCell: UICollectionViewCell, CollectionCell {
    static let reuseIdentifier = "AddressSuggestionCell"

    private var imageView = ImageView().ui
        .image(UIImage())
        .setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        .setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        .forAutoLayout()
    private var titleLabel = Label().ui
        .textStyle(.textBody)
        .textColor(.black)
        .numberOfLines(0)
        .make()
    private let descriptionLabel = Label().ui
        .textStyle(.subheader)
        .textColor(.gray)
        .numberOfLines(0)
        .make()
    private let highlightedView = UIView().ui
        .backgroundColor(.lightText)
        .make()

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

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)

        if state.isHighlighted {
            highlightedView.alpha = 1
        } else {
            highlightedView.alpha = 0
        }
    }

    // MARK: Configuration

    private func configure() {
        backgroundConfiguration = .clear()
        backgroundConfiguration?.backgroundColor = .white

        highlightedView.ui
            .frame(contentView.bounds)
            .autoresizingMask([.flexibleWidth, .flexibleHeight])

        titleLabel.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
        let labelsStackView = UIStackView().ui
            .axis(.vertical)
            .spacing(2)
            .addArrangedSubviews([titleLabel, descriptionLabel])
            .make()

        imageView.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        let stackView = UIStackView().ui
            .axis(.horizontal)
            .spacing(12)
            .addArrangedSubviews([imageView, labelsStackView])
            .forAutoLayout()
        let separator = UIView().ui
            .backgroundColor(.lightGray)
            .forAutoLayout()
        contentView.ui.addSubviews([stackView, separator, highlightedView])

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            contentView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separator.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 13),
            contentView.trailingAnchor.constraint(equalTo: separator.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: separator.bottomAnchor)
        ])
    }

    // MARK: CollectionCell

    func update(with model: AddressSuggestionVM) {
        titleLabel.text = model.title
        descriptionLabel.text = model.subtitle
        descriptionLabel.isHidden = model.subtitle.isEmpty
        imageView.isHidden = model.id == .search
    }
}

//
//  petrovich
//  Copyright © 2022 Heads and Hands. All rights reserved.
//

import Foundation

extension Optional where Wrapped: Collection {
    /// Логическое значение, показывающее, что коллекция пустая. Если значение отсутствует, то возвращается `true`
    public var isEmpty: Bool {
        switch self {
        case .none:
            return true
        case let .some(wrapped):
            return wrapped.isEmpty
        }
    }

    /// Логическое значение, показывающее, что коллекция не пустая. Если значение отсутствует, то возвращается `false`
    public var isNotEmpty: Bool {
        !isEmpty
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

public final class DetailedAddressView: UIView {
    public let collectionManager = CollectionManager()
    public let addressField = TextField(style: .plain).ui
        .borderColor(A.Colors.Primary.blue.color)
        .textColor(.black)
        .placeholder("Адрес мероприятия")
        .forAutoLayout()
//    public let deliveryButton = Button(style: .bordered).ui
//        .title("Выбрать адрес")
//        .forAutoLayout()
    public let detailsView = UIView().ui
        .forAutoLayout()
    public lazy var collectionView = collectionManager.collectionView.ui
        .forAutoLayout()
    public var emptyView = UIView().ui
        .forAutoLayout()
    private var emptyLabel = Label().ui
        .text("Подходящих адресов не найдено")
        .textStyle(.title2)
        .textAlignment(.center)
        .textColor(.black)
        .numberOfLines(0)
        .lineBreakStrategy([])
        .forAutoLayout()
    private var emptyDetails = Label().ui
        .text("Не найдены адреса, попробуйте изменить запрос")
        .textStyle(.textBody)
        .textAlignment(.center)
        .textColor(.black)
        .numberOfLines(0)
        .lineBreakStrategy([])
        .forAutoLayout()

    // MARK: Properties

    private var model: DetailedAddressVM?

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Configuration

    private func configure() {
        backgroundColor = .clear

        let gripView = UIView().ui
            .backgroundColor(.gray)
            .cornerRadius(2)
            .clipsToBounds(true)
            .forAutoLayout()
        let gripBackground = UIView().ui
            .backgroundColor(.white)
            .addSubview(gripView)
            .forAutoLayout()

        collectionView.alpha = 0
        emptyView.isHidden = true

//        detailsView.ui.addSubviews([deliveryButton])
        emptyView.ui.addSubviews([emptyLabel, emptyDetails])

        let view = UIView().configurator
            .set(\.backgroundColor, to: .white)
            .set(\.cornerRadius, to: 16)
            .set(\.cornerCurve, to: .circular)
            .set(\.maskedCorners, to: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
            .set(\.clipsToBounds, to: true)
            .addSubviews([gripBackground, addressField, detailsView, collectionView, emptyView])
            .forAutoLayout()
        let shadowView = ShadowView(style: .sheet).ui
            .addSubview(view)
            .forAutoLayout()

        addSubview(shadowView)

        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowView.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),

            gripBackground.heightAnchor.constraint(equalToConstant: 20),
            gripBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            gripBackground.topAnchor.constraint(equalTo: topAnchor),
            trailingAnchor.constraint(equalTo: gripBackground.trailingAnchor),

            gripView.widthAnchor.constraint(equalToConstant: 33),
            gripView.heightAnchor.constraint(equalToConstant: 4),
            gripView.centerXAnchor.constraint(equalTo: gripBackground.centerXAnchor),
            gripView.topAnchor.constraint(equalTo: gripBackground.topAnchor, constant: 8),

            addressField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            addressField.heightAnchor.constraint(equalToConstant: 70),
            addressField.topAnchor.constraint(equalTo: gripBackground.bottomAnchor, constant: 8),
            trailingAnchor.constraint(equalTo: addressField.trailingAnchor, constant: 16),

//            deliveryButton.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor),
//            deliveryButton.topAnchor.constraint(equalTo: detailsView.topAnchor),
//            deliveryButton.heightAnchor.constraint(equalToConstant: 50),
//            detailsView.trailingAnchor.constraint(equalTo: deliveryButton.trailingAnchor),
//            detailsView.bottomAnchor.constraint(equalTo: deliveryButton.bottomAnchor),

            detailsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            detailsView.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 28),
            trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: 16),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: 16),

            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            collectionView.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 8),
            trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: 16),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),

            emptyView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emptyView.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 8),
            trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: 16),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor, constant: 16)
        ])

        collectionView.constraints.forEach {
            $0.priority = UILayoutPriority.defaultLow
        }

        emptyView.constraints.forEach {
            $0.priority = UILayoutPriority.defaultLow
        }

        NSLayoutConstraint.activate([
            emptyLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: emptyView.centerYAnchor),
            emptyView.trailingAnchor.constraint(equalTo: emptyLabel.trailingAnchor),

            emptyDetails.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor),
            emptyDetails.topAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: 8),
            emptyView.trailingAnchor.constraint(equalTo: emptyDetails.trailingAnchor)
        ])
    }

    // MARK: Internal

    func update(with model: DetailedAddressVM) {
        self.model = model

        layoutIfNeeded()
    }

    // MARK: Private
}


//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation
import UIKit

class DetailedAddressVM {
    let street: String
    let driveway: String
    let apartment: String
    let maxHeight: CGFloat

    let updateHeightVisibleMap: ((CGFloat) -> Void)?

    init(
        street: String,
        driveway: String,
        apartment: String,
        maxHeight: CGFloat,
        updateHeightVisibleMap: @escaping (CGFloat) -> Void
    ) {
        self.street = street
        self.driveway = driveway
        self.apartment = apartment
        self.maxHeight = maxHeight
        self.updateHeightVisibleMap = updateHeightVisibleMap
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

extension UIView {
    /// Область представления, перекрытая клавиатурой
    ///
    /// Когда клавиатура скрыта, то `keyboardGuide.top` == `safeAreaLayoutGuide.bottom`
    public var keyboardGuide: UILayoutGuide {
        if let guide = layoutGuides.first(where: { $0.identifier == ViewKeyboardLayoutGuide.identifier }) {
            return guide
        }

        let guide = ViewKeyboardLayoutGuide()
        addLayoutGuide(guide)
        guide.configure()
        return guide
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class ViewKeyboardLayoutGuide: UILayoutGuide {
    static let identifier = "ViewKeyboardLayoutGuide"

    var didChange: (() -> Void)?

    private var topConstraint: NSLayoutConstraint?

    // MARK: Initialization

    override init() {
        super.init()
        identifier = Self.identifier
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Configuration

    func configure() {
        guard let owningView else {
            return
        }

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: owningView.leadingAnchor),
            owningView.safeAreaLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            owningView.trailingAnchor.constraint(equalTo: trailingAnchor),
            owningView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if let window = owningView.window {
            bind(to: window)
        }
    }

    func bind(to window: UIWindow) {
        if topConstraint?.isActive == true {
            return
        }

        let constraint = topAnchor.constraint(equalTo: window.windowKeyboardGuide.topAnchor)
        constraint.priority = .required - 1
        constraint.isActive = true
        topConstraint = constraint
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

extension UIWindow {
    /// Начать отслеживать клавиатуру
    ///
    /// Добавляет к окну `WindowKeyboardLayoutGuide`, который отслеживает клавиатуру
    public func handleKeyboard() {
        _ = windowKeyboardGuide
    }

    var windowKeyboardGuide: UILayoutGuide {
        if let guide = layoutGuides.first(where: { $0.identifier == WindowKeyboardLayoutGuide.identifier }) {
            return guide
        }

        let guide = WindowKeyboardLayoutGuide()
        addLayoutGuide(guide)
        guide.configure()
        return guide
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class WindowKeyboardLayoutGuide: UILayoutGuide {
    static let identifier = "WindowKeyboardLayoutGuide"

    private let keyboardManager = KeyboardManager()
    private var heightConstraint: NSLayoutConstraint!

    // MARK: Initialization

    override init() {
        super.init()
        identifier = Self.identifier
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Configuration

    func configure() {
        guard let owningView else {
            return
        }

        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: owningView.leadingAnchor),
            owningView.trailingAnchor.constraint(equalTo: trailingAnchor),
            owningView.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightConstraint
        ])

        keyboardManager.observe { [weak self] info in
            self?.handleKeyboard(info)
        }
    }

    // MARK: Private

    private func handleKeyboard(_ info: KeyboardManager.KeyboardInfo) {
        guard info.isLocal else {
            return
        }

        heightConstraint.constant = info.height

        guard
            let guides = owningView?.constraints.compactMap({ $0.firstItem as? ViewKeyboardLayoutGuide }),
            !guides.isEmpty
        else {
            return
        }

        let animator = UIViewPropertyAnimator(duration: info.animationDuration, curve: info.animationCurve) {
            guides.forEach {
                $0.didChange?()
                $0.owningView?.layoutIfNeeded()
            }
        }
        animator.startAnimation()
    }
}

//
//  petrovich
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

final class KeyboardManager {
    private var handler: ((KeyboardInfo) -> Void)?

    // MARK: Initialization

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handle(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handle(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handle(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Internal

    func observe(handler: @escaping (_ info: KeyboardInfo) -> Void) {
        self.handler = handler
    }

    // MARK: Private

    @objc
    private func handle(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            var frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
            let animationCurve = UIView.AnimationCurve(rawValue: curve),
            let isLocal = userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? Bool
        else {
            return
        }

        var keyboardHeight = frame.height
        if let window = keyWindow() {
            // Если открепить клавиатуру на iPad, то её положение будет нулевым
            if frame != .zero {
                frame = window.convert(frame, from: window.screen.coordinateSpace)
                if window.bounds.height > frame.maxY {
                    // Когда клавиатура открепляется на iPad, то до первого перемещения
                    // может вернуться реальное положение клавиатуры, а не ноль.
                    //
                    // Сравнение идёт с размером окна, а не экрана, потому что в режиме Slide Over,
                    // когда клавиатура закреплена, её frame.maxY, полученный от уведомления, меньше высоты экрана
                    frame = .zero
                }

                keyboardHeight = window.bounds.intersection(frame).height
            }
        }

        let info = KeyboardInfo(
            height: keyboardHeight,
            animationCurve: animationCurve,
            animationDuration: duration,
            isLocal: isLocal
        )
        handler?(info)
    }

    private func keyWindow() -> UIWindow? {
        UIApplication.shared
            .connectedScenes
            .lazy
            .compactMap { $0 as? UIWindowScene }
            .compactMap(\.keyWindow)
            .first
    }
}

// MARK: -

extension KeyboardManager {
    struct KeyboardInfo {
        let height: CGFloat
        let animationCurve: UIView.AnimationCurve
        let animationDuration: TimeInterval
        let isLocal: Bool
    }
}

extension UITextField: ClosureActionableControl {}

extension ClosureActionableControl where Self: UITextField {
    /// Добавляет действие для указанного события
    /// - Parameters:
    ///   - controlEvents: Событие, для которого будет добавлено действие
    ///   - handler: Замыкание принимает текстовое поле и вызывается, когда оно отправляет указанное событие
    public func addAction(for controlEvents: UIControl.Event = .editingChanged, handler: @escaping (Self) -> Void) {
        let action = UIAction { action in
            if let sender = action.sender as? Self {
                handler(sender)
            }
        }
        addAction(action, for: controlEvents)
    }
}

//
//  petrovich
//  Copyright © 2022 Heads and Hands. All rights reserved.
//

import UIKit

/// Протокол описывает элемент управления, которое поддерживает действия на основе замыканий
public protocol ClosureActionableControl {}
