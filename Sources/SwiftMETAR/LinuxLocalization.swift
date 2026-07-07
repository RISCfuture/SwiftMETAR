//  `String(localized:)` (and `LocalizedStringResource`) come from
//  FoundationInternationalization on Apple platforms but are unavailable on Linux.
//  These packages use their default ("en") localization text as the lookup key, so on
//  Linux we resolve each key to itself. This shim is excluded on Apple, where the real
//  Foundation API is used instead.

#if !canImport(Darwin)
  import Foundation

  extension String {
    init(
      localized key: String,
      table _: String? = nil,
      bundle _: Bundle? = nil,
      locale _: Locale? = nil,
      comment _: StaticString? = nil
    ) {
      self = key
    }
  }
#endif
