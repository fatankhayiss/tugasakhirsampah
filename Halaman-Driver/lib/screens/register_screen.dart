import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/wilayah_service.dart';
import '../constants/api_config.dart';

const _primary = DriverColors.primary;
const _bg = DriverColors.background;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Step 1: Akun
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Step 2: Alamat
  final _alamatController = TextEditingController();
  final _kodePosController = TextEditingController();

  final _wilayahService = WilayahService();
  List<Map<String, String>> _provinces = [];
  List<Map<String, String>> _regencies = [];
  List<Map<String, String>> _districts = [];

  String? _selectedProvinsiId;
  String? _selectedProvinsiName;
  String? _selectedKabKotaId;
  String? _selectedKabKotaName;
  String? _selectedKecamatanId;
  String? _selectedKecamatanName;
  
  bool _isLoadingWilayah = true;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingWilayah = true);
    final data = await _wilayahService.getProvinces();
    setState(() {
      _provinces = data;
      _isLoadingWilayah = false;
    });
  }

  Future<void> _onProvinsiChanged(String? id, String? name) async {
    if (id == null) return;
    setState(() {
      _selectedProvinsiId = id;
      _selectedProvinsiName = name;
      _selectedKabKotaId = null;
      _selectedKabKotaName = null;
      _selectedKecamatanId = null;
      _selectedKecamatanName = null;
      _regencies = [];
      _districts = [];
      _isLoadingWilayah = true;
    });
    final data = await _wilayahService.getRegencies(id);
    setState(() {
      _regencies = data;
      _isLoadingWilayah = false;
    });
  }

  Future<void> _onKabKotaChanged(String? id, String? name) async {
    if (id == null) return;
    setState(() {
      _selectedKabKotaId = id;
      _selectedKabKotaName = name;
      _selectedKecamatanId = null;
      _selectedKecamatanName = null;
      _districts = [];
      _isLoadingWilayah = true;
    });
    final data = await _wilayahService.getDistricts(id);
    setState(() {
      _districts = data;
      _isLoadingWilayah = false;
    });
  }

  // Step 3: Kendaraan
  String _tipeKendaraan = 'Motor';
  final _jenisKendaraanController = TextEditingController();
  final _plat1Controller = TextEditingController();
  final _plat2Controller = TextEditingController();
  final _plat3Controller = TextEditingController();

  double get _kapasitasBerat {
    switch (_tipeKendaraan) {
      case 'Truk':
        return 100.0;
      case 'Mobil':
        return 30.0;
      case 'Motor':
      default:
        return 10.0;
    }
  }

  Future<void> _register() async {
    // Validasi akhir
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Konfirmasi Password tidak cocok'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final registerData = {
      'nama_lengkap': _namaController.text,
      'username': _usernameController.text,
      'no_telepon': _phoneController.text,
      'password': _passwordController.text,
      'alamat': _alamatController.text,
      'kecamatan': _selectedKecamatanName ?? '',
      'kab_kota': _selectedKabKotaName ?? '',
      'wilayah': _selectedProvinsiName ?? '',
      'kode_pos': _kodePosController.text,
      'tipe_kendaraan': _tipeKendaraan,
      'jenis_kendaraan': _jenisKendaraanController.text,
      'plat_nomor': '${_plat1Controller.text.toUpperCase()} ${_plat2Controller.text} ${_plat3Controller.text.toUpperCase()}',
      'kapasitas_berat': _kapasitasBerat.toString(),
    };

    try {
      final response = await _authService.register(registerData);

      if (response.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Driver berhasil! Silakan login.')),
        );
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.message,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (_namaController.text.isEmpty ||
          _usernameController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua data akun')),
        );
        return false;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Password tidak cocok')));
        return false;
      }
    } else if (step == 1) {
      if (_alamatController.text.isEmpty ||
          _selectedProvinsiName == null ||
          _selectedKabKotaName == null ||
          _selectedKecamatanName == null ||
          _kodePosController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua data alamat')),
        );
        return false;
      }
    } else if (step == 2) {
      if (_jenisKendaraanController.text.isEmpty ||
          _plat1Controller.text.isEmpty ||
          _plat2Controller.text.isEmpty ||
          _plat3Controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua data kendaraan')),
        );
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _alamatController.dispose();
    _kodePosController.dispose();
    _jenisKendaraanController.dispose();
    _plat1Controller.dispose();
    _plat2Controller.dispose();
    _plat3Controller.dispose();
    super.dispose();
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _primary),
          suffixIcon: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Daftar Driver',
          style: TextStyle(color: _primary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (!_validateStep(_currentStep)) return;

          if (_currentStep < 2) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            _register();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          } else {
            Navigator.of(context).pop();
          }
        },
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              isLastStep ? 'Selesaikan' : 'Lanjut',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Akun'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                _buildTextField(_namaController, 'Nama Lengkap', Icons.person),
                _buildTextField(
                  _usernameController,
                  'Username',
                  Icons.alternate_email,
                ),
                _buildTextField(
                  _phoneController,
                  'Nomor Telepon',
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  _passwordController,
                  'Password',
                  Icons.lock,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  ),
                ),
                _buildTextField(
                  _confirmPasswordController,
                  'Konfirmasi Password',
                  Icons.lock_outline,
                  obscure: _obscureConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Alamat'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                _buildTextField(
                  _alamatController,
                  'Alamat Lengkap',
                  Icons.home,
                ),
                
                // Dropdown Provinsi
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedProvinsiId,
                    decoration: InputDecoration(
                      labelText: 'Provinsi (Wilayah)',
                      prefixIcon: const Icon(Icons.public, color: _primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _provinces.map((prov) {
                      return DropdownMenuItem<String>(
                        value: prov['id'],
                        child: Text(prov['name']!),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final name = _provinces.firstWhere((e) => e['id'] == val)['name'];
                        _onProvinsiChanged(val, name);
                      }
                    },
                  ),
                ),
                
                // Dropdown Kab/Kota
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedKabKotaId,
                    decoration: InputDecoration(
                      labelText: 'Kabupaten/Kota',
                      prefixIcon: const Icon(Icons.location_city, color: _primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _regencies.map((reg) {
                      return DropdownMenuItem<String>(
                        value: reg['id'],
                        child: Text(reg['name']!),
                      );
                    }).toList(),
                    onChanged: _regencies.isEmpty ? null : (val) {
                      if (val != null) {
                        final name = _regencies.firstWhere((e) => e['id'] == val)['name'];
                        _onKabKotaChanged(val, name);
                      }
                    },
                  ),
                ),
                
                // Dropdown Kecamatan
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedKecamatanId,
                    decoration: InputDecoration(
                      labelText: 'Kecamatan',
                      prefixIcon: const Icon(Icons.map, color: _primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _districts.map((dis) {
                      return DropdownMenuItem<String>(
                        value: dis['id'],
                        child: Text(dis['name']!),
                      );
                    }).toList(),
                    onChanged: _districts.isEmpty ? null : (val) {
                      if (val != null) {
                        final name = _districts.firstWhere((e) => e['id'] == val)['name'];
                        setState(() {
                          _selectedKecamatanId = val;
                          _selectedKecamatanName = name;
                        });
                      }
                    },
                  ),
                ),

                if (_isLoadingWilayah) const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: LinearProgressIndicator(color: _primary),
                ),
                
                _buildTextField(
                  _kodePosController,
                  'Kode Pos',
                  Icons.markunread_mailbox,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Kendaraan'),
            isActive: _currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _tipeKendaraan,
                  decoration: InputDecoration(
                    labelText: 'Tipe Kendaraan',
                    prefixIcon: const Icon(
                      Icons.directions_car,
                      color: _primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items:
                      ['Motor', 'Mobil', 'Truk'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _tipeKendaraan = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _jenisKendaraanController,
                  'Jenis Kendaraan (Contoh: Honda Beat, Avanza)',
                  Icons.info_outline,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Plat Nomor',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _plat1Controller,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'B',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _plat2Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '1234',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _plat3Controller,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'ABC',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.scale, color: _primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kapasitas Angkut Maksimal',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Berdasarkan tipe $_tipeKendaraan, kapasitas maksimal yang dapat dibawa adalah ${_kapasitasBerat.toInt()} kg.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
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
          ),
        ],
      ),
    );
  }
}
