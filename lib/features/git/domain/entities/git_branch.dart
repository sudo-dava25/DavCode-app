class GitBranch {
  final String name;
  final bool isCurrent;
  final bool isRemote;

  const GitBranch({required this.name, required this.isCurrent, this.isRemote = false});
}
