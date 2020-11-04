import Foundation
import RxSwift
import RxRelay


example(of: "Publish Subject") {
  let subject = PublishSubject<String>()
  subject.onNext("Is anyone listening?")
}
