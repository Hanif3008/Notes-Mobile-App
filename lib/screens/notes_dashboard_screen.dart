import 'package:material_ui/material_ui.dart';
import '../models/note_model.dart';
import '../services/geocoding_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/delete_confirm_dialog.dart';

class NotesDashboardScreen extends StatefulWidget {
  final VoidCallback onAddNote;
  final ValueChanged<NoteModel> onEditNote;
  final VoidCallback onOpenProfile;

  const NotesDashboardScreen({
    super.key,
    required this.onAddNote,
    required this.onEditNote,
    required this.onOpenProfile,
  });

  @override
  State<NotesDashboardScreen> createState() => _NotesDashboardScreenState();
}

class _NotesDashboardScreenState extends State<NotesDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.user!;
    final notes = state.filteredNotes;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAddNote,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Tambah Catatan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      body: Column(
        children: [
          AppTopBar(
            pageTitle: 'Catatan Saya',
            userInitial: initial,
            avatarUrl: user.avatar,
            onRefreshTap: () => state.fetchNotes(),
            onAvatarTap: widget.onOpenProfile,
          ),
          if (state.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppTheme.primary,
              backgroundColor: AppTheme.tertiaryTint,
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: state.fetchNotes,
              color: AppTheme.primary,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 96),
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFD6F1F6),
                          AppTheme.surfaceBase,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Halo, ${user.name} 👋',
                                        style: const TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          'ID #${user.userId}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${state.totalCount} catatan tersimpan',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        AuraCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppTheme.tertiaryTint,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.insights_rounded,
                                      color: AppTheme.primaryDark,
                                      size: 19,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Ringkasan Aktivitas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _SummaryStatBox(
                                    label: 'Total Catatan',
                                    value: '${state.totalCount}',
                                    subtitle: 'Tersimpan',
                                  ),
                                  const SizedBox(width: 8),
                                  _SummaryStatBox(
                                    label: 'Rata-rata',
                                    value: '${state.averageStatus}%',
                                    subtitle: 'Kelengkapan',
                                  ),
                                  const SizedBox(width: 8),
                                  _SummaryStatBox(
                                    label: 'Selesai',
                                    value: '${state.completedCount}',
                                    subtitle: 'Catatan (>50%)',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        _SyncStatusCard(
                          pendingCount: state.pendingSyncCount,
                          isSyncing: state.isSyncing,
                          isOffline: state.isOffline,
                          onSyncTap: () async {
                            final result = await state.syncNotes();
                            if (!context.mounted) return;
                            final msg = result.hasErrors
                                ? 'Sinkronisasi selesai: ${result.syncedCount} berhasil, ${result.failedCount} gagal (periksa koneksi).'
                                : result.syncedCount > 0
                                    ? '${result.syncedCount} catatan berhasil disinkronkan ke MockAPI.'
                                    : 'Semua catatan sudah tersinkron dengan MockAPI.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: state.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: 'Cari judul atau isi catatan...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppTheme.textSecondary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon:
                                      const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    state.setSearchQuery('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _FilterChipPill(
                          label: 'Semua (${state.totalCount})',
                          selected: state.filter == NoteFilter.all,
                          onTap: () => state.setFilter(NoteFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChipPill(
                          label: 'Selesai (>50%)',
                          selected: state.filter == NoteFilter.completed,
                          onTap: () => state.setFilter(NoteFilter.completed),
                        ),
                        const SizedBox(width: 8),
                        _FilterChipPill(
                          label: 'Berjalan (${state.inProgressCount})',
                          selected: state.filter == NoteFilter.inProgress,
                          onTap: () => state.setFilter(NoteFilter.inProgress),
                        ),
                      ],
                    ),
                  ),

                  // Count & Sort Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Menampilkan ${notes.length} dari ${state.totalCount} catatan',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<NoteSort>(
                            value: state.sort,
                            isDense: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: AppTheme.textPrimary,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDark,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: NoteSort.newest,
                                child: Text('Urutan Terbaru'),
                              ),
                              DropdownMenuItem(
                                value: NoteSort.highestStatus,
                                child: Text('Progres Tertinggi'),
                              ),
                              DropdownMenuItem(
                                value: NoteSort.title,
                                child: Text('Judul A-Z'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) state.setSort(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (notes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 48,
                            color: AppTheme.textMuted.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Belum ada catatan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...notes.map(
                      (note) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _NoteCard(
                          note: note,
                          onTap: () => widget.onEditNote(note),
                          onDelete: () async {
                            final confirmed = await showDeleteNoteDialog(
                              context,
                              note: note,
                              ownerName: user.name,
                            );
                            if (confirmed) {
                              await state.deleteNote(note.noteId);
                            }
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusCard extends StatelessWidget {
  final int pendingCount;
  final bool isSyncing;
  final bool isOffline;
  final VoidCallback onSyncTap;

  const _SyncStatusCard({
    required this.pendingCount,
    required this.isSyncing,
    required this.isOffline,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPending = pendingCount > 0;
    final badgeColor = hasPending
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFD1FAE5);
    final textColor = hasPending
        ? const Color(0xFFB45309)
        : const Color(0xFF047857);

    return AuraCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasPending
                      ? Icons.sync_problem_rounded
                      : Icons.cloud_done_rounded,
                  color: textColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Penyimpanan Offline (SQLite)',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      hasPending
                          ? '$pendingCount catatan menunggu sinkronisasi'
                          : isOffline
                              ? 'Mode offline • Data dimuat dari SQLite'
                              : 'Semua catatan tersinkron dengan MockAPI',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: hasPending ? textColor : AppTheme.textSecondary,
                        fontWeight:
                            hasPending ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isSyncing ? null : onSyncTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryDark,
              side: const BorderSide(color: AppTheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync_rounded, size: 18),
            label: Text(
              isSyncing ? 'Menyinkronkan...' : 'Sinkronkan ke MockAPI',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatBox extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const _SummaryStatBox({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceBase,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AuraCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.softBlueBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        note.noteId.startsWith('local_')
                            ? 'Lokal (SQLite)'
                            : 'Catatan #${note.noteId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ),
                    StatusPillBadge.forStatus(note.status),
                    if (!note.isSynced)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 11,
                              color: Color(0xFFB45309),
                            ),
                            SizedBox(width: 3),
                            Text(
                              'Offline',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                onSelected: (value) {
                  if (value == 'edit') onTap();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Lihat & Ubah'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Hapus Catatan',
                      style: TextStyle(color: AppTheme.critical),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            note.description,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppTheme.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progres Catatan',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${note.status}%',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: note.status / 100,
              minHeight: 6,
              backgroundColor: AppTheme.softBlueBg,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryDark),
            ),
          ),
          const SizedBox(height: 12),
          _LocationAddressBadge(
            latitude: note.latitude,
            longitude: note.longitude,
          ),
          const SizedBox(height: 8),
          Text(
            'Dibuat: ${formatFriendlyDate(note.createdAt)}  •  Diubah: ${formatFriendlyDate(note.updatedAt)}',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationAddressBadge extends StatefulWidget {
  final String latitude;
  final String longitude;

  const _LocationAddressBadge({
    required this.latitude,
    required this.longitude,
  });

  @override
  State<_LocationAddressBadge> createState() => _LocationAddressBadgeState();
}

class _LocationAddressBadgeState extends State<_LocationAddressBadge> {
  String? _address;

  @override
  void initState() {
    super.initState();
    _resolveAddress();
  }

  @override
  void didUpdateWidget(covariant _LocationAddressBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _address = null;
      _resolveAddress();
    }
  }

  Future<void> _resolveAddress() async {
    final cached = GeocodingService.getCachedAddress(
      widget.latitude,
      widget.longitude,
    );
    if (cached != null) {
      _address = cached;
      return;
    }

    final resolved = await GeocodingService.getAddressFromCoordinates(
      widget.latitude,
      widget.longitude,
    );
    if (!mounted) return;
    if (resolved != null && resolved.isNotEmpty) {
      setState(() => _address = resolved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords =
        widget.latitude.trim().isNotEmpty && widget.longitude.trim().isNotEmpty;
    final label = _address ??
        (hasCoords
            ? '${widget.latitude}, ${widget.longitude}'
            : 'Lokasi belum diatur');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBase,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 14,
            color: AppTheme.primaryDark,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
