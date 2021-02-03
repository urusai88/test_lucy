import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './../export.dart';

class ResponseException {
  final http.Response response;

  ResponseException({@required this.response});
}

class Repository {
  final String baseUrl;

  Repository({@required String baseUrl})
      : baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;

  Future<List<GoodsEntity>> loadGoods() async {
    final resp = await http.get('$baseUrl/data.json');

    print('$baseUrl/data.json');

    _validateResponse(resp);

    return ((jsonDecode(resp.body) as Map<String, dynamic>)['data'] as List)
        .map((v) => GoodsEntity.fromJson(v))
        .toList();
  }

  void _validateResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ResponseException(response: response);
    }
  }
}
