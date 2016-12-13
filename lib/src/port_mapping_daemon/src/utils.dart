import 'dart:async';

/// Listens for the next element added on [stream].
///
/// If an element is not added before [timeout] has passed, the returned
/// subscription is cancelled and [onTimeout] is called.
///
/// If an element is recieved, [onData] is called with the element.
void nextElement/*<T>*/(Stream/*<T>*/ stream,
    {Duration timeout: const Duration(seconds: 3),
    onTimeout(),
    onData(/*=T*/ element)}) {
  StreamSubscription/*<T>*/ subscription;

  var timeoutTimer = new Timer(timeout, () {
    subscription.cancel();
    onTimeout();
  });

  subscription = stream.take(1).listen((/*=T*/element) {
    timeoutTimer.cancel();
    subscription.cancel();
    onData(element);
  });
}
