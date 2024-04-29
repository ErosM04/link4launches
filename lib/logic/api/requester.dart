import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Used to make http requests.
class Requester {
  /// The link of the api.
  final String link;

  const Requester({required this.link});

  /// Performs a basic get request.
  Future<void> get({
    String? fullLink,
    required String parameters,
    required Future onSuccess(http.Response res),
    required void onError(
      int statusCode,
      String? reasonPhrase,
      String responseBody,
    ),
    VoidCallback? onException,
  }) async {
    try {
      var response =
          await http.get(Uri.parse((fullLink) ?? '$link$parameters'));

      if (response.statusCode == 200) {
        await onSuccess(response);
      } else {
        onError(response.statusCode, response.reasonPhrase, response.body);
      }
    } catch (e) {
      (onException != null) ? onException() : null;
    }
  }
}
