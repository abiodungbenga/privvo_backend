import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Response successResponse(dynamic data, {int statusCode = HttpStatus.ok}) {
  final body = <String, dynamic>{'message': 'success!'};
  if (data != null) {
    body['data'] = data;
  }
  return Response.json(body: body, statusCode: statusCode);
}

Response errorResponse(
  String message, {
  dynamic data,
  int statusCode = HttpStatus.badRequest,
}) {
  final body = <String, dynamic>{'message': message};
  if (data != null) {
    body['data'] = data;
  }
  return Response.json(
    body: body,
    statusCode: statusCode,
  );
}

Response validationError(
  String message, {
  Map<String, dynamic>? errors,
  int statusCode = HttpStatus.unprocessableEntity,
}) {
  final body = <String, dynamic>{
    'message': message,
    'errors': errors ?? {},
  };

  return Response.json(
    body: body,
    statusCode: statusCode,
  );
}

Response authErrorResponse() => errorResponse('Auth error!', statusCode: 403);
