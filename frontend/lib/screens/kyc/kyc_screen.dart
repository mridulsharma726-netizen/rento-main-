import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/rento_button.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  final _fullNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedIdType;
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  Map<String, dynamic>? _kycData;
  bool _loadingStatus = true;

  final List<String> _idTypes = const [
    'Aadhar Card',
    'PAN Card',
    'Driving License',
    'Passport',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKycStatus();
    });
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadKycStatus() async {
    setState(() => _loadingStatus = true);
    final response = await context.read<AuthProvider>().getKycStatus();
    if (!mounted) return;
    setState(() {
      _kycData = response?['data'] as Map<String, dynamic>?;
      _loadingStatus = false;
    });
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1800,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImage = image;
      _selectedImageBytes = bytes;
    });
  }

  Future<void> _submitKyc() async {
    if (_selectedImage == null || _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an ID proof image'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.uploadKyc(
      {
        'id_type': _selectedIdType,
        'id_number': _idNumberController.text.trim(),
        'full_name': _fullNameController.text.trim(),
      },
      imagePath: _selectedImage!.path,
    );

    if (!mounted) return;
    if (success) {
      await auth.refreshProfile();
      await _loadKycStatus();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KYC documents submitted for review'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Upload failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  List<dynamic> get _documents =>
      (_kycData?['documents'] as List<dynamic>? ?? const []);

  Map<String, dynamic>? get _latestDocument {
    if (_documents.isEmpty) return null;
    return _documents.first as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;
    final status = _kycData?['kyc_status']?.toString() ??
        user?.kycStatus ??
        'not_submitted';
    final latestDocument = _latestDocument;
    final rejectionReason =
        latestDocument?['rejection_reason']?.toString().trim() ?? '';

    if (_loadingStatus) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (status == 'verified' || status == 'pending') {
      return _buildStatusView(status, latestDocument);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Identity Verification')),
      body: RefreshIndicator(
        onRefresh: _loadKycStatus,
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trust & Safety', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Complete KYC to unlock owner listings, strengthen your trust score, and make your account easier for other renters and owners to trust.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (status == 'rejected' && rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.errorSubtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Previous submission was rejected',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rejectionReason,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _selectedImageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: AppColors.accent,
                              ),
                              const SizedBox(height: 12),
                              Text('Upload ID Proof',
                                  style: theme.textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                'JPEG or PNG, max 5MB',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          )
                        : Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  initialValue: _selectedIdType,
                  decoration: InputDecoration(
                    labelText: 'Select ID Type',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _idTypes
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedIdType = value),
                  validator: (value) =>
                      value == null ? 'Please select ID type' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idNumberController,
                  decoration: InputDecoration(
                    labelText: 'ID Number',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter ID number'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name (as per ID)',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter your full name'
                      : null,
                ),
                const SizedBox(height: 32),
                RentoButton(
                  label: status == 'rejected'
                      ? 'Resubmit for Verification'
                      : 'Submit for Verification',
                  onPressed: _submitKyc,
                  isLoading: auth.isLoading,
                  icon: Icons.verified_user_outlined,
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Your data is encrypted and used only for verification.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusView(
    String status,
    Map<String, dynamic>? latestDocument,
  ) {
    final isVerified = status == 'verified';
    final docType = latestDocument?['id_type']?.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('KYC Status')),
      body: RefreshIndicator(
        onRefresh: _loadKycStatus,
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: const EdgeInsets.all(40),
          children: [
            const SizedBox(height: 60),
            Icon(
              isVerified ? Icons.verified : Icons.hourglass_empty,
              size: 80,
              color: isVerified ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(height: 24),
            Text(
              isVerified ? 'Verification Complete' : 'Verification in Progress',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isVerified
                  ? 'Your identity is verified. You can list products and continue building your trust score.'
                  : 'We are reviewing your documents now. Owners can approve bookings while your KYC review continues, but listing your own items stays tied to verification.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (docType != null && docType.isNotEmpty) ...[
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Latest document: $docType',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
