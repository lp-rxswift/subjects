import Foundation
import RxSwift
import RxRelay


example(of: "Publish Subject") {
  let subject = PublishSubject<String>()
  subject.onNext("Is anyone listening?")

  let subscriptionOne = subject
    .subscribe(onNext: { string in
      print(string)
    })

  subject.onNext("1")
  subject.onNext("2")

  let subscriptionTwo = subject.subscribe { event in
    print("2) ", event.element ?? event)
  }

  subject.onNext("3")
  subscriptionOne.dispose()
  subject.onNext("4")
  subject.onCompleted()
  subject.onNext("5")
  subscriptionTwo.dispose()
  let disposeBag = DisposeBag()
  subject.subscribe {
    print("3) ", $0.element ?? $0)
  }.disposed(by: disposeBag)

  subject.onNext("?")
}

enum MyError: Error {
  case anError
}

func print<T: CustomStringConvertible>(label: String,
                                       event: Event<T>) {
  print(label, (event.element ?? event.error) ?? event)
}

example(of: "Behavior Subject") {
  
}
