import 'package:meta/meta.dart';

/// A template for matching HTTP request paths.
///
/// Templates may specify parameters which can be parsed via [parseArguments].
/// Templates have a specific format and violating the format may cause each
/// method in this class to have unexpected behavior. The format, in BNF is:
///
///    template = '/' segments
///             | '/'
///
///    segments = segments segment
///             | segment
///
///     segment = ':' string
///             | string
///
///      string = [a-z]+
class RequestTemplate {
  static final _segmentRegex = new RegExp(r':?[a-z]+');

  final String template;

  @literal
  const RequestTemplate(this.template);

  /// Returns true iff [request] matches [template].
  bool matches(String request) {
    var templateSegments = Uri.parse(template).pathSegments;
    var requestSegments = Uri.parse(request).pathSegments;
    var argPositions = computeArgPositions(template);

    if (templateSegments.length > requestSegments.length ||
        request.isEmpty ||
        !request.startsWith('/')) {
      return false;
    }

    for (int i = 0; i < templateSegments.length; i++) {
      var tSeg = templateSegments[i];
      var rSeg = requestSegments[i];

      if (argPositions.contains(i)) {
        // Disallow empty-string arguments
        if (rSeg.isEmpty) {
          return false;
        }
      } else if (tSeg != rSeg) {
        return false;
      }
    }

    return true;
  }

  /// Parses the arguments specified in [request] into a `Map<String, String>`.
  ///
  /// If this template has no arguments or [matches]([template], [request]) is
  /// false, the empty map is returned.
  Map<String, String> parseArguments(String request) {
    var templateSegments = Uri.parse(template).pathSegments;
    var requestSegments = Uri.parse(request).pathSegments;
    var argPositions = computeArgPositions(template);

    if (!matches(request)) {
      return <String, String>{};
    }

    return new Map<String, String>.fromIterable(argPositions,
        // Skip leading colon.
        key: (int pos) => templateSegments[pos].substring(1),
        value: (int pos) => requestSegments[pos]);
  }

  /// Returns a list of the positions of the path segments that make up the url
  /// parameters for [template].
  ///
  /// If template contains no parameters or is incorrectly formatted, the empty
  /// list is returned.
  @visibleForTesting
  static List<int> computeArgPositions(String template) {
    const failed = const <int>[];

    if (!(template.startsWith('/') && template.contains(':'))) {
      return failed;
    }

    var segments = Uri.parse(template).pathSegments;
    var positions = <int>[];

    // Make sure every url segment is comprised of only lowercase letters with an
    // optional leading colon.
    for (int i = 0; i < segments.length; i++) {
      var segment = segments[i];
      if (_segmentRegex.stringMatch(segment) != segment) {
        return failed;
      } else if (segment.startsWith(':')) {
        positions.add(i);
      }
    }
    return positions;
  }
}
