import 'dart:async';
import 'package:build_runner/build_runner.dart';
import 'package:built_value_generator/built_value_generator.dart';
import 'package:source_gen/source_gen.dart';

Future main() async {
  final phaseGroup = new PhaseGroup.singleAction(
      new GeneratorBuilder([new BuiltValueGenerator()]),
      new InputSet('distributed.objects', const ['lib/peer.dart']));
  await for (var buildResult in watch(phaseGroup)) {
    print('Generated ${buildResult.outputs}');
  }
}
