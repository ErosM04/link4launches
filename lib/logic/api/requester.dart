import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Class used to perform basuic http requests by more complex classes. Uses the ``http`` package.
class Requester {
  /// The link used to perfrom the requests.
  final String link;

  const Requester({required this.link});

  /// Performs a basic ``get`` request.
  ///
  /// #### Parameters:
  /// - ``String? fullLink`` : if this link is not null is used as the link to perform the get request (ignoring both ``[link]``)
  /// and ``[parameters]``;
  /// - ``String parameters`` : the parameters to concatenate to ``[link]``;
  /// - ``Future Function(http.Response res) onSuccess`` : the function to execute when the request is successful (status code is
  /// 200), the ``[http.Response]`` obj with all the data is also passed as a parameter to be used;
  /// - ``required void Function(...) onError,`` : the function to execute
  /// when the request fails (status code is different from 200):
  ///   - ``int statusCode`` : the status code of the request;
  ///   - ``String? reasonPhrase`` : the reson of the status code;
  ///   - ``String responseBody`` : the body containg the error data;
  /// - ``VoidCallback? onException`` : the function to execute when an ``[Exception]`` occurs while performing the request or
  /// executing the 2 previous function.
  Future<void> get({
    String? fullLink,
    required String parameters,
    required Future Function(http.Response res) onSuccess,
    required void Function(
      int statusCode,
      String? reasonPhrase,
      String responseBody,
    ) onError,
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
