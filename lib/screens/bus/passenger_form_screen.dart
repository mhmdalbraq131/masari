import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class PassengerFormScreen extends StatefulWidget {
  const PassengerFormScreen({super.key});

  @override
  State<PassengerFormScreen> createState() => _PassengerFormScreenState();
}

class _PassengerFormScreenState extends State<PassengerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _visaType;
  File? _passportImage;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _visaTypes = const [
    'سياحية',
    'عمل',
    'دراسة',
    'زيارة',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickPassportImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (image == null) return;
    setState(() => _passportImage = File(image.path));
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('التقاط بالكاميرا'),
              onTap: () {
                Navigator.of(context).pop();
                _pickPassportImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.of(context).pop();
                _pickPassportImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false) || _passportImage == null) {
      if (_passportImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى رفع صورة الجواز')),
        );
      }
      return;
    }
    context.push(
      '/bus-review',
      extra: {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'reason': _reasonController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'بيانات المسافر'),
      body: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(labelText: 'سبب السفر'),
                  maxLines: 2,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'مطلوب' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _visaType,
                  decoration: const InputDecoration(labelText: 'نوع التأشيرة'),
                  items: _visaTypes
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _visaType = value),
                  validator: (value) => value == null ? 'مطلوب' : null,
                ),
                const SizedBox(height: 16),
                if (_passportImage == null)
                  OutlinedButton.icon(
                    onPressed: _showImagePicker,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('رفع صورة الجواز'),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _passportImage!,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showImagePicker,
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('استبدال الصورة'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () => setState(() => _passportImage = null),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('إزالة'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('حفظ البيانات'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
