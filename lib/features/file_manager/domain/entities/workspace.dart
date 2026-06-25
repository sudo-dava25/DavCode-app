import 'package:equatable/equatable.dart';

/// A workspace = a project root the user opened, persisted so it can be
/// reopened later ("Workspace system" / "Recent projects" / "Open project").
class Workspace extends Equatable {
  final String id;
  final String rootPath;
  final String name;
  final DateTime lastOpened;

  const Workspace({
    required this.id,
    required this.rootPath,
    required this.name,
    required this.lastOpened,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'rootPath': rootPath,
        'name': name,
        'lastOpened': lastOpened.toIso8601String(),
      };

  factory Workspace.fromMap(Map map) => Workspace(
        id: map['id'] as String,
        rootPath: map['rootPath'] as String,
        name: map['name'] as String,
        lastOpened: DateTime.parse(map['lastOpened'] as String),
      );

  @override
  List<Object?> get props => [id, rootPath, lastOpened];
}
