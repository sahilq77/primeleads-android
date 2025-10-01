class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  HttpException(this.message, this.statusCode);
}

class ParseException implements Exception {
  final String message;
  ParseException(this.message);
}
