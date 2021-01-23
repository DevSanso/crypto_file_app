

enum KeyHash {
  SHA256,
  SHA1,
  MD5
}

enum CryptoMode {
  AES_CBC,
  AES_CTR,
  AES_GCM,
}
enum Action {
  Encode,
  Decode
}

class _Config {
  Action action;
  void switchAction() {
    if(action == Action.Decode) {
      action = Action.Encode;
    }else {
      action = Action.Decode;
    }
  }
  bool isEncode() {
     if(action == Action.Decode) {
      return false;
    }else {
      return true;
    }
  }

  String srcFilePath;
  String dstFilePath;

  KeyHash hash;
  CryptoMode mode;

  String key;

}






final _Config config = _Config();