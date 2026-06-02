import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:locked_notes_app/models/notes_model.dart';
import 'package:locked_notes_app/services/database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockedNotesScreen extends StatefulWidget {
  const LockedNotesScreen({super.key});

  @override
  State<LockedNotesScreen> createState() => _LockedNotesScreenState();
}

class _LockedNotesScreenState extends State<LockedNotesScreen>
    with SingleTickerProviderStateMixin {
  List<NotesModel> lockedNotes = [];
  bool _isLoading = true;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    loadLockedNotes();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void loadLockedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    final db = DBHelper.instance;
    final notes = await db.getLockedNotes(userId);
    if (!mounted) return;
    setState(() {
      lockedNotes = notes;
      _isLoading = false;
    });
  }

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // ── Glow blobs ───────────────────────────────────────────────
            Positioned(
              top: -70,
              right: -60,
              child: _GlowBlob(
                color: Colors.green.withOpacity(0.28),
                size: 260,
              ),
            ),
            Positioned(
              bottom: 40,
              left: -80,
              child: _GlowBlob(color: Colors.blue.withOpacity(0.2), size: 300),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Custom AppBar ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Back button
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.07),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.12),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Lock icon badge
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.35),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Colors.greenAccent,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),

                                const Expanded(
                                  child: Text(
                                    'Locked Notes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),

                                // Notes count badge
                                if (!_isLoading)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.35),
                                      ),
                                    ),
                                    child: Text(
                                      '${lockedNotes.length}',
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Body ────────────────────────────────────────────
                    Expanded(
                      child: _isLoading
                          ? _buildLoading()
                          : lockedNotes.isEmpty
                          ? _buildEmpty()
                          : _buildList(),
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

  // ── Loading state ──────────────────────────────────────────────────────────
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
              color: Colors.greenAccent.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading locked notes...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.lock_open_outlined,
              color: Colors.white.withOpacity(0.3),
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Locked Notes',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lock a note to keep it private here.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Notes list ─────────────────────────────────────────────────────────────
  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: lockedNotes.length,
      itemBuilder: (context, index) {
        final note = lockedNotes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.13)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.greenAccent,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 10,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(note.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                            ),
                          ),
                          if (note.isFavorite) ...[
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.favorite,
                              size: 11,
                              color: Colors.pinkAccent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Favorite',
                              style: TextStyle(
                                color: Colors.pinkAccent.withOpacity(0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white24,
                    size: 20,
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
