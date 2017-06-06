import RxSwift
import ReactiveReSwift

struct Storage {
  private let storage: Store<Variable<AppState>>
  let rxState: Observable<AppState>

  init() {
    let middleware = Middleware<AppState>().sideEffect { _, _, action in
      print("=========== 💥Received action: ===========")
      }.map { _, action in
        print(action)
        print("===================")
        return action
    }

    let initialState = AppState()

    storage = Store(
      reducer: appReducer,
      observable: Variable(initialState),
      middleware: middleware
    )

    rxState = storage.observable.asObservable()
  }

  public func dispatch(_ actions: Action...) {
    actions.forEach { action in
      self.storage.dispatch(action)
    }
  }
}
