import 'package:meta/meta.dart';

import 'exceptions.dart';

class FHttpManager {
  static final FHttpManager singleton = FHttpManager._();

  FHttpManager._();

  bool _init = false;

  FHttpAdapter _adapter;

  FHttpAdapter get adapter {
    _checkInit();
    return _adapter;
  }

  /// 初始化
  void init({@required FHttpAdapter adapter}) {
    assert(adapter != null);
    _adapter = adapter;
    _init = true;
  }

  void _checkInit() {
    if (!_init) {
      throw Exception(
          'You must invoke FHttpManager.singleton.init() method before this');
    }
  }
}

abstract class FHttpAdapter {
  Future<FHttpResponse> toResponse(FHttpRequestInfo requestInfo);

  void handleHttpException(dynamic e);
}

enum FHttpMethod {
  post,
  get,
}

/// http发起请求的一些信息
class FHttpRequestInfo {
  final String path;
  final Map<String, dynamic> queryParams;
  final dynamic data;
  final FHttpMethod method;

  FHttpRequestInfo({
    this.path,
    this.queryParams,
    this.data,
    this.method,
  }) : assert(method != null);
}

/// http请求返回信息
class FHttpResponse {
  final int code;
  final dynamic data;

  FHttpResponse({
    @required this.code,
    @required this.data,
  }) : assert(code != null);
}

abstract class FHttpRequest {
  FHttpResponse _response;

  FHttpResponse get response => _response;

  /// 发起请求
  Future<FHttpResponse> toResponse() async {
    FHttpManager.singleton._checkInit();

    FHttpResponse response;

    final FHttpRequestInfo requestInfo = FHttpRequestInfo(
      path: getPath(),
      queryParams: getQueryParams(),
      data: getData(),
      method: getMethod(),
    );

    try {
      response = await toResponseImpl(requestInfo);
    } catch (e) {
      handleHttpException(e);
      throw e;
    }

    assert(response != null);

    final Type type = getExpectedResponseDataType();
    if (type != null) {
      if (type != response.data.runtimeType) {
        throw Exception(
            'Expected response data type:${type} but ${response.data.runtimeType} was found');
      }
    }

    _response = response;
    return response;
  }

  /// 请求路径
  String getPath() {
    return null;
  }

  /// 请求参数
  Map<String, dynamic> getQueryParams() {
    return null;
  }

  /// 附加数据，用来扩展各种不同的[FHttpMethod]所需要的参数
  dynamic getData() {
    return null;
  }

  /// 请求方法
  FHttpMethod getMethod() {
    return FHttpMethod.post;
  }

  /// 返回希望得到的请求结果数据类型[FHttpResponse.data]
  Type getExpectedResponseDataType() {
    return String;
  }

  @protected
  Future<FHttpResponse> toResponseImpl(FHttpRequestInfo requestInfo) {
    final FHttpAdapter adapter = FHttpManager.singleton.adapter;
    return adapter.toResponse(requestInfo);
  }

  void handleHttpException(dynamic e) {
    FHttpManager.singleton.adapter.handleHttpException(e);
  }
}

abstract class FHttpModelRequest<T> extends FHttpRequest {
  @override
  Type getExpectedResponseDataType() {
    return String;
  }

  /// 发起请求
  Future<T> toModel() async {
    final FHttpResponse response = await toResponse();

    assert(response.data is String);
    final String data = beforeParse(response.data);

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
