import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

/*----------------------------------------------------------------------------*/

class NettskjemaPublic {
  final int nettskjemaId;
  Map<String, int>? _externalToInternalQuestionId;

  NettskjemaPublic({required this.nettskjemaId});

  Future<void> upload(Map<String, String> data) async {
    // resolve keys once
    _externalToInternalQuestionId ??= await getSchemaFieldsPub(nettskjemaId);
    // upload
    await uploadSchemaPub(
      nettskjemaId: nettskjemaId,
      fieldNames: _externalToInternalQuestionId!,
      data: data,
    );
  }
}

/*----------------------------------------------------------------------------*/

/// get all field names in nettskjema (with mapping to internal field ID)
/// errors: 
/// - Connection
/// - ServerResponse
/// - FormatException (JSON)
/// - MissingJsonField
/// - NettskjemaStatus
Future<Map<String, int>> getSchemaFieldsPub(int nettskjemaId) async {
  // obtain json from nettskjema server
  final r = await http.get(Uri.parse("https://nettskjema.no/answer/answer.json?formId=$nettskjemaId"));
  if (r.statusCode != HttpStatus.ok) {
    throw ServerResponseException("HTTP status code '${r.statusCode}'");
  }
  final dynamic json = jsonDecode(r.body);
  final jsonStatus = _getJsonFieldSafe(json, _enumToString(_JsonFieldNames.status));
  if (jsonStatus != _kNettskjemaResponseSuccess) {
    final message = json[_enumToString(_JsonFieldNames.message)];
    throw NettskjemaStatusException(message);
  }
  // lookup json fields to build map
  Map<String, int> m = Map<String, int>();
  final dynamic form = _getJsonFieldSafe(json, _enumToString(_JsonFieldNames.form));
  final dynamic pages = _getJsonFieldSafe(form, _enumToString(_JsonFieldNames.pages));
  for (var page in pages) {
    final dynamic elements = _getJsonFieldSafe(page, _enumToString(_JsonFieldNames.elements));
    for (var element in elements) {
      final dynamic questions = _getJsonFieldSafe(element, _enumToString(_JsonFieldNames.questions));
      for (var question in questions) {
        final String externalQuestionId = _getJsonFieldSafe(question, _enumToString(_JsonFieldNames.externalQuestionId));
        final int questionId = _getJsonFieldSafe(question, _enumToString(_JsonFieldNames.questionId));
        m[externalQuestionId] = questionId;
      }
    }
  }
  return m;
}

/*----------------------------------------------------------------------------*/

/// upload to a nettskjema
/// - FieldIdMatch
/// - Connection
/// - ServerResponse
/// - FormatException (JSON)
/// - MissingJsonField
/// - NettskjemaStatus
Future<void> uploadSchemaPub({
  required int nettskjemaId,
  required Map<String, int> fieldNames, 
  required Map<String, String> data
  }) async {
  assert(matchesExpectedSchemaFieldsPub(
    nettskjemaFields: fieldNames.keys.toList(), 
    expectedFields: data.keys.toList())
  ); //throws exeption if false
  var uri = Uri.parse("https://nettskjema.no/answer/deliver.json?formId=$nettskjemaId&quizResultAsJson=true&elapsedTime=42");
  var request = http.MultipartRequest("POST", uri);
  data.forEach( (k,v) {
    final int questionId = fieldNames[k]!;
    request.fields['answersAsMap[$questionId].textAnswer'] = v;
  });
  var response = await request.send();
  if (response.statusCode != HttpStatus.ok) {
    throw ServerResponseException("HTTP status code '${response.statusCode}'");
  }
  var json = jsonDecode(await response.stream.bytesToString());
  final jsonStatus = _getJsonFieldSafe(json, _enumToString(_JsonFieldNames.status));
  if (jsonStatus != _kNettskjemaResponseSuccess) {
    final message = _getJsonFieldSafe(json, _enumToString(_JsonFieldNames.message));
    throw NettskjemaStatusException(message);
  }
}

/*----------------------------------------------------------------------------*/

/// check if fields in a nettskjema match expected fields  - 1:1 and no additional fields
/// - FieldIdMatch
bool matchesExpectedSchemaFieldsPub({
    required List<String> nettskjemaFields, 
    required List<String> expectedFields
  }) {
  final setn = nettskjemaFields.toSet();
  final sete = expectedFields.toSet();
  final r = SetEquality().equals(nettskjemaFields.toSet(), expectedFields.toSet());
  if (!r) {
    Set<String> missing = setn.difference(sete);
    missing.addAll( sete.difference(setn));
    throw FieldIdMatchException("mismatching form fields: ${missing.join(",")}");
  }
  return r;
}

/*----------------------------------------------------------------------------*/

enum _JsonFieldNames {
  form,
  pages,
  elements,
  questions,
  externalQuestionId,
  questionId,
  message,
  status,
}

/*----------------------------------------------------------------------------*/

const String _kNettskjemaResponseSuccess = "success";

/*----------------------------------------------------------------------------*/

String _enumToString(final o) => o.toString().split('.').last;

/*----------------------------------------------------------------------------*/

dynamic _getJsonFieldSafe(final dynamic json, String fieldName) {
  final r = json[fieldName];
  if (r == null) {
    throw MissingJsonFieldException("received JSON does not contain field '$fieldName'\n${json.toString()}");
  }
  return r;
}
