import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart' as hash;
import 'package:path/path.dart' as p;

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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


}

const outFileExt= ".out.cryp";
const packetSize = 64;

class FileHeader {
  AppConfig.CryptoMode mode;
  List<int> pbkdf2;
  Nonce nonce;
  int blockCount;

  FileHeader.init(this.mode,this.pbkdf2,this.nonce,this.blockCount);
}


Uint8List makePbkdf2Bytes(){
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac(sha256),
      iterations: 10000,
      bits: 256
    );
    var key = utf8.encode(AppConfig.globalConfig.key);
    return pbkdf2.deriveBitsSync(key,nonce: null);
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

  Stream<int> running();
  int calcPacketCount(RandomAccessFile f) {
    if(f.lengthSync() % packetSize != 0) {
      return f.lengthSync() + 1;
    } 
    return f.lengthSync();
  }
  

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
    lenData.setUint32(0, header.blockCount);
    f.writeFromSync(lenData.buffer.asUint8List());
    
  }
  FileHeader readFileHeader(RandomAccessFile f) {
    
    AppConfig.CryptoMode mode;
    f.setPositionSync(0);
    var flag = f.readByteSync();
    var buf = List<int>(64);
    var nonceBuf = List<int>(64);
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
  Stream<int> running() {
    var accessSrc = config.srcFile.openSync();
    var maxL = calcPacketCount(accessSrc);
    
    var dstF = File(p.join(
      config.dstDirPath,
      p.basename(accessSrc.path),
      outFileExt));
    
    var accessDst = dstF.openSync(mode: FileMode.write);
    var controller = new StreamController<int>();
    


    var cipher = makeCipher(AppConfig.globalConfig.mode);
    var secretKey = SecretKey(makeDigest().bytes);
    var nonce = cipher.newNonce();

    var fileHeader = FileHeader.init(
      AppConfig.globalConfig.mode,
      makePbkdf2Bytes(),
      nonce,
      maxL
    );
    writeFileHeader(accessDst, fileHeader);
    
    () async {
      var input = new List<int>(64);
      var buffer = new List<int>(64);
      
      var index = 0;
      try {
        while(maxL <= index)
        {
          accessSrc.readIntoSync(input);
          controller.add(index);
          cipher.decryptToBuffer(input, buffer: buffer, secretKey: secretKey, nonce: nonce);
          accessDst.writeFromSync(buffer);
          index++;
        }
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
  Stream<int> running(){
    var accessSrc = config.srcFile.openSync();
    var header = readFileHeader(accessSrc);

    if(header.pbkdf2 != makePbkdf2Bytes()) {
      throw Exception("not matching passwd");
    }

    var dstF = File(p.join(
      config.dstDirPath,
      p.basename(accessSrc.path)));

    var accessDst = dstF.openSync();
    var controller = new StreamController<int>();

    var cipher = makeCipher(header.mode);
    var secretKey = SecretKey(makeDigest().bytes);
    () async {
      var input = new List<int>(64);
      var buffer = new List<int>(64);
      var index = 0;
      try{
        while(header.blockCount >= index){
          accessSrc.readIntoSync(input);
          cipher.decryptToBuffer(input, buffer: buffer, secretKey: secretKey, nonce: header.nonce);
          accessDst.writeFromSync(buffer);
          index++;
        }
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