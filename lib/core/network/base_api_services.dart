abstract class BaseApiServices {
  Future<dynamic> getApiResponse(String url, {Map<String, String> headers});

  Future<dynamic> postApiResponse(
    String url,
    dynamic data, {
    Map<String, String> headers,
  });
}
