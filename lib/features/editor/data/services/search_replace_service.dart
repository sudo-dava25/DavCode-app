/// One search match: the start offset and length within the document text.
class SearchMatch {
  final int start;
  final int end;
  const SearchMatch(this.start, this.end);
}

/// Implements "Search and replace" over a single document's text.
class SearchReplaceService {
  List<SearchMatch> findAll(String text, String query, {bool caseSensitive = false}) {
    if (query.isEmpty) return [];
    final haystack = caseSensitive ? text : text.toLowerCase();
    final needle = caseSensitive ? query : query.toLowerCase();
    final matches = <SearchMatch>[];
    var index = 0;
    while (true) {
      final found = haystack.indexOf(needle, index);
      if (found == -1) break;
      matches.add(SearchMatch(found, found + needle.length));
      index = found + needle.length;
    }
    return matches;
  }

  String replaceAll(String text, String query, String replacement, {bool caseSensitive = false}) {
    if (query.isEmpty) return text;
    if (caseSensitive) {
      return text.replaceAll(query, replacement);
    }
    final pattern = RegExp(RegExp.escape(query), caseSensitive: false);
    return text.replaceAll(pattern, replacement);
  }

  /// Replaces only the match at [match] and returns the new text plus the
  /// new cursor offset (end of the inserted replacement).
  (String, int) replaceOne(String text, SearchMatch match, String replacement) {
    final newText = text.replaceRange(match.start, match.end, replacement);
    return (newText, match.start + replacement.length);
  }
}
