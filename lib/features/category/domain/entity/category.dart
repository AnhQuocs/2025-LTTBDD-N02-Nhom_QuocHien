import 'package:hive/hive.dart';
part 'category.g.dart';

@HiveType(typeId: 3)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  Category copyWith({String? id, String? name, String? icon}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}