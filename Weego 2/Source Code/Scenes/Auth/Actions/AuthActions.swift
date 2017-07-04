import ReactiveReSwift
import Firebase

struct UserDidAuthAction: Action {
  let user: User
  let authState = UserAuthStateResult.success(.authenticated)
}

struct UserDidLogOutAction: Action {
}

struct UpdateAuthStateAction: Action {
  var authState: UserAuthStateResult
}
