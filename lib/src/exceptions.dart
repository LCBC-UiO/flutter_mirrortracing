class _NettskjemaExceptionBase implements Exception {
  final String message;

  _NettskjemaExceptionBase([this.message = ""]);
  
  String toString() {
    return "Nettskjema error - $message";
  }
}

/*----------------------------------------------------------------------------*/

class FieldIdMatchException extends _NettskjemaExceptionBase {
  FieldIdMatchException([String s = ""]) : super(s);
}

/*----------------------------------------------------------------------------*/

class ServerResponseException extends _NettskjemaExceptionBase {
  ServerResponseException([String s = ""]) : super(s);
}

/*----------------------------------------------------------------------------*/

class NettskjemaStatusException extends _NettskjemaExceptionBase {
  NettskjemaStatusException([String s = ""]) : super(s);
}

/*----------------------------------------------------------------------------*/

class MissingJsonFieldException extends _NettskjemaExceptionBase {
  MissingJsonFieldException([String s = ""]) : super(s);
}