import RxSwift
import FBSDKLoginKit

protocol AuthViewModelInputs {
  func didRequestToLoginWithFacebookFromViewController(_ vc: UIViewController) -> Void
}

protocol AuthViewModelOutputs {
  var state: Observable<UserAuthStateResult> { get }
}

protocol AuthViewModelType {
  var inputs: AuthViewModelInputs { get }
  var outputs: AuthViewModelOutputs { get }
}

final class AuthViewModel: AuthViewModelInputs, AuthViewModelOutputs {
  private let storage: Storage

  let state: Observable<UserAuthStateResult>

  init(withStorage storage: Storage) {
    self.storage = storage

    state = storage.rxState
      .map { $0.userState.authState }
      .shareReplay(1)
  }

  func didRequestToLoginWithFacebookFromViewController(_ vc: UIViewController) {
    let worker = FacebookAuthWorker(withStorage: storage, withAuthViewController: vc)
    _ = worker.execute().subscribe();
  }
}

extension AuthViewModel: AuthViewModelType {
  var inputs: AuthViewModelInputs { return self }
  var outputs: AuthViewModelOutputs { return self }
}
