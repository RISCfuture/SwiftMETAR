import Foundation
import SwiftMETAR

extension Weather {

  /// Formatter for `Weather`
  public struct FormatStyle: Foundation.FormatStyle, Sendable {
    public func format(_ value: Weather) -> String {
      if value.intensity == .moderate || value.intensity == .vicinity {
        if let descriptor = value.descriptor {
          if value.intensity.isVicinity {
            String(
              localized:
                "\(descriptor, format: .descriptor(phenomenon: value.phenomena.first!)) \(value.phenomena, format: .list(memberStyle: .phenomenon, type: .and)) in the vicinity",
              comment: "weather phenomena (descriptor, phenomena)"
            )
          } else {
            String(
              localized:
                "\(descriptor, format: .descriptor(phenomenon: value.phenomena.first!)) \(value.phenomena, format: .list(memberStyle: .phenomenon, type: .and))",
              comment: "weather phenomena (descriptor, phenomena)"
            )
          }
        } else {
          if value.intensity.isVicinity {
            String(
              localized:
                "\(value.phenomena, format: .list(memberStyle: .phenomenon, type: .and)) in the vicinity",
              comment: "weather phenomena (phenomena)"
            )
          } else {
            ListFormatStyle.list(memberStyle: .phenomenon, type: .and).format(value.phenomena)
          }
        }
      } else {
        if let descriptor = value.descriptor {
          if value.intensity.isVicinity {
            String(
              localized:
                "\(value.intensity, format: .intensity) \(descriptor, format: .descriptor(phenomenon: value.phenomena.first!)) \(value.phenomena, format: .list(memberStyle: .phenomenon, type: .and)) in the vicinity",
              comment: "weather phenomena (intensity, descriptor, phenomena)"
            )
          } else {
            String(
              localized:
                "\(value.intensity, format: .intensity) \(descriptor, format: .descriptor(phenomenon: value.phenomena.first!)) \(value.phenomena, format: .list(memberStyle: .phenomenon, type: .and))",
              comment: "weather phenomena (intensity, descriptor, phenomena)"
            )
          }
        } else {
          if value.intensity.isVicinity {
            String(
              localized:
                "\(value.intensity, format: .intensity) \(value.phenomena, format: .list(memberStyle: .phenomenon, type: .and)) in the vicinity",
              comment: "weather phenomena (intensity, phenomena)"
            )
          } else {
            String(
              localized:
                "\(value.intensity, format: .intensity) \(value.phenomena, format: .list(memberStyle: .phenomenon, type: .and))",
              comment: "weather phenomena (intensity, phenomena)"
            )
          }
        }
      }
    }
  }
}

// swiftlint:disable missing_docs
extension FormatStyle where Self == Weather.FormatStyle {
  public static var weather: Self { .init() }
}
// swiftlint:enable missing_docs
