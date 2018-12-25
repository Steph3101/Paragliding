// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Common {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "common.cancel")
    /// Settings
    internal static let settings = L10n.tr("Localizable", "common.settings")
  }

  internal enum Map {
    internal enum LocationAlert {
      /// Edit your %@'s settings to authorize %@ to read your location.
      internal static func message(_ p1: String, _ p2: String) -> String {
        return L10n.tr("Localizable", "map.locationAlert.message", p1, p2)
      }
      /// Location
      internal static let title = L10n.tr("Localizable", "map.locationAlert.title")
    }
  }

  internal enum Search {
    internal enum SearchBar {
      /// Where do you want to fly?
      internal static let placeholder = L10n.tr("Localizable", "search.searchBar.placeholder")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
