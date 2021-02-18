import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart' as hash;
import 'package:path/path.dart' as p;
import 'package:loading_animations/loading_animations.dart';

import '../var/config.dart' as AppConfig;
import '../var/switch.dart';

class ProcessingView extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _State();
  }
}


class _State extends State<ProcessingView> {
  _Process _process = null;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    if(AppConfig.Action.Decode == AppConfig.globalConfig.action) {
      _process = _Decode(AppConfig.globalConfig);
    }else {
      _process = _Encode(AppConfig.globalConfig);
    }

    
  }

  @override
  Widget build(BuildContext context) {
    var loadingCounter = _process.running();
    // TODO: implement build
    return Column(
      children: 
      [
        Container(
          margin: EdgeInsets.only(top: 50),
          child: loading()
        ),
        Container(
          margin : EdgeInsets.only(top: 30),
          child: Center(child: outputLog(loadingCounter),)
        )
      ],
    );
  }

  Widget loading() {
    return Center(
      child: LoadingBouncingGrid.square(
        borderColor: Colors.blueGrey,
        borderSize: 3,
        size : 30,
        duration: Duration(milliseconds: 500),
      ),
    );
  }
  StreamBuilder<String> outputLog(Stream<String> loadingCounter) {
    return StreamBuilder<String>(stream: loadingCounter,
        builder: (BuildContext context,AsyncSnapshot<String> snapshot) {
          return Text("$snapshot",style: TextStyle(fontSize: 24),);
        }
    );
  }

}




class FileHeader {
  AppConfig.CryptoMode mode;
  List<int> pbkdf2;
  Nonce nonce;
  int dataLen;

  FileHeader.init(this.mode,this.pbkdf2,this.nonce,this.dataLen);
}


Uint8List makePbkdf2Bytes(Nonce nonce){
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac(sha256),
      iterations: 10000,
      bits: 256
    );
    var key = utf8.encode(AppConfig.globalConfig.key);
    return pbkdf2.deriveBitsSync(key,nonce: nonce);
}

CipherWithAppendedMac makeCipher(AppConfig.CryptoMode mode) {
    CipherWithAppendedMac mac;
    
    switch (mode) {
      case AppConfig.CryptoMode.AES_CBC:
      mac = CipherWithAppendedMac(aesCbc,Hmac(sha256));
      break;
      case AppConfig.CryptoMode.AES_CTR:
      mac = CipherWithAppendedMac(aesCtr,Hmac(sha256));
      break;
      case AppConfig.CryptoMode.AES_GCM:
      mac = CipherWithAppendedMac(aesGcm,Hmac(sha256));
      break;
    }
    return mac;
}
hash.Digest makeDigest() {
    var bytes = utf8.encode(AppConfig.globalConfig.key);
    return hash.sha256.convert(bytes);
}

abstract class _Process {
  AppConfig.Config config;

  _Process(this.config);

  Stream<String> running();


  void writeFileHeader(RandomAccessFile f,FileHeader header) {
    f.setPositionSync(0);
    int flag = 0;
    switch (header.mode) {
      case AppConfig.CryptoMode.AES_CBC:
      flag = 1;
      break;
      case AppConfig.CryptoMode.AES_CTR:
      flag = 2;
      break;
      case AppConfig.CryptoMode.AES_GCM:
      flag = 3;
      break;
    }
    f.writeByteSync(flag);
    f.writeFromSync(header.pbkdf2);
    f.writeFromSync(header.nonce.bytes);
    var lenData = ByteData(4);
    lenData.setUint32(0, header.dataLen);
    f.writeFromSync(lenData.buffer.asUint8List());
    
  }

  FileHeader readFileHeader(RandomAccessFile f) {
    
    AppConfig.CryptoMode mode;
    f.setPositionSync(0);
    var flag = f.readByteSync();
    var buf = List<int>(32);
    var nonceBuf = List<int>(16);
    f.readIntoSync(buf);
    f.readIntoSync(nonceBuf);

    Nonce nonce = Nonce(nonceBuf);

    switch (flag) {
      case 1:
      mode = AppConfig.CryptoMode.AES_CBC;
      break;
      case 2:
      mode = AppConfig.CryptoMode.AES_CTR;
      break;
      case 3:
      mode = AppConfig.CryptoMode.AES_GCM;
      break;
    }
  
    var blockCountBuf = Uint8List(4);
    f.readIntoSync(blockCountBuf);
    var count = ByteData.view(blockCountBuf.buffer).getUint32(0);
    
    return FileHeader.init(mode,buf,nonce,count);
  }  
}
  

class _Encode extends _Process{
  _Encode(AppConfig.Config config) : super(config);

  @override
  Stream<String> running() {
    var accessSrc = config.srcFile.openSync();

    
    var dstF = File(p.join(
      config.dstDirPath,
      p.basename(accessSrc.path)));
    
    var accessDst = dstF.openSync(mode: FileMode.write);
    var controller = new StreamController<String>();
    


    var cipher = makeCipher(config.mode);
    var secretKey = SecretKey(makeDigest().bytes);
    var nonce = cipher.newNonce();

    var fileHeader = FileHeader.init(
      config.mode,
      makePbkdf2Bytes(nonce),
      nonce,
      accessSrc.lengthSync()
    );
    writeFileHeader(accessDst, fileHeader);
    
    () async {
      var input = new List<int>(() {
        if(fileHeader.dataLen <= 32) {
          return 32;
        }else {
          return fileHeader.dataLen;
        }
      }());
      
      
      
      try {
        controller.add("reading file");
        accessSrc.readIntoSync(input);
        controller.add("encrpyto...");
        var buffer = cipher.encryptSync(input, secretKey: secretKey, nonce: nonce);
        controller.add("writing...");
        accessDst.writeFromSync(buffer);
      }
      catch(e) {
        throw e;
      }
      finally {
        accessSrc.close();
        accessDst.close();
        controller.close();
      }
    }();

    return controller.stream;
  }
  
}

class _Decode extends _Process{
  _Decode(AppConfig.Config config) : super(config);
  @override
  Stream<String> running(){
    var accessSrc = config.srcFile.openSync();
    var header = readFileHeader(accessSrc);

    
    if(listEquals(header.pbkdf2, makePbkdf2Bytes(header.nonce))) {
      throw Exception("not matching passwd");
    }

    var dstF = File(p.join(
      config.dstDirPath,
      p.basename(accessSrc.path)));

    var accessDst = dstF.openSync();
    var controller = new StreamController<String>();

    var cipher = makeCipher(header.mode);
    var secretKey = SecretKey(makeDigest().bytes);
    () async {
      var input = new List<int>(() {
        if(header.dataLen <= 32) {
          return 32;
        }else {
          return header.dataLen;
        }
      }());

      try{
        controller.add("reading file");
        accessSrc.readIntoSync(input);
        controller.add("decrpyto...");
        var buffer = cipher.decryptSync(input , secretKey: secretKey, nonce: header.nonce);
        controller.add("writing...");
        accessDst.writeFromSync(List<int>.from(buffer.take(header.dataLen)));
      }catch(e){
        throw e;
      }finally{
          controller.close();
          accessSrc.close();
          accessDst.close();
      }
    }();
    return controller.stream;
  }
}