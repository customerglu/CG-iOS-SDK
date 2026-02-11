import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        let length = hexSanitized.count
        if length == 6 {
            self.init(red: CGFloat((rgb >> 16) & 0xFF) / 255,
                      green: CGFloat((rgb >> 8) & 0xFF) / 255,
                      blue: CGFloat(rgb & 0xFF) / 255,
                      alpha: 1)
        } else if length == 8 {
            self.init(red: CGFloat((rgb >> 24) & 0xFF) / 255,
                      green: CGFloat((rgb >> 16) & 0xFF) / 255,
                      blue: CGFloat((rgb >> 8) & 0xFF) / 255,
                      alpha: CGFloat(rgb & 0xFF) / 255)
        } else {
            return nil
        }
    }
}
