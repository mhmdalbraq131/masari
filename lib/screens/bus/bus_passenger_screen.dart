import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../logic/bus_booking_controller.dart';
import '../../models/bus_model.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class BusPassengerScreen extends StatefulWidget {
  const BusPassengerScreen({super.key});

  @override
  State<BusPassengerScreen> createState() => _BusPassengerScreenState();
}

class _BusPassengerScreenState extends State<BusPassengerScreen> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  String? _reasonForTravel;
  String? _visaType;
  File? _passportImageFile;
  bool _isSubmitting = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPassportImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _passportImageFile = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحميل صورة جواز السفر'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الصورة: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_passportImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحميل صورة جواز السفر'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final passengerInfo = PassengerInfo(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        reasonForTravel: _reasonForTravel!,
        visaType: _visaType!,
        passportImagePath: _passportImageFile!.path,
      );

      final controller = context.read<BusBookingController>();
      controller.updatePassengerInfo(passengerInfo);

      // Complete the booking
      final success = await controller.completeBooking();

      if (!mounted) return;

      if (success) {
        // Navigate to confirmation screen
        context.pushReplacementNamed('bus-confirmation');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'فشل الحجز'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'بيانات الراكب'),
      body: SafeArea(
        child: Consumer<BusBookingController>(
          builder: (context, controller, _) {
            final trip = controller.selectedTrip;

            if (trip == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_bus_filled_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text('لم يتم اختيار أي رحلة'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('العودة'),
                    ),
                  ],
                ),
              );
            }

            return ResponsiveContainer(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Trip Summary Card
                    Card(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ملخص الرحلة',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trip.company,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${trip.fromCity} → ${trip.toCity}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'الانطلاق: ${trip.departureTime} | الوصول: ${trip.arrivalTime}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${trip.priceSAR.toStringAsFixed(0)} ر.س',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                    Text(
                                      '${trip.priceYER.toStringAsFixed(0)} ر.ي',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full Name
                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: 'الاسم الكامل',
                              prefixIcon: const Icon(Icons.person),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الاسم الكامل مطلوب';
                              }
                              if (value.length < 3) {
                                return 'الاسم قصير جداً';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'رقم الهاتف',
                              prefixIcon: const Icon(Icons.phone),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'رقم الهاتف مطلوب';
                              }
                              if (value.length < 7) {
                                return 'رقم الهاتف غير صحيح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Reason for Travel
                          DropdownButtonFormField<String>(
                            initialValue: _reasonForTravel,
                            decoration: InputDecoration(
                              labelText: 'سبب السفر',
                              prefixIcon: const Icon(Icons.info),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            items: BusConstants.travelReasons.map((reason) {
                              return DropdownMenuItem<String>(
                                value: reason,
                                child: Text(reason),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _reasonForTravel = value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'اختر سبب السفر';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Visa Type
                          DropdownButtonFormField<String>(
                            initialValue: _visaType,
                            decoration: InputDecoration(
                              labelText: 'نوع التأشيرة',
                              prefixIcon: const Icon(Icons.assignment),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            items: BusConstants.visaTypes.map((visa) {
                              return DropdownMenuItem<String>(
                                value: visa,
                                child: Text(visa),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _visaType = value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'اختر نوع التأشيرة';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Passport Image Upload
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'صورة جواز السفر',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (_passportImageFile != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            _passportImageFile!,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'تم تحميل الصورة',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.green,
                                                  ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() =>
                                                    _passportImageFile = null);
                                              },
                                              child: const Text('حذف'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  else
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: _pickPassportImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                              .withValues(alpha: 0.3),
                                            style: BorderStyle.solid,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt,
                                              size: 48,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.5),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'اضغط لتحميل صورة جواز السفر',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submitForm,
                            icon: _isSubmitting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(_isSubmitting
                                ? 'جاري المعالجة...'
                                : 'تأكيد الحجز'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
