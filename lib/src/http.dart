import 'package:meta/meta.dart';

import 'exceptions.dart';

enum FHttpMethod {
  post,
  get,
  delete,
}

/// http发起请求的一些信息
class FHttpRequestInfo {
  final String path;
  final Map<String, dynamic> params;
  final FHttpMethod method;

  FHttpRequestInfo({
    this.path,
    this.params,
    this.method,
  }) : assert(method != null);
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

    final FHttpRequestInfo requestInfo = FHttpRequestInfo(
      path: getPath(),
      params: getParams(),
      method: getMethod(),
    );

    try {
      response = await toResponseImpl(requestInfo);
    } catch (e) {
      handleHttpException(e);
      throw e;
    }

    assert(response != null);
    _response = response;
    return response;
  }

  /// 请求路径
  String getPath() {
    return null;
  }

  /// 请求参数
  Map<String, dynamic> getParams();

  /// 请求方法
  FHttpMethod getMethod() {
    return FHttpMethod.post;
  }

  @protected
  Future<FHttpResponse<T>> toResponseImpl(FHttpRequestInfo request);

  void handleHttpException(dynamic e) {}
}

abstract class FHttpStringRequest extends FHttpRequest<String> {}

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
