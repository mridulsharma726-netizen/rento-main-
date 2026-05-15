import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/product_provider.dart';
import '../../widgets/rento_button.dart';
import '../../widgets/rento_input.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  String? _selectedCategory;
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();

  static const List<String> _categories = [
    'electronics',
    'vehicles',
    'clothing',
    'furniture',
    'sports',
    'books',
    'tools',
    'appliances',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    final product = await context.read<ProductProvider>().createProduct({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price_per_day': double.parse(_priceCtrl.text.trim()),
      'deposit': _depositCtrl.text.trim().isEmpty
          ? 0
          : double.parse(_depositCtrl.text.trim()),
      'category': _selectedCategory!,
    }, imageBytes: _imageBytes, imageName: _selectedImage?.name);
    if (!mounted) return;
    if (product != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Product listed successfully!'),
            backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } else {
      final provider = context.read<ProductProvider>();
      if (provider.errorCode == 'KYC_REQUIRED') {
        final shouldOpenKyc = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('KYC Required'),
            content: const Text(
              'Owners need a verified identity before they can publish listings. Submit KYC now to unlock product listing.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Open KYC'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        if (shouldOpenKyc == true) {
          Navigator.pushNamed(context, '/kyc');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to create product'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.addProduct)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1200,
                    maxHeight: 1200,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    final bytes = await image.readAsBytes();
                    setState(() {
                      _selectedImage = image;
                      _imageBytes = bytes;
                    });
                  }
                },
                child: Container(
                  height: 140,
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _imageBytes != null
                      ? Image.memory(_imageBytes!,
                          fit: BoxFit.cover, width: double.infinity)
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined,
                                  color: AppColors.textSecondary, size: 36),
                              const SizedBox(height: 8),
                              Text(AppStrings.uploadImages,
                                  style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 4),
                              Text('Tap to upload photos',
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Product Details', style: theme.textTheme.titleLarge),
              const SizedBox(height: 14),
              RentoInput(
                label: AppStrings.titleLabel,
                hint: AppStrings.titleHint,
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                maxLength: 200,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  if (v.trim().length < 3) return 'Title too short';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              RentoInput(
                label: AppStrings.descriptionLabel,
                hint: AppStrings.descHint,
                controller: _descCtrl,
                maxLines: 4,
                maxLength: 2000,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Pricing', style: theme.textTheme.titleLarge),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: RentoInput(
                      label: AppStrings.priceLabel,
                      hint: '0',
                      controller: _priceCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('₹',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 16)),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v) == null || double.parse(v) < 1) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RentoInput(
                      label: AppStrings.depositLabel,
                      hint: '0',
                      controller: _depositCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('₹',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(AppStrings.categoryLabel, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentSubtle
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                selected ? AppColors.accent : AppColors.border),
                      ),
                      child: Text(
                        cat[0].toUpperCase() + cat.substring(1),
                        style: TextStyle(
                          color: selected
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Consumer<ProductProvider>(
                builder: (_, provider, __) => RentoButton(
                  label: AppStrings.listProduct,
                  onPressed: _submit,
                  isLoading: provider.isLoading,
                  icon: Icons.rocket_launch_outlined,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
