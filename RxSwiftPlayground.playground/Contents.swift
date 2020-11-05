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
  let subject = BehaviorSubject(value: "Initial value")
  let disposeBag = DisposeBag()
  subject.onNext("X")
  subject.subscribe {
    print(label: "1) ", event: $0)
  }
  .disposed(by: disposeBag)

  subject.onError(MyError.anError)
  subject.subscribe {
    print(label: "2)", event: $0)
  }
  .disposed(by: disposeBag)
}

example(of: "Replay Subject") {
  let subject = ReplaySubject<String>.create(bufferSize: 2)
  let disposeBag = DisposeBag()

  subject.onNext("1")
  subject.onNext("2")
  subject.onNext("3")

  subject.subscribe {
    print(label: "1) ", event: $0)
  }
  .disposed(by: disposeBag)

  subject.subscribe {
    print(label: "2) ", event: $0)
  }
  .disposed(by: disposeBag)

  subject.onNext("4")
  subject.onError(MyError.anError)
  subject.dispose()
  subject.subscribe {
    print(label: "3) ", event: $0)
  }
  .disposed(by: disposeBag)
}

example(of: "Publish Relay") {
  let relay = PublishRelay<String>()
  let disposeBag = DisposeBag()
  relay.accept("Knock knock, anyone home?")

  relay.subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

  relay.accept("1")
}

example(of: "Behavior relay") {
  let relay = BehaviorRelay(value: "Initial value")
  let disposeBag = DisposeBag()

  relay.accept("New initial value")

  relay.subscribe { print(label: "1) ", event: $0) }
    .disposed(by: disposeBag)

  relay.accept("1")

  relay.subscribe { print(label: "2) ", event: $0) }
    .disposed(by: disposeBag)

  relay.accept("2")

  print(relay.value)
}

example(of: "Black jack challenge") {

  let disposeBag = DisposeBag()
  let dealtHand = PublishSubject<[(String, Int)]>()

  func deal(_ cardCount: UInt) {
    var deck = cards
    var cardsRemaining = deck.count
    var hand = [(String, Int)]()

    for _ in 0..<cardCount {
      let randomIndex = Int.random(in: 0..<cardsRemaining)
      hand.append(deck[randomIndex])
      deck.remove(at: randomIndex)
      cardsRemaining -= 1
    }

    // Add code to update dealtHand here
    let handPoints = points(for: hand)
    if handPoints > 21 {
      dealtHand
        .onError(HandError.busted(points: handPoints))
    } else {
      dealtHand.onNext(hand)
    }
  }

  // Add subscription to dealtHand here
  dealtHand.subscribe(onNext: { element in
    print(cardString(for: element), "for", points(for: element))
  }, onError: { error in
    print(String(describing: error))
  })


  deal(3)
}
