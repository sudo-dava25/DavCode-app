class GitCommit {
  final String hash;
  final String author;
  final String message;
  final DateTime date;

  const GitCommit({
    required this.hash,
    required this.author,
    required this.message,
    required this.date,
  });
}
