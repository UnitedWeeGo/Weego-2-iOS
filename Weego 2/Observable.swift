import RxSwift

extension Observable {
  /** Maps the entire sequence to a single element of type `Void`, regardless of whether its empty or not. */
  func void() -> Observable<Void> {
    return self.ignoreElements().toArray().flatMap { _ in Observable<Void>.just(()) }
  }

  public func doOnTerminate(_ onTerminate: @escaping (() -> Void)) -> Observable<E> {
    return self.do(onError: { _ in onTerminate() }, onCompleted: { onTerminate() })
  }
}
