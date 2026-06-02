import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:locked_notes_app/services/database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locked_notes_app/models/notes_model.dart';

class AddNoteScreen extends StatefulWidget {
  final NotesModel? note;
  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen>
    with SingleTickerProviderStateMixin {
  final db = DBHelper.instance;

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool _isSaving = false;
  bool _isLocked = false;
  bool _isFavorite = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
      _isLocked = widget.note!.isLocked;
      _isFavorite = widget.note!.isFavorite;
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      _showSnack(
        title.isEmpty ? 'Title cannot be empty' : 'Content cannot be empty',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        _showSnack('Session expired. Please log in again.', isError: true);
        return;
      }

      if (!_isEditing) {
        await db.createNote(
          NotesModel(
            title: title,
            content: content,
            isFavorite: _isFavorite,
            isLocked: _isLocked,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
          userId,
        );
      } else {
        await db.updateNote(
          NotesModel(
            id: widget.note!.id,
            title: title,
            content: content,
            isLocked: _isLocked,
            isFavorite: _isFavorite,
            createdAt: widget.note!.createdAt,
          ),
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Something went wrong. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Gradient background ──────────────────────────────────────────────
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF0A0A0A), Color(0xFF1A237E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Glow blobs ─────────────────────────────────────────────────
            Positioned(
              top: -60,
              left: -60,
              child: _GlowBlob(color: Colors.green.withOpacity(0.3), size: 250),
            ),
            Positioned(
              bottom: 40,
              right: -80,
              child: _GlowBlob(color: Colors.blue.withOpacity(0.2), size: 280),
            ),

            // ── Content ────────────────────────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    // ── Custom AppBar ──────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Back button
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _isEditing ? 'Edit Note' : 'New Note',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          // Favorite toggle
                          _AppBarIconButton(
                            icon: _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite
                                ? Colors.pinkAccent
                                : Colors.white54,
                            onTap: () =>
                                setState(() => _isFavorite = !_isFavorite),
                          ),
                          const SizedBox(width: 8),
                          // Lock toggle
                          _AppBarIconButton(
                            icon: _isLocked ? Icons.lock : Icons.lock_open,
                            color: _isLocked
                                ? Colors.greenAccent
                                : Colors.white54,
                            onTap: () => setState(() => _isLocked = !_isLocked),
                          ),
                        ],
                      ),
                    ),

                    // ── Form card ──────────────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1.2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status chips
                                    Row(
                                      children: [
                                        if (_isFavorite)
                                          _StatusChip(
                                            label: 'Favorite',
                                            icon: Icons.favorite,
                                            color: Colors.pinkAccent,
                                          ),
                                        if (_isFavorite && _isLocked)
                                          const SizedBox(width: 8),
                                        if (_isLocked)
                                          _StatusChip(
                                            label: 'Locked',
                                            icon: Icons.lock,
                                            color: Colors.greenAccent,
                                          ),
                                      ],
                                    ),
                                    if (_isFavorite || _isLocked)
                                      const SizedBox(height: 20),

                                    // Title label
                                    Text(
                                      'Title',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Title field
                                    TextField(
                                      controller: titleController,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Note title...',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.25),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),

                                    Divider(
                                      color: Colors.white.withOpacity(0.1),
                                      height: 24,
                                    ),

                                    // Content label
                                    Text(
                                      'Content',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Content field
                                    TextField(
                                      controller: contentController,
                                      maxLines: null,
                                      minLines: 10,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 15,
                                        height: 1.6,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Write your note here...',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.25),
                                          fontSize: 15,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Metadata row
                                    if (_isEditing)
                                      Text(
                                        'Last edited · ${_formatDate(widget.note!.createdAt)}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Save button ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isEditing
                                          ? Icons.check_circle_outline
                                          : Icons.save_outlined,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isEditing ? 'Update Note' : 'Save Note',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Frosted app bar icon button ───────────────────────────────────────────────
class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 18),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glow blob ─────────────────────────────────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.8,
            spreadRadius: size * 0.2,
          ),
        ],
      ),
    );
  }
}
