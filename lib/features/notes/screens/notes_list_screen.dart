import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:locked_notes_app/core/routes/app_routes.dart';
import 'package:locked_notes_app/models/notes_model.dart';
import 'package:locked_notes_app/services/database/db_helper.dart';
import 'package:locked_notes_app/services/session_service.dart';
import 'package:locked_notes_app/widgets/app_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen>
    with SingleTickerProviderStateMixin {
  List<NotesModel> _allNotes = [];
  List<NotesModel> _filteredNotes = [];
  final _searchController = TextEditingController();
  bool _isLoading = true;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;
    final notes = await DBHelper.instance.getNotes(userId);
    if (!mounted) return;
    setState(() {
      _allNotes = notes;
      _filteredNotes = notes;
      _isLoading = false;
    });
  }

  void _searchNotes(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filteredNotes = q.isEmpty
          ? _allNotes
          : _allNotes.where((n) {
              return n.title.toLowerCase().contains(q) ||
                  n.content.toLowerCase().contains(q);
            }).toList();
    });
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _openNote(NotesModel note) async {
    if (note.isLocked) {
      final entered = await showPinDialog(
        context,
        title: 'Enter PIN',
        actionLabel: 'Unlock',
      );
      if (!mounted || entered == null) return;
      final saved = await SessionService().getPin();
      if (entered != saved) {
        _showSnack('Incorrect PIN', isError: true);
        return;
      }
    }
    if (!mounted) return;
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addNote,
      arguments: note,
    );
    if (result == true) _loadNotes();
  }

  Future<void> _toggleLock(NotesModel note) async {
    final session = SessionService();
    final savedPin = await session.getPin();

    if (!note.isLocked) {
      String? pinToUse = savedPin;
      if (pinToUse == null || pinToUse.isEmpty) {
        pinToUse = await showPinDialog(
          context,
          title: 'Set PIN',
          actionLabel: 'Save',
        );
        if (!mounted || pinToUse == null || pinToUse.isEmpty) return;
        await session.savePin(pinToUse);
      }
      await DBHelper.instance.updateNote(note.copyWith(isLocked: true));
    } else {
      final entered = await showPinDialog(
        context,
        title: 'Enter PIN',
        actionLabel: 'Unlock',
      );
      if (!mounted || entered == null) return;
      if (entered != savedPin) {
        _showSnack('Incorrect PIN', isError: true);
        return;
      }
      await DBHelper.instance.updateNote(note.copyWith(isLocked: false));
    }
    _loadNotes();
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Delete Note',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This note will be permanently deleted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white54,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) {
                      _searchNotes(v);
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchNotes('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Notes count
          if (!_isLoading && _allNotes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Text(
                    '${_filteredNotes.length} '
                    'note${_filteredNotes.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? _buildLoading()
                : _filteredNotes.isEmpty
                ? _buildEmpty()
                : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.greenAccent.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notes...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final isSearch = _searchController.text.isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Icon(
              isSearch ? Icons.search_off : Icons.note_add_outlined,
              color: Colors.white.withValues(alpha: 0.3),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearch ? 'No matching notes' : 'No notes yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearch
                ? 'Try a different search term.'
                : 'Tap + to create your first note.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: note.isFavorite
                        ? Colors.pinkAccent.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.12),
                    width: note.isFavorite ? 1.5 : 1.0,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _openNote(note),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                note.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (note.isLocked)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.lock,
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.8,
                                  ),
                                  size: 15,
                                ),
                              ),
                            if (note.isFavorite)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.pinkAccent,
                                  size: 15,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Content preview
                        Text(
                          note.isLocked ? '••••••••••••' : note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Footer row
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: 11,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(note.createdAt),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 11,
                              ),
                            ),
                            const Spacer(),
                            _NoteAction(
                              icon: note.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: note.isFavorite
                                  ? Colors.pinkAccent
                                  : Colors.white38,
                              onTap: () async {
                                await DBHelper.instance.updateNote(
                                  note.copyWith(isFavorite: !note.isFavorite),
                                );
                                _loadNotes();
                              },
                            ),
                            _NoteAction(
                              icon: note.isLocked
                                  ? Icons.lock
                                  : Icons.lock_open,
                              color: note.isLocked
                                  ? Colors.greenAccent
                                  : Colors.white38,
                              onTap: () => _toggleLock(note),
                            ),
                            _NoteAction(
                              icon: Icons.delete_outline,
                              color: Colors.redAccent.withValues(alpha: 0.7),
                              onTap: () async {
                                final ok = await _confirmDelete();
                                if (ok) {
                                  await DBHelper.instance.deleteNote(note.id!);
                                  _loadNotes();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Compact note action button ────────────────────────────────────────────────
class _NoteAction extends StatelessWidget {
  const _NoteAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
