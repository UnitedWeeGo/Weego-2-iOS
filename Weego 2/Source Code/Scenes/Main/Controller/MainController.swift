import AsyncDisplayKit

class MainController: BaseController {
  private let rootNode = ASDisplayNode ()
  private let storage: Storage

  init(withStorage storage: Storage) {
    self.storage = storage
    super.init(node: rootNode)
  }

}
