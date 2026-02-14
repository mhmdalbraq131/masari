import '../models/app_notification.dart';
import '../../models/trip_details.dart';

class MockData {
  static List<TripDetails> initialFavorites() => const [
        TripDetails(
          id: 'fav-1',
          title: 'رحلة دبي',
          location: 'دبي - الإمارات',
          imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=80',
          description: 'أفضل العروض المتاحة لزيارة دبي.',
          priceLabel: '340 ر.س',
        ),
        TripDetails(
          id: 'fav-2',
          title: 'رحلة البحرين',
          location: 'المنامة - البحرين',
          imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
          description: 'رحلات قصيرة بأسعار مناسبة.',
          priceLabel: '260 ر.س',
        ),
      ];

  static TripDetails sampleFavorite() => const TripDetails(
        id: 'fav-3',
        title: 'رحلة الرياض',
        location: 'الرياض - السعودية',
        imageUrl: 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=1200&q=80',
        description: 'أفضل العروض لزيارة الرياض.',
        priceLabel: '220 ر.س',
      );

  static List<AppNotification> initialNotifications() => const [
        AppNotification(
          id: 'n1',
          title: 'تم تأكيد الحجز',
          message: 'رحلة باريس أصبحت مؤكدة وجاهزة للسفر.',
          time: 'منذ 5 دقائق',
          isRead: false,
        ),
        AppNotification(
          id: 'n2',
          title: 'تحديث السعر',
          message: 'انخفض سعر رحلة دبي 15% لفترة محدودة.',
          time: 'منذ ساعتين',
          isRead: false,
        ),
        AppNotification(
          id: 'n3',
          title: 'تذكير بالدفع',
          message: 'يرجى إكمال الدفع قبل 24 ساعة من الموعد.',
          time: 'الأمس',
          isRead: true,
        ),
      ];
}
