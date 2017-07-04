import AsyncDisplayKit
import TTGSnackbar

extension ASDisplayNode {
  func showToastMessage(_ message: String,
                        withDuration duration: TTGSnackbarDuration = .middle,
                        onUndoTap: ((_ snackbar: TTGSnackbar) -> Void)? = .none,
                        onDismiss: ((_ snackbar: TTGSnackbar) -> Void)? = .none) {
    let snackbar: TTGSnackbar = TTGSnackbar.init(message: message, duration: duration)
    snackbar.backgroundColor = ColorManager.Toast.background
    snackbar.cornerRadius = 0.0
    snackbar.leftMargin = 0.0
    snackbar.rightMargin = 0.0
    snackbar.bottomMargin = 0.0

    snackbar.dismissBlock = onDismiss

    if onUndoTap != nil {
      snackbar.actionText = NSLocalizedString("undo", comment: "").uppercased()
      snackbar.actionTextColor = ColorManager.Toast.undoColor
      snackbar.actionBlock = onUndoTap
    }

    snackbar.show()
  }
}
