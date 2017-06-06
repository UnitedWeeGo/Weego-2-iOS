struct UserState {
  let authed: Bool

  init(withIsAuthed isAuthed: Bool = false) {
    authed = isAuthed
  }
}
