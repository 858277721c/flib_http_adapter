import 'package:meta/meta.dart';

import 'exceptions.dart';

class FHttpResponse {
  final int httpCode;
  final String content;

  FHttpResponse({
    @required this.httpCode,
    @required this.content,
  });
}

abstract class FHttpRequest {
  Future<FHttpResponse> toResponse() async {
    final FHttpResponse response = await toResponseImpl();
    assert(response != null);
    return response;
  }

  @protected
  Future<FHttpResponse> toResponseImpl();
}

abstract class FModelHttpRequest<T> extends FHttpRequest {
  Future<T> toModel() async {
    final FHttpResponse response = await toResponse();
    try {
      return parseToModel(response);
    } catch (e) {
      throw new FHttpParseResponseException(error: e);
    }
  }

  @protected
  T parseToModel(FHttpResponse response);
}
