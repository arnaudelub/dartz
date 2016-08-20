library streaming_io_example;

import 'combinators.dart';
import 'dart:io';

main() async {

  final pathToThisFile = Platform.script.toFilePath();

  // Construct Conveyor that:
  // 1. Reads lines from this file
  // 2. Trims leading and trailing whitespace
  // 3, 4. Finds single line comments and removes consecutive duplicates
  // 3, 4. Finds single line comments and removes consecutive duplicates
  // 5. Stops after five comments are consumed
  final firstFiveCommentsInThisFile = fileLines(pathToThisFile)
      .map((line) => line.trim())
      .filter((line) => line.startsWith("//"))
      .pipe(skipDuplicates())
      .take(5);

  // This is the sixth comment. It might never be read from the file,
  // since the Conveyor finishes as soon as the fifth comment is consumed.
  // The file will be closed as soon as the Conveyor finishes.

  await dump(firstFiveCommentsInThisFile);

  // Conveyors are pure values, and can safely be reused:
  await dump(firstFiveCommentsInThisFile);

  // ...and composed further:
  await dump(firstFiveCommentsInThisFile.pipe(toUppercase));

}
