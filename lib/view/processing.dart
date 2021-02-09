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
  int dataPos;

  FileHeader.init(this.mode,this.pbkdf2,this.nonce,this.dataPos);
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

CipherWithAppendedMac makeCipher() {
    CipherWithAppendedMac mac;
    
    switch (AppConfig.globalConfig.mode) {
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
  }
  FileHeader readFileHeader(RandomAccessFile f) {
    var current = f.positionSync();
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
    var dataPos = f.positionSync();
    f.setPosition(current);
    return FileHeader.init(mode,buf,nonce,dataPos);
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
    
    var accessDst = dstF.openSync();
    
    
    var controller = new StreamController<int>();
    var buffer = new List<int>();
    var index = 0;
    var readLen = 0;

    var cipher = makeCipher();
    var secretKey = SecretKey(makeDigest().bytes);
    var nonce = cipher.newNonce();

    var fileHeader = FileHeader.init(
      AppConfig.globalConfig.mode,
      makePbkdf2Bytes(),
      nonce,
      0
    );
    writeFileHeader(accessDst, fileHeader);

    while(maxL > index)
    {
      readLen = accessSrc.readIntoSync(buffer,index,index+packetSize-1);
      
      if(readLen != packetSize)break;
      
      
      cipher.encryptSync(buffer, secretKey: secretKey, nonce: nonce);
      
      accessDst.writeFromSync(buffer);
      buffer.clear();
      index += readLen;
    }

    accessSrc.close();
    accessDst.close();
  }

}

class _Decode extends _Process{
  _Decode(AppConfig.Config config) : super(config);
  @override
  Stream<int> running(){}
}