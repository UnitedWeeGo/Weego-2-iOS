import AsyncDisplayKit
import FBSDKLoginKit

class AuthNode: ASDisplayNode {
  fileprivate let viewModel: AuthViewModelType

  lazy var facebookButton: ASDisplayNode = {
    return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
      guard let weakSelf = self else { fatalError("missing self in AuthNode:facebookButton block") }
      let loginButton = FBSDKLoginButton()
      loginButton.defaultAudience = .friends
      loginButton.loginBehavior = .systemAccount
      loginButton.delegate = weakSelf
      return loginButton
    })
  }()

  init(withViewModel viewModel: AuthViewModelType)
  {
    self.viewModel = viewModel

    super.init()

    automaticallyManagesSubnodes = true
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    facebookButton.style.preferredSize = CGSize(width: 100.0, height: 28.0)
    let facebookButtonSpec = ASWrapperLayoutSpec(layoutElement: facebookButton)

    let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: facebookButtonSpec)

    return ASAbsoluteLayoutSpec(children: [centerSpec])
  }

}

extension AuthNode: FBSDKLoginButtonDelegate {
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    print("Facebook button did log out")
  }

  func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
    print("Facebook button will log in")
    return true
  }

  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    print("Facebook button did complete")
    print(result)
    print(error)
  }
}
