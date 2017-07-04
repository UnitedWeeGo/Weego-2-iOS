import RxSwift
import FBSDKLoginKit
import ReactiveReSwift
import Firebase

class FacebookAuthWorker: AsyncWorker {
  typealias T = Void

  private let authViewController: UIViewController
  private let storage: Storage

  init(withStorage st: Storage, withAuthViewController vc: UIViewController) {
    storage = st
    authViewController = vc
  }

  func execute() -> Observable<Void> {

    let loginManager = FBSDKLoginManager()
    loginManager.defaultAudience = .friends
    loginManager.loginBehavior = .systemAccount

    let readPermissions = ["public_profile"]

    let stateAction = UpdateAuthStateAction(authState: UserAuthStateResult.success(.authenticating))
    storage.dispatch(stateAction)

    return Observable<Void>
      .create({ [weak self] (observer) -> Disposable in

        guard let weakSelf = self else { return Disposables.create() }

        loginManager.logIn(withReadPermissions: readPermissions, from: weakSelf.authViewController) { (res, err) in

          if let error = err {
            let authError = UserAuthError.couldNotAuth(error.localizedDescription)
            let stateAction = UpdateAuthStateAction(authState: UserAuthStateResult.failure(authError))
            weakSelf.storage.dispatch(stateAction)

            observer.onNext(())
            observer.on(.completed)
            return
          }

          guard let result = res else {
            print("⚠️ AuthViewModel:didRequestToLoginWithFacebookFromViewController - Missing result")
            let authError = UserAuthError.couldNotAuth("Unknown error")
            let stateAction = UpdateAuthStateAction(authState: UserAuthStateResult.failure(authError))
            weakSelf.storage.dispatch(stateAction)

            observer.onNext(())
            observer.on(.completed)
            return
          }

          if result.isCancelled {
            print("⚠️ AuthViewModel:didRequestToLoginWithFacebookFromViewController - User Canceled Auth")
            let stateAction = UpdateAuthStateAction(authState: UserAuthStateResult.success(.idle))
            weakSelf.storage.dispatch(stateAction)

            observer.onNext(())
            observer.on(.completed)
            return
          }

          let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
          Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
              print("Auth.auth().signIn error: \(error.localizedDescription)")
              let authError = UserAuthError.couldNotAuth(error.localizedDescription)
              let stateAction = UpdateAuthStateAction(authState: UserAuthStateResult.failure(authError))
              weakSelf.storage.dispatch(stateAction)
              return
            }

            if let user = Auth.auth().currentUser {
              let action = UserDidAuthAction(user: user)
              weakSelf.storage.dispatch(action)
            }

          }
          
        }

        return Disposables.create()
      })
  }

  deinit {
    print("✅ deinit FacebookAuthWorker")
  }
}
