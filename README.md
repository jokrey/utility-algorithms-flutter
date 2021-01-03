# jokrey_utilities

Utility algorithm in flutter.
Some of these algorithms and utilities might exist in a similar form in other repositories in other languages.
Notably this package currently contains a wrapper around the already quite good flutter-webrtc package.
Encapsulates some complicated network signaling stuff and provides a websocket wrapper to communicate with
   a generic go signaling server (found in another repository).

## Getting Started

Import this project into yours directly from github.

Simply add the following entry to your pubspec.yaml dependencies

```yaml
jokrey_utilities:
  git:
    url: git://github.com/jokrey/utility-algorithms-flutter.git
    ref: master
```

When using the webrtc functionalities, you need to add a few permissions.
Please refer to https://pub.dev/packages/flutter_webrtc

If you host your own signaling server and which to use ssl, you need to have a certificate. If it is self signed, you need to add it.
Always prefer to use a 'real' certificate, for example a free one by Let's Encrypt.

Please refer to github.com/jokrey/call1friend for a complete example of how to use this package's web rtc part.
