// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum A {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal enum Colors {
    internal enum Background {
      internal static let background = ColorAsset(name: "Colors/Background/background")
      internal static let placeholder = ColorAsset(name: "Colors/Background/placeholder")
    }
    internal enum Grayscale {
      internal static let black = ColorAsset(name: "Colors/Grayscale/black")
      internal static let lightGray = ColorAsset(name: "Colors/Grayscale/lightGray")
      internal static let midGray = ColorAsset(name: "Colors/Grayscale/midGray")
    }
    internal enum Primary {
      internal static let blue = ColorAsset(name: "Colors/Primary/blue")
      internal static let red = ColorAsset(name: "Colors/Primary/red")
    }
    internal static let white = ColorAsset(name: "Colors/white")
  }
  internal enum Images {
    internal enum Catalog {
      internal static let imagePlaceholder = ImageAsset(name: "Images/Catalog/ImagePlaceholder")
      internal static let likeOff = ImageAsset(name: "Images/Catalog/LikeOff")
      internal static let likeOn = ImageAsset(name: "Images/Catalog/LikeOn")
      internal static let listFilter = ImageAsset(name: "Images/Catalog/ListFilter")
      internal static let mapIcon = ImageAsset(name: "Images/Catalog/MapIcon")
      internal static let mapPoint = ImageAsset(name: "Images/Catalog/MapPoint")
      internal static let mappingMode = ImageAsset(name: "Images/Catalog/MappingMode")
      internal static let menu = ImageAsset(name: "Images/Catalog/Menu")
      internal enum Points {
        internal static let art = ImageAsset(name: "Images/Catalog/Points/art")
        internal static let education = ImageAsset(name: "Images/Catalog/Points/education")
        internal static let history = ImageAsset(name: "Images/Catalog/Points/history")
        internal static let music = ImageAsset(name: "Images/Catalog/Points/music")
        internal static let party = ImageAsset(name: "Images/Catalog/Points/party")
        internal static let sport = ImageAsset(name: "Images/Catalog/Points/sport")
        internal static let ticket = ImageAsset(name: "Images/Catalog/Points/ticket")
      }
      internal static let rate = ImageAsset(name: "Images/Catalog/Rate")
      internal static let scales = ImageAsset(name: "Images/Catalog/Scales")
      internal static let scalesOff = ImageAsset(name: "Images/Catalog/ScalesOff")
      internal static let scalesOn = ImageAsset(name: "Images/Catalog/ScalesOn")
      internal static let shoppingCart = ImageAsset(name: "Images/Catalog/ShoppingCart")
      internal static let shoppingCartAdded = ImageAsset(name: "Images/Catalog/ShoppingCartAdded")
      internal static let testImage = ImageAsset(name: "Images/Catalog/TestImage")
      internal static let testSearch = ImageAsset(name: "Images/Catalog/TestSearch")
    }
    internal static let everyEventLogo = ImageAsset(name: "Images/EveryEventLogo")
    internal enum Menu {
      internal static let create = ImageAsset(name: "Images/Menu/Create")
      internal static let events = ImageAsset(name: "Images/Menu/Events")
      internal static let logout = ImageAsset(name: "Images/Menu/Logout")
      internal static let myEvents = ImageAsset(name: "Images/Menu/MyEvents")
      internal static let profile = ImageAsset(name: "Images/Menu/Profile")
      internal static let settings = ImageAsset(name: "Images/Menu/Settings")
    }
    internal enum Profile {
      internal static let photo = ImageAsset(name: "Images/Profile/Photo")
    }
    internal enum SearchComponent {
      internal static let clearField = ImageAsset(name: "Images/SearchComponent/ClearField")
      internal static let scanCode = ImageAsset(name: "Images/SearchComponent/ScanCode")
      internal static let search = ImageAsset(name: "Images/SearchComponent/Search")
      internal static let searchByPhoto = ImageAsset(name: "Images/SearchComponent/SearchByPhoto")
    }
    internal enum SocialMedia {
      internal static let apple = ImageAsset(name: "Images/SocialMedia/Apple")
      internal static let facebook = ImageAsset(name: "Images/SocialMedia/Facebook")
      internal static let odnoklassniki = ImageAsset(name: "Images/SocialMedia/Odnoklassniki")
      internal static let vk = ImageAsset(name: "Images/SocialMedia/VK")
    }
    internal enum System {
      internal static let backButton = ImageAsset(name: "Images/System/BackButton")
      internal static let loading = ImageAsset(name: "Images/System/Loading")
    }
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
