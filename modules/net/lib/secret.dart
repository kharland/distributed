import 'dart:convert';

class Secret {
  static const acceptAny = const Secret._any();

  final bool _matchAny;
  final String _value;

  const Secret._any()
      : _value = '',
        _matchAny = true;

  const Secret(this._value) : _matchAny = false;

  factory Secret.fromString(String json) =>
      new Secret((JSON.decode(json) as Map<String, String>)['secret']);

  @override
  String toString() => JSON.encode(_toJson());

  bool matches(Object other) =>
      other is Secret &&
      (other._value == _value || _matchAny || other._matchAny);

  Map<String, String> _toJson() => <String, String>{'secret': _value};
}
