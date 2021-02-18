///Abstract connectable interface
abstract class Connectable {
  ///Connect to the api, future shall complete when connected
  ///Future shall evaluate to isConnected, when completed
  Future<bool> connect();

  ///Close connection to signaling api,
  ///  when future completes isConnected shall evaluate to false
  Future<void> close();

  ///Whether the Signaler is currently connected to its server
  bool isConnected();
}
