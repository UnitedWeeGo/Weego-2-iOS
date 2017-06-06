struct AppState {
  let userState: UserState

  init(withUserState userState: UserState) {
    self.userState = userState
  }
}
