import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../general/observers.dart';
import '../peer_id.dart';

///Abstract stream provider,
///  concrete implementations will either be local or remote
abstract class StreamProvider extends Observable<MediaStream> {
  ///Given id of this stream/provider/peer
  PeerId id;

  ///Constructor
  StreamProvider(this.id);

  MediaStream _stream;

  ///Returns the internal media stream, created using initStream
  MediaStream get stream => _stream;

  set stream(MediaStream value) {
    _stream = value;
    notifyAll(stream);
  }

  ///Implementation shall initialize and return the stream in this method
  ///After this method completes, get stream shall return the created stream
  ///Called at most once
  Future<MediaStream> initStream();

  ///Returns whether it can be assumed that this provider is connected or not
  ///Not necessarily accurate:
  ///    implementations may take a timeout amount of time to notice disconnect
  bool isConnected() =>
      stream != null &&
      (stream.getAudioTracks().isNotEmpty ||
          stream.getVideoTracks().isNotEmpty);

  ///Closes this stream, idempotent
  ///Implementations shall close their own resources also
  @mustCallSuper
  Future<void> closeStream() async {
    stream?.getTracks()?.forEach((element) async {
      await element.stop();
    });
    await stream?.dispose();
    stream = null;
  }
}
