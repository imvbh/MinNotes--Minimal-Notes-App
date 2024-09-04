import 'package:isar/isar.dart';

// used to generate file
// run: dart run build_runner build
part 'note.g.dart';

@Collection()
class Note {
  Id id = Isar.autoIncrement;
  late String title;
  late String description;
  late bool isHidden;
  late DateTime createdAt;
  late DateTime updatedAt;

  Note({
    this.isHidden = false, // Initialize as needed
  });
}
