import AsyncDisplayKit
import RxSwift
import Result

class AuthNode: ASDisplayNode {
  private let disposeBag = DisposeBag()
  fileprivate let viewModel: AuthViewModelType

  private var state: UserAuthStateResult = .success(.idle) {
    didSet {
      if oldValue == state {
        return
      }

      if let errorMessage = state.error?.localizedDescription {
        showToastMessage(errorMessage)
      }

    }
  }

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

    viewModel.outputs.state
      .doOnTerminate {
        print("viewModel.outputs.state doOnTerminate")
      }
      .subscribe(onNext: { [weak self] (newState) in
        guard let weakSelf = self else { return }
        weakSelf.state = newState
      })
      .addDisposableTo(disposeBag)
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
    guard let vc = self.closestViewController else { fatalError("Missing closestViewController in AuthNode:didTapFacebookButton") }
    viewModel.inputs.didRequestToLoginWithFacebookFromViewController(vc)
  }

}
