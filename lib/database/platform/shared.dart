// shared.dart

export 'native.dart';

class DBFileInfo {
  DBFileInfo(
    this.dbFileBytes,
    this.mediaStream,
  );
  var dbFileBytes;
  Stream<List<int>> mediaStream;
}
