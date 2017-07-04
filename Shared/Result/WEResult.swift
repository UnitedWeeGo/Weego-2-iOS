import Result
import RxSwift

// MARK: ListFetchState
public enum ListFetchState {
  case idle
  case initialLoading
  case loading
  case loaded
  case empty
}

struct ListFetchStateError: Error {
  let error: Error?
  init(error: Error?) {
    self.error = error
  }
}

// MARK: Auth
public enum UserAuthState {
  case idle
  case authenticating
  case authenticated
}

enum UserAuthError: Error {
  case couldNotAuth(String)
}

extension UserAuthError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .couldNotAuth(let message):
      return NSLocalizedString(message, comment: "")
    }
  }
}

extension UserAuthError: Equatable {
  public static func ==(lhs: UserAuthError, rhs: UserAuthError) -> Bool {
    return lhs.errorDescription == rhs.errorDescription
  }
}

typealias ListLoadingStateResult = Result<ListFetchState, ListFetchStateError>
typealias UserAuthStateResult = Result<UserAuthState, UserAuthError>
