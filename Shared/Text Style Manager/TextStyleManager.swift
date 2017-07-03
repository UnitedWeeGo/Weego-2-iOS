import UIKit

class TextStyleManager {
  static let sharedInstance = TextStyleManager()

  func defaultFont(ofSize: CGFloat = 15.0) -> UIFont {
    return UIFont.systemFont(ofSize: ofSize)
  }

  func defaultBoldFont(ofSize: CGFloat = 15.0) -> UIFont {
    return UIFont.systemFont(ofSize: ofSize)
  }

  func textStyleWithFontOfSize(_ fontSize: CGFloat = 15.0, withColor color : UIColor = UIColor.black) -> [String: Any] {
    let styles = [
      NSForegroundColorAttributeName : color,
      NSFontAttributeName : defaultFont(ofSize: fontSize)
    ]

    return styles
  }

  func centeredTextStyleWithFontOfSize(_ fontSize: CGFloat = 15.0, withColor color : UIColor = UIColor.black) -> [String: Any] {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center

    let styles = [
      NSForegroundColorAttributeName : color,
      NSFontAttributeName : defaultFont(ofSize: fontSize),
      NSParagraphStyleAttributeName: paragraphStyle
    ]

    return styles
  }

  func boldTextStyleWithFontOfSize(_ fontSize: CGFloat = 15.0, withColor color : UIColor = UIColor.black) -> [String: Any] {
    let styles = [
      NSForegroundColorAttributeName : color,
      NSFontAttributeName : defaultBoldFont(ofSize: fontSize)
    ]

    return styles
  }
}
