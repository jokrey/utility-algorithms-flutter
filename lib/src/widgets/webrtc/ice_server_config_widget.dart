import 'package:flutter/material.dart';

import '../michelangelo/big_wide_button.dart';

///For when you don't have any - which would be a problem, but whatever
const List<Map<String, String>> emptyIceServers = [];

///Controller for IceServersConfigurationWidget
class IceServersConfigurationController {
  List<Map<String, String>> _iceServers;
  ///ice servers that are mutated by this widget
  List<Map<String, String>> get iceServers => _iceServers;
  set iceServers(List<Map<String, String>> iceServers) {
    _iceServers = iceServers;
    if(_onChange != null) {
      _onChange(_iceServers);
    }
  }

  Function(List<Map<String, String>>) _onChange;

  ///Constructor
  IceServersConfigurationController({iceServers=emptyIceServers, onChange}) :
      _iceServers = iceServers,
        _onChange = onChange;
}

///widget to configure ice servers
class IceServersConfigurationWidget extends StatefulWidget {
  ///This widget's controller
  final IceServersConfigurationController _controller;
  ///Constructor
  IceServersConfigurationWidget(this._controller, {onChange}) {
    _controller._onChange = onChange;
  }

  @override
  _IceServersConfigurationWidgetState createState() =>
      _IceServersConfigurationWidgetState(_controller.iceServers);
}

class _IceServersConfigurationWidgetState
    extends State<IceServersConfigurationWidget> {
  final serverConfigurators = <_IceServerConfigurationWidget>[];
  _IceServersConfigurationWidgetState(iceServers) {
    for(var iceS in iceServers) {
      var url = iceS['url'];
      var username = iceS['username'] ?? "";
      var credential = iceS['credential'] ?? "";
      if(url != null) {
        serverConfigurators.add(
            _IceServerConfigurationWidget(url, username, credential)
        );
      }
    }
  }

  _applyChangesAndPop() {
    var jsonListOfIceServers = <Map<String, String>>[];
    for(var iceConfigW in serverConfigurators) {
      var url = iceConfigW.urlC.text;
      if(iceConfigW.representsTurnServer) {
        jsonListOfIceServers.add(
            {
              'url': url.startsWith('turn:') ? url : 'turn:$url',
              'username': iceConfigW.turnUsernameC.text,
              'credential': iceConfigW.turnCredentialC.text
            }
        );
      } else {
        jsonListOfIceServers.add(
            {
              'url': url.startsWith('stun:') ? url : 'stun:$url'
            }
        );
      }
    }
    widget._controller.iceServers = jsonListOfIceServers;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: serverConfigurators.map((e) {
                  return Card(child: Column(
                    children: [
                      Text(
                          "Ice Server: ",
                          style: TextStyle(fontWeight: FontWeight.bold)
                      ),
                      e,
                      _WidthFillingTextButton("Remove", bg: Color(0xffA71D31),
                          onPressed: () => setState((){
                            serverConfigurators.remove(e);
                          })
                      ),
                    ],
                  ));
                }).toList(),
              ),
            ),
            _WidthFillingTextButton("Add Ice Server", bg: Color(0xffA71D31),
              onPressed: () => setState(() {
                serverConfigurators.add(
                    _IceServerConfigurationWidget("","","")
                );
              })
            ),
            _WidthFillingTextButton("Apply Changes",
              onPressed: _applyChangesAndPop,
            ),
          ],
        ))
    );
  }
}


class _WidthFillingTextButton extends SizedBox {
  _WidthFillingTextButton(String text,
      {VoidCallback onPressed, Color bg=defaultButtonBgColor}) :
        super(width: double.infinity, // match_parent
          child: RaisedButton(
            child: Text(text),
            onPressed: onPressed,
            color: bg,
            textColor: Colors.white,
          ));
}

//stun or turn
class _IceServerConfigurationWidget extends StatefulWidget {
  final urlC = TextEditingController();
  final turnUsernameC = TextEditingController();
  final turnCredentialC = TextEditingController();


  bool get representsTurnServer =>
      turnUsernameC.text.isNotEmpty && turnCredentialC.text.isNotEmpty;

  _IceServerConfigurationWidget(String url, username, credential) {
    urlC.text = url;
    turnUsernameC.text = username;
    turnCredentialC.text = credential;
  }

  @override
  _IceServerConfigurationWidgetState createState() =>
      _IceServerConfigurationWidgetState();
}
class _IceServerConfigurationWidgetState
    extends State<_IceServerConfigurationWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
            controller: widget.urlC,
            decoration: InputDecoration(
                labelText: "URL (Stun/Turn)", hintText: "enter a url"
            )
        ),
        TextField(
            controller: widget.turnUsernameC,
            decoration: InputDecoration(
                labelText: "Username (Turn only)",
                hintText: "enter the username or leave it blank"
            )
        ),
        TextField(
            controller: widget.turnCredentialC,
            decoration: InputDecoration(
                labelText: "Credential (Turn only)",
                hintText: "enter the credential or leave it blank"
            )
        )
      ],
    );
  }
}
