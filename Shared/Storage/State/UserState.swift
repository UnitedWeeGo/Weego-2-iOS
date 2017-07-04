import Firebase

struct UserState {
  let user: User?
  let authState: UserAuthStateResult

  init(withUser user: User? = .none, withAuthState authState: UserAuthStateResult = UserAuthStateResult.success(.idle)) {
    self.user = user
    self.authState = authState
  }
}
