import '../provider/stream_provider_remote.dart';
import 'vcall_1to1.dart';

///A video call with an allowed, hidden observer with a predefined name.
class ObservableVCall1to1 extends VCall1to1 {
  ///Remote observer provider, with the id(observerName) given in constructor
  ///Will server the observer with the local stream.
  RemoteVideoProviderInternal remoteObserverProvider;

  ///Returns whether the predetermined observer is currently connected.
  bool isObserverConnected() => remoteObserverProvider.isConnected();

  ///See super constructor
  /// Additionally creates a remote provider which will provide the stream
  ///  to the remote observer with name 'observerName'.
  ///  Typically(depending on signaler's policy), observers with other ids will
  ///    be automatically rejected.
  ObservableVCall1to1(localName, remoteName, String observerName, signaler)
      : super(localName, remoteName, signaler) {
    remoteObserverProvider = RemoteVideoProviderInternal.create(observerName);
    remoteObserverProvider.setSignaler(signaler);
    remoteObserverProvider.setLocal(localProvider);
    signaler.addRemoteProvider(remoteObserverProvider);
  }

  ///Closes the signaler if so requested, closes the local and remote provider,
  ///  additionally the remote provider stream is also closed.
  Future<void> close({bool closeSignalerConnection = false}) async {
    await super.close(closeSignalerConnection: closeSignalerConnection);
    await remoteObserverProvider.closeStream();
  }
}