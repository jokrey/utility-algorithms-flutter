///An observer on an observable - called when notifyAll on Observable is called
typedef Observer<T> = Future<void> Function(T);

///An arbitrary Observable object
///  (can be extended from or implemented from or used directly,
///   semantic naming potentially problematic when using directly)
class Observable<T> {
  final List<Observer<T>> _observers = [];

  ///Add an observer
  void addObserver(Observer<T> observer) => _observers.add(observer);
  ///Remove an observer (must be same f-pointer, since Functions incomparable)
  void removeObserver(Observer<T> observer) => _observers.remove(observer);

  ///Calls all registered observers with the change, can be used asynchronously
  Future<void> notifyAll(T change) async {
    for(var o in _observers) {
      await o(change);//todo call them simultaneously? Not await, but await for
    }
  }
}
