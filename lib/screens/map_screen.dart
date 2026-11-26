import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import '../models/note_model.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class MapScreen extends StatefulWidget {
  final ValueChanged<NoteModel> onEditNote;
  final VoidCallback onOpenProfile;

  const MapScreen({
    super.key,
    required this.onEditNote,
    required this.onOpenProfile,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _myLocation;
  bool _locating = false;

  Future<void> _centerToMyLocation() async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
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
            message: 'Izinkan akses lokasi untuk menampilkan posisi Anda.',
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
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() => _myLocation = point);
      _mapController.move(point, 15);
    } catch (_) {
      if (mounted) {
        await showStatusPopupDialog(
          context,
          isSuccess: false,
          title: 'Lokasi Tidak Tersedia',
          message: 'Gagal mendapatkan posisi GPS saat ini.',
          buttonText: 'OK',
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.user!;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    final validNotes = <(NoteModel, LatLng)>[];
    for (final note in state.allNotes) {
      final lat = double.tryParse(note.latitude);
      final lng = double.tryParse(note.longitude);
      if (lat != null && lng != null) {
        validNotes.add((note, LatLng(lat, lng)));
      }
    }

    final initialCenter = validNotes.isNotEmpty
        ? validNotes.first.$2
        : const LatLng(-6.2088, 106.8456);

    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      body: Column(
        children: [
          AppTopBar(
            pageTitle: 'Peta Lokasi',
            userInitial: initial,
            avatarUrl: user.avatar,
            onRefreshTap: () => state.fetchNotes(),
            onAvatarTap: widget.onOpenProfile,
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mobile_application_2',
                    ),
                    MarkerLayer(
                      markers: [
                        ...validNotes.map((entry) {
                          final note = entry.$1;
                          final point = entry.$2;
                          return Marker(
                            point: point,
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () => widget.onEditNote(note),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryDark,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: AppTheme.floatingShadow,
                                ),
                                child: Center(
                                  child: Text(
                                    '#${note.noteId}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_myLocation != null)
                          Marker(
                            point: _myLocation!,
                            width: 22,
                            height: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: AppTheme.floatingShadow,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Floating GPS Recenter Button
                Positioned(
                  right: 16,
                  bottom: 98,
                  child: FloatingActionButton.small(
                    heroTag: 'map_gps_btn',
                    onPressed: _locating ? null : _centerToMyLocation,
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryDark,
                    child: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                ),

                // Bottom Summary Card
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: AuraCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.tertiaryTint,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${validNotes.length} Titik Lokasi Tersimpan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Text(
                                'Ketuk pin di peta untuk melihat atau mengubah catatan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
