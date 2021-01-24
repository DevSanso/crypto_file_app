import 'dart:async';
import 'package:flutter/material.dart';
import '../config.dart' as AppConfig;

class CryptoSetView extends StatefulWidget {
  StreamSink<int> _router;
  CryptoSetView(this._router);
  
  @override
  State<CryptoSetView> createState() {
    return CryptoSetViewState();
  }
}

class CryptoSetViewState extends State<CryptoSetView> {
  List<bool> _selectExpaned = [false,false];


  String cryptoPanelName() {
    var mode = AppConfig.config.mode;
    if(AppConfig.CryptoMode.AES_GCM == mode)
      return "Aes GCM";
    else if(AppConfig.CryptoMode.AES_CTR == mode)
      return "Aes CTR";
    else
      return "Aes CBC";
  }


  @override
  Widget build(BuildContext context){
    return Column(
      children: 
      [
        _selectCryptoBox()
      ],);
  }
  Widget _selectCryptoBox() {
    return ExpansionPanelList(
      expansionCallback: (int index,bool isExpaned) {
        setState((){
          _selectExpaned[index] =  !_selectExpaned[index];
        });
      },
      children: 
      [
        _selectCrypto(),
      ]
    );
  }
  
  ExpansionPanel _selectCrypto() {
    return ExpansionPanel(
      headerBuilder: (BuildContext context,bool isExpaned) {
        return ListTile(title : Text("Crypto: ${cryptoPanelName()}"));
      },
      isExpanded: _selectExpaned[0],
      body : Column(
        children: [
          ListTile(
            title: const Text('Aes CBC'),
            leading: Radio(
              value:  AppConfig.CryptoMode.AES_CBC,
              groupValue: AppConfig.config.mode,
              onChanged: (AppConfig.CryptoMode value) {
                setState(() {
                  AppConfig.config.mode = value;
                });
              },
            ),
            
          ),
          ListTile(
            title: const Text('Aes CTR'),
            leading: Radio(
              value:  AppConfig.CryptoMode.AES_CTR,
              groupValue: AppConfig.config.mode,
              onChanged: (AppConfig.CryptoMode value) {
                setState(() {
                  AppConfig.config.mode = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Aes GCM'),
            leading: Radio(
              value:  AppConfig.CryptoMode.AES_GCM,
              groupValue: AppConfig.config.mode,
              onChanged: (AppConfig.CryptoMode value) {
                setState(() {
                  AppConfig.config.mode = value;
                });
              },
            ),
          )
        ],
      )
    );
  }
    
  ExpansionPanel _selectPasswdHash() {
    return null;
  }
  Widget _nextBtn() {
    return RaisedButton(
          onPressed: () {
            
          },
          child : Text("next")
    );
  }





}