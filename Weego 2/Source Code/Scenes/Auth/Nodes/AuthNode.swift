import AsyncDisplayKit

class AuthNode: ASDisplayNode {
  private let viewModel: AuthViewModelType

  init(withViewModel viewModel: AuthViewModelType)
  {
    self.viewModel = viewModel
    super.init()

    backgroundColor = UIColor.green
  }

}
