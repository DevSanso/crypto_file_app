import 'dart:async';
import 'package:flutter/material.dart';

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


  @override
  Widget build(BuildContext context){
    passwdController = TextEditingController(text : AppConfig.config.key);
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
          groupValue: AppConfig.config.mode,
          onChanged: (AppConfig.CryptoMode value) {
            setState(() {
              AppConfig.config.mode = value;
            });
          },
        )
      ),
      ListTile(
        title : Text("AES CTR"),
        leading : Radio(
          value : AppConfig.CryptoMode.AES_CTR,
          groupValue: AppConfig.config.mode,
          onChanged: (AppConfig.CryptoMode value) {
            setState(() {
              AppConfig.config.mode = value;
            });
          },
        )
      ),
      ListTile(
        title : Text("AES GCM"),
        leading : Radio(
          value : AppConfig.CryptoMode.AES_GCM,
          groupValue: AppConfig.config.mode,
          onChanged: (AppConfig.CryptoMode value) {
            setState(() {
              AppConfig.config.mode = value;
            });
          },
        )
      ),
    ];
  }
  Widget passwdTxtBox() {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Crypto Password'
      ),
      controller: passwdController,
      autofocus: false,
      obscureText: true,
    );
  }
  Widget nextBtn() {
    return RaisedButton(
          onPressed: () {
            AppConfig.config.key = passwdController.text;
            widget._router.add(3);
          },
          child : Text("next")
    );
  }





}