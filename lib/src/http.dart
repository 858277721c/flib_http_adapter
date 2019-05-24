import 'package:meta/meta.dart';

import 'exceptions.dart';

enum FHttpMethod {
  post,
  get,
  delete,
}

/// http请求返回信息
class FHttpResponse<T> {
  final int code;
  final T content;

  FHttpResponse({
    @required this.code,
    @required this.content,
  }) : assert(code != null);
}

abstract class FHttpRequest<T> {
  FHttpResponse<T> _response;

  FHttpResponse<T> get response => _response;

  /// 发起请求
  Future<FHttpResponse<T>> toResponse() async {
    FHttpResponse<T> response;

    try {
      response = await toResponseImpl();
    } catch (e) {
      handleHttpException(e);
      throw e;
    }

    assert(response != null);
    _response = response;
    return response;
  }

  @protected
  Future<FHttpResponse<T>> toResponseImpl();

  void handleHttpException(dynamic e) {}
}

abstract class FHttpStringRequest extends FHttpRequest<String> {
  FHttpMethod getHttpMethod() {
    return FHttpMethod.post;
  }
}

abstract class FHttpModelRequest<T> extends FHttpStringRequest {
  /// 发起请求
  Future<T> toModel() async {
    final FHttpResponse<String> response = await toResponse();
    final String data = beforeParse(response.content);

    T model;
    try {
      model = parseToModel(data);
    } catch (e) {
      throw new FHttpParseResponseException(error: e);
    }

    assert(model != null);
    afterParse(model);
    return model;
  }

  /// 请求内容转model之前调用
  String beforeParse(String data) {
    return data;
  }

  /// 将请求内容转为model
  @protected
  T parseToModel(String data);

  /// 请求内容转model之后调用
  void afterParse(T model) {}
}
