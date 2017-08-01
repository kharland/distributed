import 'dart:async';
import 'package:build_runner/build_runner.dart';
import 'package:built_value_generator/built_value_generator.dart';
import 'package:source_gen/source_gen.dart';

Future<Null> main() async {
  await build(
      new PhaseGroup.singleAction(
          new GeneratorBuilder([new BuiltValueGenerator()]),
          new InputSet('distributed.objects', const ['lib/**.dart'])),
      deleteFilesByDefault: true).then((BuildResult buildResult) {
    print('Generated ${buildResult.outputs}');
  });
}
