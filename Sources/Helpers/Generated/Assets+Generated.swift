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
internal enum Asset {
  internal enum Colors {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal static let end = ColorAsset(name: "end")
    internal static let endBackground = ColorAsset(name: "endBackground")
    internal static let pause = ColorAsset(name: "pause")
    internal static let pauseBackground = ColorAsset(name: "pauseBackground")
    internal static let positiveButton = ColorAsset(name: "positiveButton")
    internal static let highHeartRate = ColorAsset(name: "highHeartRate")
    internal static let idleHeartRate = ColorAsset(name: "idleHeartRate")
    internal static let lowHeartRate = ColorAsset(name: "lowHeartRate")
    internal static let mediumHeartRate = ColorAsset(name: "mediumHeartRate")
    internal static let veryHighHeartRate = ColorAsset(name: "veryHighHeartRate")
    internal static let veryLowHeartRate = ColorAsset(name: "veryLowHeartRate")
    internal static let energyBurned = ColorAsset(name: "energyBurned")
    internal static let heartRate = ColorAsset(name: "heartRate")
    internal static let totalTime = ColorAsset(name: "totalTime")
  }
  internal enum Images {
    internal static let heartbeat0 = ImageAsset(name: "heartbeat_0")
    internal static let heartbeat1 = ImageAsset(name: "heartbeat_1")
    internal static let heartbeat2 = ImageAsset(name: "heartbeat_2")
    internal static let heartbeat3 = ImageAsset(name: "heartbeat_3")
    internal static let heartbeat4 = ImageAsset(name: "heartbeat_4")
    internal static let heartbeat5 = ImageAsset(name: "heartbeat_5")
    internal static let heartbeat6 = ImageAsset(name: "heartbeat_6")
    internal static let heartbeat7 = ImageAsset(name: "heartbeat_7")
    internal static let heartbeat8 = ImageAsset(name: "heartbeat_8")
    internal static let heartbeatLoading0 = ImageAsset(name: "heartbeat_loading_0")
    internal static let heartbeatLoading1 = ImageAsset(name: "heartbeat_loading_1")
    internal static let heartbeatLoading10 = ImageAsset(name: "heartbeat_loading_10")
    internal static let heartbeatLoading11 = ImageAsset(name: "heartbeat_loading_11")
    internal static let heartbeatLoading12 = ImageAsset(name: "heartbeat_loading_12")
    internal static let heartbeatLoading13 = ImageAsset(name: "heartbeat_loading_13")
    internal static let heartbeatLoading14 = ImageAsset(name: "heartbeat_loading_14")
    internal static let heartbeatLoading15 = ImageAsset(name: "heartbeat_loading_15")
    internal static let heartbeatLoading16 = ImageAsset(name: "heartbeat_loading_16")
    internal static let heartbeatLoading17 = ImageAsset(name: "heartbeat_loading_17")
    internal static let heartbeatLoading18 = ImageAsset(name: "heartbeat_loading_18")
    internal static let heartbeatLoading19 = ImageAsset(name: "heartbeat_loading_19")
    internal static let heartbeatLoading2 = ImageAsset(name: "heartbeat_loading_2")
    internal static let heartbeatLoading20 = ImageAsset(name: "heartbeat_loading_20")
    internal static let heartbeatLoading21 = ImageAsset(name: "heartbeat_loading_21")
    internal static let heartbeatLoading22 = ImageAsset(name: "heartbeat_loading_22")
    internal static let heartbeatLoading23 = ImageAsset(name: "heartbeat_loading_23")
    internal static let heartbeatLoading24 = ImageAsset(name: "heartbeat_loading_24")
    internal static let heartbeatLoading25 = ImageAsset(name: "heartbeat_loading_25")
    internal static let heartbeatLoading26 = ImageAsset(name: "heartbeat_loading_26")
    internal static let heartbeatLoading27 = ImageAsset(name: "heartbeat_loading_27")
    internal static let heartbeatLoading28 = ImageAsset(name: "heartbeat_loading_28")
    internal static let heartbeatLoading29 = ImageAsset(name: "heartbeat_loading_29")
    internal static let heartbeatLoading3 = ImageAsset(name: "heartbeat_loading_3")
    internal static let heartbeatLoading30 = ImageAsset(name: "heartbeat_loading_30")
    internal static let heartbeatLoading31 = ImageAsset(name: "heartbeat_loading_31")
    internal static let heartbeatLoading32 = ImageAsset(name: "heartbeat_loading_32")
    internal static let heartbeatLoading33 = ImageAsset(name: "heartbeat_loading_33")
    internal static let heartbeatLoading34 = ImageAsset(name: "heartbeat_loading_34")
    internal static let heartbeatLoading35 = ImageAsset(name: "heartbeat_loading_35")
    internal static let heartbeatLoading36 = ImageAsset(name: "heartbeat_loading_36")
    internal static let heartbeatLoading37 = ImageAsset(name: "heartbeat_loading_37")
    internal static let heartbeatLoading38 = ImageAsset(name: "heartbeat_loading_38")
    internal static let heartbeatLoading39 = ImageAsset(name: "heartbeat_loading_39")
    internal static let heartbeatLoading4 = ImageAsset(name: "heartbeat_loading_4")
    internal static let heartbeatLoading40 = ImageAsset(name: "heartbeat_loading_40")
    internal static let heartbeatLoading41 = ImageAsset(name: "heartbeat_loading_41")
    internal static let heartbeatLoading42 = ImageAsset(name: "heartbeat_loading_42")
    internal static let heartbeatLoading43 = ImageAsset(name: "heartbeat_loading_43")
    internal static let heartbeatLoading44 = ImageAsset(name: "heartbeat_loading_44")
    internal static let heartbeatLoading45 = ImageAsset(name: "heartbeat_loading_45")
    internal static let heartbeatLoading46 = ImageAsset(name: "heartbeat_loading_46")
    internal static let heartbeatLoading47 = ImageAsset(name: "heartbeat_loading_47")
    internal static let heartbeatLoading48 = ImageAsset(name: "heartbeat_loading_48")
    internal static let heartbeatLoading49 = ImageAsset(name: "heartbeat_loading_49")
    internal static let heartbeatLoading5 = ImageAsset(name: "heartbeat_loading_5")
    internal static let heartbeatLoading50 = ImageAsset(name: "heartbeat_loading_50")
    internal static let heartbeatLoading51 = ImageAsset(name: "heartbeat_loading_51")
    internal static let heartbeatLoading52 = ImageAsset(name: "heartbeat_loading_52")
    internal static let heartbeatLoading53 = ImageAsset(name: "heartbeat_loading_53")
    internal static let heartbeatLoading54 = ImageAsset(name: "heartbeat_loading_54")
    internal static let heartbeatLoading55 = ImageAsset(name: "heartbeat_loading_55")
    internal static let heartbeatLoading56 = ImageAsset(name: "heartbeat_loading_56")
    internal static let heartbeatLoading57 = ImageAsset(name: "heartbeat_loading_57")
    internal static let heartbeatLoading58 = ImageAsset(name: "heartbeat_loading_58")
    internal static let heartbeatLoading59 = ImageAsset(name: "heartbeat_loading_59")
    internal static let heartbeatLoading6 = ImageAsset(name: "heartbeat_loading_6")
    internal static let heartbeatLoading60 = ImageAsset(name: "heartbeat_loading_60")
    internal static let heartbeatLoading7 = ImageAsset(name: "heartbeat_loading_7")
    internal static let heartbeatLoading8 = ImageAsset(name: "heartbeat_loading_8")
    internal static let heartbeatLoading9 = ImageAsset(name: "heartbeat_loading_9")
    internal static let welcome = ImageAsset(name: "welcome")
    internal static let workoutButtonIcon = ImageAsset(name: "workout_button_icon")
    internal static let workoutIcon = ImageAsset(name: "workout_icon")
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
