import ReSwift
import RxSwift

//
// MARK: - Worker
protocol Worker {

}

// MARK: - Async Worker
protocol AsyncWorker: Worker {
  associatedtype T
  func execute() -> Observable<T>
}
