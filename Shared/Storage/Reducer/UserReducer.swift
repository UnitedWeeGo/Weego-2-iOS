import ReactiveReSwift

let userReducer: Reducer<UserState> = { action, state in
  switch action {
  case let action as UserDidAuthAction:
    return UserState(withUser: action.user, withAuthState: action.authState)
  case let action as UserDidLogOutAction:
    return UserState()
  case let action as UpdateAuthStateAction:
    return UserState(withUser: state.user, withAuthState: action.authState)
  default:
    return state
  }
}
