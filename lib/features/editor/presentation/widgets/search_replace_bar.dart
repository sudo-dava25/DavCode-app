import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/code_editor_controller.dart';
import '../../data/services/search_replace_service.dart';

/// Implements "Search and replace" as a collapsible bar above the editor.
class SearchReplaceBar extends StatefulWidget {
  final CodeEditorController controller;
  final VoidCallback onClose;

  const SearchReplaceBar({super.key, required this.controller, required this.onClose});

  @override
  State<SearchReplaceBar> createState() => _SearchReplaceBarState();
}

class _SearchReplaceBarState extends State<SearchReplaceBar> {
  final _searchCtrl = TextEditingController();
  final _replaceCtrl = TextEditingController();
  List<SearchMatch> _matches = [];
  int _currentIndex = -1;
  bool _showReplace = false;

  void _runSearch() {
    setState(() {
      _matches = widget.controller.search.findAll(widget.controller.text, _searchCtrl.text);
      _currentIndex = _matches.isEmpty ? -1 : 0;
    });
    _selectCurrent();
  }

  void _selectCurrent() {
    if (_currentIndex < 0 || _currentIndex >= _matches.length) return;
    final m = _matches[_currentIndex];
    widget.controller.selection = TextSelection(baseOffset: m.start, extentOffset: m.end);
  }

  void _next() {
    if (_matches.isEmpty) return;
    setState(() => _currentIndex = (_currentIndex + 1) % _matches.length);
    _selectCurrent();
  }

  void _prev() {
    if (_matches.isEmpty) return;
    setState(() => _currentIndex = (_currentIndex - 1 + _matches.length) % _matches.length);
    _selectCurrent();
  }

  void _replaceCurrent() {
    if (_currentIndex < 0 || _currentIndex >= _matches.length) return;
    final (newText, newOffset) = widget.controller.search.replaceOne(
      widget.controller.text,
      _matches[_currentIndex],
      _replaceCtrl.text,
    );
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
    _runSearch();
  }

  void _replaceAll() {
    final newText = widget.controller.search.replaceAll(
      widget.controller.text,
      _searchCtrl.text,
      _replaceCtrl.text,
    );
    widget.controller.text = newText;
    _runSearch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _replaceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceElevated,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Search…',
                    isDense: true,
                    prefixIcon: Icon(Icons.search, size: 18),
                  ),
                  onChanged: (_) => _runSearch(),
                  onSubmitted: (_) => _next(),
                ),
              ),
              Text(
                _matches.isEmpty ? '0/0' : '${_currentIndex + 1}/${_matches.length}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              IconButton(icon: const Icon(Icons.keyboard_arrow_up, size: 20), onPressed: _prev),
              IconButton(icon: const Icon(Icons.keyboard_arrow_down, size: 20), onPressed: _next),
              IconButton(
                icon: Icon(_showReplace ? Icons.expand_less : Icons.expand_more, size: 20),
                onPressed: () => setState(() => _showReplace = !_showReplace),
              ),
              IconButton(icon: const Icon(Icons.close, size: 20), onPressed: widget.onClose),
            ],
          ),
          if (_showReplace)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replaceCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Replace…',
                      isDense: true,
                      prefixIcon: Icon(Icons.find_replace, size: 18),
                    ),
                  ),
                ),
                TextButton(onPressed: _replaceCurrent, child: const Text('Replace')),
                TextButton(onPressed: _replaceAll, child: const Text('Replace All')),
              ],
            ),
        ],
      ),
    );
  }
}
