import ReactiveReSwift

let userReducer: Reducer<UserState> = { action, state in
  switch action {
  case let action as UserDidAuthAction:
    return UserState(withIsAuthed: action.authed)
  case let action as UserDidLogOutAction:
    return UserState(withIsAuthed: action.authed)
  default:
    return state
  }
}
