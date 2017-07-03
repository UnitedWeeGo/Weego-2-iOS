import AsyncDisplayKit

class BaseController: ASViewController<ASDisplayNode> {

  override init(node: ASDisplayNode) {
    super.init(node: node)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
