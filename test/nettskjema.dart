import 'dart:convert';
import 'package:http/http.dart' as http;

const String RESPONSE_SUCCESS = "success";

String enumToString(final o) => o.toString().split('.').last;



Future<dynamic> getPublicFormSpec(int nettskjemaId) async {
  final r = await http.get("https://nettskjema.no/answer/answer.json?formId=$nettskjemaId");
  final dynamic json = jsonDecode(r.body);
  if (json[enumToString(JsonFieldNames.status)] != RESPONSE_SUCCESS) {
    final message = json[enumToString(JsonFieldNames.message)];
    throw "error: $message";
  }
  return json;
}

enum JsonFieldNames {
  form,
  pages,
  elements,
  questions,
  externalQuestionId,
  questionId,
  message,
  status,
}

int external2internalElementId(dynamic json, String ext) {
  for (var page in json[enumToString(JsonFieldNames.form)][enumToString(JsonFieldNames.pages)]) {
    for (var element in page[enumToString(JsonFieldNames.elements)]) {
      for (var question in element[enumToString(JsonFieldNames.questions)]) {
        if (question[enumToString(JsonFieldNames.externalQuestionId)] == ext) {
          return question[enumToString(JsonFieldNames.questionId)];
        }
      }
    }
  }
  throw "key '$ext' not found";
}


 Map<String, int>  autoResolveKeys(final dynamic json, final List<String> extKeys, Map<String, int> int2extKeys) {
  extKeys.forEach( (e) {
    if (!int2extKeys.containsKey(e)) {
      print(e);
      int2extKeys[e] = external2internalElementId(json, e);
      print(int2extKeys);
    }
  });
  return int2extKeys;
}


Future<void> uploadTextFields(int nettskjemaId, final Map<String, int> int2extKeys, final Map<String, String> kv) async {
  var uri = Uri.parse("https://nettskjema.uio.no/answer/deliver.json?formId=$nettskjemaId&quizResultAsJson=true&elapsedTime=42");
  var request = http.MultipartRequest("POST", uri);
  kv.forEach( (k,v) {
    if (!int2extKeys.containsKey(k)) {
      throw "key '$k' not found in map";
    }
    int qId = int2extKeys[k];
    request.fields['answersAsMap[$qId].textAnswer'] = v;
  });
  var response = await request.send();
  if (response.statusCode != 200) {
    throw "response.statusCode";
  }
  var json = jsonDecode(await response.stream.bytesToString());
  if (json[enumToString(JsonFieldNames.status)] != RESPONSE_SUCCESS) {
    final message = json[enumToString(JsonFieldNames.message)];
    throw "response status $message";
  }
}


class NettSkjemaPublic {
  Map<String, int> _int2extKeys = Map<String, int>();
  dynamic _specJson;
  int nettskjemaId;

  NettSkjemaPublic({
    this.nettskjemaId,
  });

  Future<void> init() async {
    _specJson = await getPublicFormSpec(nettskjemaId);
  }
  
  Future<void> upload(final Map<String, String> kv) async {
    if (_specJson == null) {
      _specJson = await getPublicFormSpec(nettskjemaId);
    }
    _int2extKeys = autoResolveKeys(_specJson, kv.keys.toList(), _int2extKeys);
    await uploadTextFields(nettskjemaId, _int2extKeys, kv);
    
  }
}


void main() async {
  Map<String, String> testdata = {
    "user_id": "florian",
    "key": "florians key",
    "index": "florians index",
    "value": "florians value",
    "category": "florians category",
    "timestamp": DateTime.now().toUtc().toIso8601String(),
  };

  NettSkjemaPublic nsp = NettSkjemaPublic(nettskjemaId: 127682);
  await nsp.init();
  await nsp.upload(testdata);
}