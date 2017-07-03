import RxSwift

protocol AuthViewModelInputs {
  func didRequestToLoginWithFacebook() -> Void
}

protocol AuthViewModelOutputs {
}

protocol AuthViewModelType {
  var inputs: AuthViewModelInputs { get }
  var outputs: AuthViewModelOutputs { get }
}

final class AuthViewModel: AuthViewModelInputs, AuthViewModelOutputs {
  private let storage: Storage

  init(withStorage storage: Storage) {
    self.storage = storage
  }

  func didRequestToLoginWithFacebook() {

  }
}

extension AuthViewModel: AuthViewModelType {
  var inputs: AuthViewModelInputs { return self }
  var outputs: AuthViewModelOutputs { return self }
}
