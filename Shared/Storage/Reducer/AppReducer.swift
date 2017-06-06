import ReactiveReSwift

let appReducer: Reducer<AppState> = { action, state in
  let userState = userReducer(action, state.userState)

  return AppState(withUserState: userState)
}
