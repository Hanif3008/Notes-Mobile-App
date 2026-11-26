import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import '../models/note_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/delete_confirm_dialog.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteModel? note;
  final VoidCallback onOpenProfile;

  const EditNoteScreen({
    super.key,
    this.note,
    required this.onOpenProfile,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  static const double _defaultLat = -6.2088;
  static const double _defaultLng = 106.8456;

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final MapController _mapController;

  late int _status;
  late double _mapLat;
  late double _mapLng;
  NoteModel? _loadedNote;
  bool _fetchingDetail = false;
  bool _detectingGps = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final n = widget.note;
    _loadedNote = n;
    _titleController = TextEditingController(text: n?.title ?? '');
    _descController = TextEditingController(text: n?.description ?? '');
    _latController = TextEditingController(text: n?.latitude ?? '');
    _lngController = TextEditingController(text: n?.longitude ?? '');
    _status = n?.status ?? 50;
    _mapLat = double.tryParse(n?.latitude ?? '') ?? _defaultLat;
    _mapLng = double.tryParse(n?.longitude ?? '') ?? _defaultLng;
    _mapController = MapController();

    if (n != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDetailById(n.noteId);
      });
    }
  }

  Future<void> _loadDetailById(String noteId) async {
    setState(() => _fetchingDetail = true);
    final fresh = await AppStateScope.of(context).getNoteById(noteId);
    if (!mounted) return;
    setState(() {
      _fetchingDetail = false;
      if (fresh != null) {
        _loadedNote = fresh;
        _titleController.text = fresh.title;
        _descController.text = fresh.description;
        _latController.text = fresh.latitude;
        _lngController.text = fresh.longitude;
        _status = fresh.status;
        final parsedLat = double.tryParse(fresh.latitude);
        final parsedLng = double.tryParse(fresh.longitude);
        if (parsedLat != null && parsedLng != null) {
          _mapLat = parsedLat;
          _mapLng = parsedLng;
          _mapController.move(LatLng(_mapLat, _mapLng), 14);
        }
      }
    });
  }

  Future<void> _detectGps() async {
    setState(() => _detectingGps = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          await showStatusPopupDialog(
            context,
            isSuccess: false,
            title: 'GPS Tidak Aktif',
            message: 'Aktifkan layanan lokasi pada perangkat Anda.',
            buttonText: 'Mengerti',
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          await showStatusPopupDialog(
            context,
            isSuccess: false,
            title: 'Izin Lokasi Ditolak',
            message: 'Izinkan akses lokasi agar koordinat dapat dideteksi.',
            buttonText: 'Mengerti',
          );
        }
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (pos == null) {
        throw Exception('Lokasi tidak ditemukan');
      }
      if (!mounted) return;
      _updateCoordinates(pos.latitude, pos.longitude);
    } catch (_) {
      if (mounted) {
        await showStatusPopupDialog(
          context,
          isSuccess: false,
          title: 'Lokasi Tidak Tersedia',
          message: 'Tidak dapat membaca GPS saat ini. Anda bisa mengetuk peta untuk memilih titik lokasi.',
          buttonText: 'OK',
        );
      }
    } finally {
      if (mounted) setState(() => _detectingGps = false);
    }
  }

  void _updateCoordinates(double lat, double lng) {
    setState(() {
      _mapLat = lat;
      _mapLng = lng;
      _latController.text = lat.toStringAsFixed(6);
      _lngController.text = lng.toStringAsFixed(6);
    });
    _mapController.move(LatLng(lat, lng), 15);
  }

  void _syncMapFromText() {
    final parsedLat = double.tryParse(_latController.text.trim());
    final parsedLng = double.tryParse(_lngController.text.trim());
    if (parsedLat != null && parsedLng != null) {
      setState(() {
        _mapLat = parsedLat;
        _mapLng = parsedLng;
      });
      _mapController.move(LatLng(_mapLat, _mapLng), 15);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _save({bool offlineOnly = false}) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      await showStatusPopupDialog(
        context,
        isSuccess: false,
        title: 'Judul Kosong',
        message: 'Judul catatan wajib diisi sebelum menyimpan.',
        buttonText: 'Mengerti',
      );
      return;
    }

    final state = AppStateScope.of(context);
    final lat = _latController.text.trim();
    final lng = _lngController.text.trim();

    bool ok;
    if (_isEditing && _loadedNote != null) {
      ok = await state.updateNote(
        _loadedNote!.copyWith(
          title: title,
          description: _descController.text.trim(),
          latitude: lat,
          longitude: lng,
          status: _status,
        ),
        offlineOnly: offlineOnly,
      );
    } else {
      ok = await state.createNote(
        title: title,
        description: _descController.text.trim(),
        latitude: lat,
        longitude: lng,
        status: _status,
        offlineOnly: offlineOnly,
      );
    }

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      await showStatusPopupDialog(
        context,
        isSuccess: false,
        title: 'Gagal Menyimpan',
        message: state.errorMessage ?? 'Terjadi kendala saat menyimpan catatan.',
        buttonText: 'Tutup',
      );
    }
  }

  Future<void> _delete() async {
    final note = _loadedNote ?? widget.note;
    if (note == null) return;
    final state = AppStateScope.of(context);
    final confirmed = await showDeleteNoteDialog(
      context,
      note: note,
      ownerName: state.user?.name ?? 'Pengguna',
    );
    if (confirmed && mounted) {
      final ok = await state.deleteNote(note.noteId);
      if (ok && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.user!;
    final note = _loadedNote ?? widget.note;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      body: Column(
        children: [
          AppTopBar(
            pageTitle: 'Catatan Saya',
            userInitial: initial,
            avatarUrl: user.avatar,
            onAvatarTap: widget.onOpenProfile,
          ),
          if (_fetchingDetail || state.isLoading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppTheme.primary,
              backgroundColor: AppTheme.tertiaryTint,
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.surfaceBase,
            child: Row(
              children: [
                CircularIconButton(
                  icon: Icons.chevron_left_rounded,
                  iconColor: AppTheme.primaryDark,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isEditing ? 'Detail & Ubah Catatan' : 'Tambah Catatan',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
                if (_isEditing)
                  CircularIconButton(
                    icon: Icons.delete_outline_rounded,
                    iconColor: AppTheme.critical,
                    onTap: _delete,
                  ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                AuraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'MILIK ${user.name.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDark,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•  ${note != null ? 'Catatan #${note.noteId}' : 'Catatan Baru'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const Spacer(),
                          StatusPillBadge.forStatus(_status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEditing
                            ? 'Ubah Catatan #${note!.noteId}'
                            : 'Buat Catatan Baru',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (note != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Dibuat: ${formatFriendlyDate(note.createdAt)}  •  Diubah: ${formatFriendlyDate(note.updatedAt)}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Judul Catatan',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan judul catatan',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Isi Catatan',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Tulis deskripsi atau detail catatan Anda...',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Titik Lokasi dengan Peta Interaktif & Deteksi GPS
                AuraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppTheme.primaryDark,
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Titik Lokasi',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.tertiaryTint,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Ketuk Peta',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 170,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(_mapLat, _mapLng),
                              initialZoom: 14,
                              onTap: (_, point) {
                                _updateCoordinates(
                                  point.latitude,
                                  point.longitude,
                                );
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.mobile_application_2',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(_mapLat, _mapLng),
                                    width: 38,
                                    height: 38,
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: AppTheme.primaryDark,
                                      size: 38,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Garis Lintang (Latitude)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _latController,
                                  onChanged: (_) => _syncMapFromText(),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Contoh: -6.2088',
                                    fillColor: AppTheme.softBlueBg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Garis Bujur (Longitude)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _lngController,
                                  onChanged: (_) => _syncMapFromText(),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Contoh: 106.8456',
                                    fillColor: AppTheme.softBlueBg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _detectingGps ? null : _detectGps,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.tertiaryTint,
                            side: BorderSide.none,
                            minimumSize: const Size.fromHeight(46),
                          ),
                          icon: _detectingGps
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location_rounded,
                                  size: 18,
                                  color: AppTheme.primaryDark,
                                ),
                          label: Text(
                            _detectingGps
                                ? 'Mendeteksi Lokasi...'
                                : 'Deteksi Lokasi GPS Otomatis',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                AuraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: AppTheme.primaryDark,
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Progres Kelengkapan',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            '$_status%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _status.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        activeColor: AppTheme.primaryDark,
                        inactiveColor: AppTheme.softBlueBg,
                        onChanged: (v) {
                          setState(() => _status = v.round());
                        },
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Awal (0%)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Berjalan (50%)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Selesai (100%)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: state.isLoading ? null : () => _save(),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _isEditing ? 'Simpan Perubahan' : 'Simpan Catatan',
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _save(offlineOnly: true),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryDark,
                    side: const BorderSide(color: AppTheme.primary),
                  ),
                  icon: const Icon(Icons.save_alt_rounded, size: 19),
                  label: Text(
                    _isEditing
                        ? 'Simpan Offline (Update)'
                        : 'Simpan Offline (Create)',
                  ),
                ),

                if (_isEditing) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: state.isLoading ? null : _delete,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppTheme.criticalBg.withValues(alpha: 0.6),
                      foregroundColor: AppTheme.critical,
                      side: const BorderSide(color: Color(0xFFFCA5A5)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 19),
                    label: const Text('Hapus Catatan'),
                  ),
                ],
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.softBlueBg,
                    side: BorderSide.none,
                  ),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
