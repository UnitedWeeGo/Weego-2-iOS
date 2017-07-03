import AsyncDisplayKit
import FBSDKLoginKit

class AuthNode: ASDisplayNode {
  fileprivate let viewModel: AuthViewModelType

//  lazy var facebookButton: ASDisplayNode = {
//    return ASDisplayNode(viewBlock: { [weak self] () -> UIView in
//      guard let weakSelf = self else { fatalError("missing self in AuthNode:facebookButton block") }
//      let loginButton = FBSDKLoginButton()
//      loginButton.defaultAudience = .friends
//      loginButton.loginBehavior = .systemAccount
//      loginButton.delegate = weakSelf
//      return loginButton
//    })
//  }()

  private let facebookButton = ASButtonNode();

  init(withViewModel viewModel: AuthViewModelType)
  {
    self.viewModel = viewModel

    super.init()

    automaticallyManagesSubnodes = true

    let facebookButtonTitleStyle = TextStyleManager.sharedInstance.centeredTextStyleWithFontOfSize(17.0, withColor: ColorManager.Auth.facebookButtonTitle)
    let facebookButtonTitle = NSAttributedString(string: "Log in with Facebook",
                                                 attributes: facebookButtonTitleStyle)

    facebookButton.backgroundColor = ColorManager.Auth.facebookButtonBackground
    facebookButton.setAttributedTitle(facebookButtonTitle, for: .normal)
    facebookButton.cornerRadius = 8.0
    facebookButton.addTarget(self, action: #selector(didTapFacebookButton), forControlEvents: .touchUpInside)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    facebookButton.style.width = ASDimensionMakeWithFraction(0.8)
    facebookButton.style.height = ASDimensionMakeWithPoints(44.0)
    let facebookButtonSpec = ASWrapperLayoutSpec(layoutElement: facebookButton)

    let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: facebookButtonSpec)

    return ASAbsoluteLayoutSpec(children: [centerSpec])
  }

  func didTapFacebookButton()
  {
    print("didTapFacebookButton")
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
