import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';

class LocationPickerMap extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;
  final bool isReadOnly;
  final Function(Map<String, dynamic>)? onLocationSelected;

  const LocationPickerMap({
    super.key,
    this.initialLocation,
    this.initialAddress,
    this.isReadOnly = false,
    this.onLocationSelected,
  });

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> with TickerProviderStateMixin {
  late final MapController _mapController;
  LatLng _currentPosition = const LatLng(-6.200000, 106.816666);
  String _currentAddress = 'Menunggu lokasi...';
  bool _isLoadingAddress = false;
  bool _isMapReady = false;

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _isMapInitializing = false;
  bool _hasLocationPermission = false;
  
  Timer? _debounce;
  late final AnimationController _animController;
  VoidCallback? _animationListener;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    
    if (widget.initialLocation != null) {
      _currentPosition = widget.initialLocation!;
      _currentAddress = widget.initialAddress ?? 'Lokasi tersimpan';
      _isMapInitializing = false;
    } else {
      _isMapInitializing = true;
      _checkLocationPermission();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (!_isMapReady) return;
    
    if (_animationListener != null) {
      _animController.removeListener(_animationListener!);
    }
    _animController.reset();
    
    final animation = CurvedAnimation(parent: _animController, curve: Curves.fastOutSlowIn);
    final latTween = Tween<double>(begin: _currentPosition.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _currentPosition.longitude, end: destLocation.longitude);
    
    _animationListener = () {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        destZoom,
      );
    };
    
    _animController.addListener(_animationListener!);
    
    _animController.forward();
  }

  Future<void> _checkLocationPermission() async {
    if (!mounted) return;
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aktifkan Lokasi'),
          content: const Text('Layanan lokasi dinonaktifkan. Silakan aktifkan layanan lokasi untuk melanjutkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Buka Pengaturan'),
            ),
          ],
        ),
      );
      if (proceed == true) {
        await Geolocator.openLocationSettings();
      }
      if (mounted) {
        setState(() {
          _currentAddress = 'Izin lokasi ditolak, silakan geser peta';
          _isLoadingAddress = false;
          _isMapInitializing = false;
        });
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _currentAddress = 'Izin lokasi ditolak, silakan geser peta';
            _isLoadingAddress = false;
            _isMapInitializing = false;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Izin Lokasi Diperlukan'),
          content: const Text('Izin lokasi ditolak secara permanen. Anda perlu membukanya melalui pengaturan aplikasi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Buka Pengaturan'),
            ),
          ],
        ),
      );
      if (proceed == true) {
        await Geolocator.openAppSettings();
      }
      if (mounted) {
        setState(() {
          _currentAddress = 'Izin lokasi ditolak, silakan geser peta';
          _isLoadingAddress = false;
          _isMapInitializing = false;
        });
      }
      return;
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      _hasLocationPermission = true;
      await _getCurrentLocation();
    }
  }

  void _onMyLocationPressed() {
    if (_hasLocationPermission) {
      _getCurrentLocation();
    } else {
      _checkLocationPermission();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingAddress = true;
      _currentAddress = 'Mengambil lokasi Anda...';
    });
    
    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.best));
          
      // Try to get better accuracy (under 20 meters) if needed
      if (position.accuracy > 20.0) {
        for (int i = 0; i < 3; i++) {
          await Future.delayed(const Duration(seconds: 1));
          Position newPos = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(accuracy: LocationAccuracy.best));
          if (newPos.accuracy < position.accuracy) {
            position = newPos;
          }
          if (position.accuracy <= 20.0) {
            break;
          }
        }
      }
      
      final latLng = LatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _currentPosition = latLng;
          if (_isMapInitializing) {
            _currentAddress = 'Mencari alamat...';
          }
        });
      }
      
      if (_isMapReady) {
        _animatedMapMove(latLng, 17.0);
      }
      
      await _getAddressFromLatLng(latLng);
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Tidak dapat memperoleh lokasi Anda.';
          _isLoadingAddress = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMapInitializing = false;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1');
      final response = await http.get(url, headers: {
        'User-Agent': 'CitizenApp/1.0',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _currentAddress = data['display_name'] ?? 'Alamat tidak dapat ditemukan, namun koordinat tetap dapat disimpan.';
          });
        }
      } else {
        if (mounted) setState(() => _currentAddress = 'Alamat tidak dapat ditemukan, namun koordinat tetap dapat disimpan.');
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = 'Alamat tidak dapat ditemukan, namun koordinat tetap dapat disimpan.');
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&countrycodes=id&limit=5');
      final response = await http.get(url, headers: {
        'User-Agent': 'CitizenApp/1.0',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _searchResults = data;
          });
        }
      }
    } catch (e) {
      // Ignore
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onSearchSelect(dynamic result) {
    FocusScope.of(context).unfocus();
    final lat = double.tryParse(result['lat'].toString());
    final lon = double.tryParse(result['lon'].toString());
    if (lat != null && lon != null) {
      final latLng = LatLng(lat, lon);
      setState(() {
        _currentPosition = latLng;
        _currentAddress = result['display_name'] ?? 'Lokasi terpilih';
        _searchResults = [];
        _searchController.clear();
      });
      if (_isMapReady) {
        _animatedMapMove(latLng, 17.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReadOnly ? 'Detail Lokasi' : 'Pilih Lokasi',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textDark)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0,
      ),
      body: _isMapInitializing 
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text('📍 $_currentAddress', style: const TextStyle(color: AppColors.textSoft, fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: widget.initialLocation != null ? 17.0 : 15.0,
              interactionOptions: InteractionOptions(
                flags: widget.isReadOnly ? InteractiveFlag.none : InteractiveFlag.all,
              ),
              onMapReady: () {
                _isMapReady = true;
              },
              onPositionChanged: (position, hasGesture) {
                if (!widget.isReadOnly && hasGesture && position.center != null) {
                  setState(() {
                    _currentPosition = position.center!;
                    _isLoadingAddress = true;
                    _currentAddress = 'Mencari alamat...';
                  });
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _getAddressFromLatLng(_currentPosition);
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (widget.isReadOnly)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_on, color: AppColors.primary, size: 45),
                    ),
                  ],
                ),
            ],
          ),
          
          // Fixed center marker for editable mode
          if (!widget.isReadOnly)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 45.0),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 45,
                ),
              ),
            ),
          
          // Search Bar
          if (!widget.isReadOnly)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _searchLocation,
                      decoration: InputDecoration(
                        hintText: 'Cari alamat...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSoft),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textSoft),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  if (_isSearching)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (c, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(item['display_name'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                            onTap: () => _onSearchSelect(item),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

          // Bottom Sheet and FAB
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isReadOnly)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      heroTag: 'curr_loc_btn',
                      onPressed: _onMyLocationPressed,
                      child: const Icon(Icons.my_location, color: AppColors.primary),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.isReadOnly ? 'Alamat Penjemputan' : 'Lokasi Penjemputan',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isLoadingAddress
                            ? const Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text('Mengambil alamat...', style: TextStyle(color: AppColors.textSoft, fontSize: 14)),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentAddress,
                                    style: const TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.4),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_currentPosition.latitude.toStringAsFixed(6)}, ${_currentPosition.longitude.toStringAsFixed(6)}',
                                    style: const TextStyle(color: AppColors.textSoft, fontSize: 12),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (!widget.isReadOnly)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoadingAddress
                            ? null
                            : () {
                                final result = {
                                  'latitude': _currentPosition.latitude,
                                  'longitude': _currentPosition.longitude,
                                  'address': _currentAddress,
                                };
                                if (widget.onLocationSelected != null) {
                                  widget.onLocationSelected!(result);
                                } else {
                                  Navigator.pop(context, result);
                                }
                              },
                        child: const Text(
                          'Gunakan Lokasi Ini',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
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
