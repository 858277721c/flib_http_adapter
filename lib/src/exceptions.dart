import 'package:meta/meta.dart';

class FHttpException implements Exception {
  final String message;

  FHttpException(this.message);

  @override
  String toString() {
    final String prefix = 'FHttpException';
    return message == null ? prefix : prefix + ' ' + message;
  }
}

/// 请求超时
class FHttpTimeoutException extends FHttpException {
  FHttpTimeoutException({String message}) : super(message);
}

/// 请求被取消
class FHttpCancelException extends FHttpException {
  FHttpCancelException({String message}) : super(message);
}

/// 服务端错误码
class FHttpResponseCodeException extends FHttpException {
  final int responseCode;
  final String responseString;

  FHttpResponseCodeException({
    @required this.responseCode,
    this.responseString,
    String message,
  }) : super(message);
}

/// 解析服务端数据错误
class FHttpParseResponseException extends FHttpException {
  final dynamic error;

  FHttpParseResponseException({
    @required this.error,
    String message,
  }) : super(message);
}
