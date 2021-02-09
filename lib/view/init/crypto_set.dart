import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../var/config.dart' as AppConfig;

class CryptoSetView extends StatefulWidget {
  StreamSink<int> _router;
  CryptoSetView(this._router);
  
  @override
  State<CryptoSetView> createState() {
    return _CryptoSetViewState();
  }
}

class _CryptoSetViewState extends State<CryptoSetView> {
  TextEditingController passwdController;
  TextEditingController passwdCkiController;

  @override
  Widget build(BuildContext context){
    passwdController = TextEditingController(text : AppConfig.globalConfig.key);
    passwdCkiController = TextEditingController(text : AppConfig.globalConfig.key);
    return Column(
      children: 
      [
        Container(
          child: Text("Crypto Setting",style: TextStyle(fontSize: 24)),
          margin: EdgeInsets.only(top : 30),
        ),
        Container(
          child: Column(children: radioSelect(),),
          padding:EdgeInsets.only(top : 50)
        ),
        Container(
          child: passwdTxtBox(),
          margin: EdgeInsets.only(top : 30,bottom: 50),
        ),
        nextBtn()
      ],
    );
    
  }

  List<Widget> radioSelect() {
    return 
    [
      ListTile(
        title : Text("AES CBC"),
        leading : Radio(
          value : AppConfig.CryptoMode.AES_CBC,
          groupValue: AppConfig.globalConfig.mode,
          onChanged: (AppConfig.CryptoMode value) {
            setState(() {
              AppConfig.globalConfig.mode = value;
            });
          },
        )
      ),
      ListTile(
        title : Text("AES CTR"),
        leading : Radio(
          value : AppConfig.CryptoMode.AES_CTR,
          groupValue: AppConfig.globalConfig.mode,
          onChanged: (AppConfig.CryptoMode value) {
            setState(() {
              AppConfig.globalConfig.mode = value;
            });
          },
        )
      ),
      ListTile(
        title : Text("AES GCM"),
        leading : Radio(
          value : AppConfig.CryptoMode.AES_GCM,
          groupValue: AppConfig.globalConfig.mode,
          onChanged: (AppConfig.CryptoMode value) {
            setState(() {
              AppConfig.globalConfig.mode = value;
            });
          },
        )
      ),
    ];
  }
  Widget passwdTxtBox() {
    return Column(children: [
      TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Password'
        ),
        controller: passwdController,
        autofocus: false,
        obscureText: true,
      ),
      TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Password Check'
        ),
        controller: passwdCkiController,
        autofocus: false,
        obscureText: true,
      )
    ],);
  }
  Widget nextBtn() {
    return RaisedButton(
          onPressed: () {
            if(passwdController.text == "") {
              showPasswdEmpty();
              return;
            }
            if(passwdController.text != passwdCkiController.text) {
              showPasswdNotMatch();
              return;
            }
            AppConfig.globalConfig.key = passwdController.text;
            widget._router.add(3);
          },
          child : Text("next")
    );
  }
  void showPasswdEmpty() {
    Fluttertoast.showToast(
        msg: "Empty Password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white30,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }
  void showPasswdNotMatch() {
    Fluttertoast.showToast(
        msg: "Password not Matching",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white30,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }



}