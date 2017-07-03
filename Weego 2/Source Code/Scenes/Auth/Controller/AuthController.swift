import AsyncDisplayKit

class AuthController: BaseController {
  private let rootNode: AuthNode
  private let storage: Storage
  private let viewModel: AuthViewModelType

  init(withStorage storage: Storage, withViewModel viewModel: AuthViewModelType) {
    self.storage = storage
    self.viewModel = viewModel
    
    rootNode = AuthNode(withViewModel: viewModel);
    super.init(node: rootNode)
  }
}
