import UIKit
import Firebase
import FBSDKLoginKit
import AsyncDisplayKit
import ReactiveReSwift
import RxSwift

struct UserDidAuthAction: Action {
  let authed: Bool = true
}

struct UserDidLogOutAction: Action {
  let authed: Bool = false
}

class ViewController: ASViewController<ASDisplayNode>, FBSDKLoginButtonDelegate {
  private let storage: Storage
  private let disposeBag = DisposeBag()

  init(withStorage storage: Storage)
  {
    self.storage = storage

    let rootNode = ASDisplayNode()
    rootNode.backgroundColor = UIColor.white

    super.init(node: rootNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    _ = Auth.auth().addStateDidChangeListener { (auth, user) in
      if user != nil {
        // User is signed in.
      } else {
        // No User is signed in.
      }
    }

    storage.rxState.flatMapLatest { state  in
      return Observable.just(state.userState.authed)
      }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] authed in
        guard let weakSelf = self else { return }
        if authed {
          print("===== WOHOOOOO! User loged in!")
          weakSelf.showLoggedInState()
        } else {
          print("===== PFFFFFFF! User loged out!")
          weakSelf.showFacebookLogin()
        }
      })
      .addDisposableTo(disposeBag);

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func showLoggedInState() {

    let authenticatedVC = Authenticated(withStorage: storage)
    authenticatedVC.modalTransitionStyle = .flipHorizontal
    self.present(authenticatedVC, animated: true) {
      print("Did present Authenticated VC")
    }

  }

  func showFacebookLogin() {
    // https://weego-id.firebaseapp.com/__/auth/handler

    let loginButton = FBSDKLoginButton()
    loginButton.defaultAudience = .friends
    loginButton.delegate = self
    loginButton.center = self.view.center
    self.view.addSubview(loginButton)

  }

  // FBSDKLoginButtonDelegate methods
  /**
   Sent to the delegate when the button was used to logout.
   - Parameter loginButton: The button that was clicked.
   */
  func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    self.userDidLogOut()
  }

  /**
   Sent to the delegate when the button was used to login.
   - Parameter loginButton: the sender
   - Parameter result: The results of the login
   - Parameter error: The error (if any) from the login
   */
  func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    if let error = error {
      print("loginButton delegate method error: \(error.localizedDescription)")
      return
    } else if result.isCancelled {
      print("Facebook login cancelled")
    } else {
      let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
      Auth.auth().signIn(with: credential) { [weak self] (user, error) in
        if let error = error {
          print("Auth.auth().signIn error: \(error.localizedDescription)")
          return
        }

        self?.userDidLogin()
      }
    }
  }

  //THIS MUST MOVE TO WORKERS
  private func userDidLogin()
  {
    let action = UserDidAuthAction()
    storage.dispatch(action)
  }

  private func userDidLogOut()
  {
    let action = UserDidLogOutAction()
    storage.dispatch(action)
  }

}

