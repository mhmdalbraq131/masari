import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../data/models/admin_company.dart';
import '../data/models/admin_price.dart';
import '../data/models/admin_trip.dart';
import '../data/models/admin_user.dart';
import '../data/models/booking_record.dart';
import '../data/models/user_role.dart';

class LocalDb {
  LocalDb._();

  static final LocalDb instance = LocalDb._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'masari.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedDefaultAdmin(db);
        await _seedAdminData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
        await _seedDefaultAdmin(db);
        await _seedAdminData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket_id TEXT NOT NULL,
        company TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS admin_companies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        logo_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS admin_trips (
        id TEXT PRIMARY KEY,
        from_region TEXT NOT NULL,
        to_region TEXT NOT NULL,
        time TEXT NOT NULL,
        price_sar REAL NOT NULL,
        seats INTEGER NOT NULL,
        enabled INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS admin_prices (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        value_sar REAL NOT NULL,
        enabled INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS admin_users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        role TEXT NOT NULL,
        active INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _seedDefaultAdmin(Database db) async {
    final existing = await db.query('users', where: 'username = ?', whereArgs: ['admin']);
    if (existing.isNotEmpty) return;
    await db.insert('users', {
      'username': 'admin',
      'password': '123456',
      'role': 'admin',
    });
  }

  Future<Map<String, Object?>?> getUserByUsername(String username) async {
    final db = await database;
    final rows = await db.query('users', where: 'username = ?', whereArgs: [username], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<Map<String, Object?>?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> insertUser({
    required String username,
    required String passwordHash,
    required String role,
  }) async {
    final db = await database;
    return db.insert('users', {
      'username': username,
      'password': passwordHash,
      'role': role,
    });
  }

  Future<void> updateUserPassword(int id, String passwordHash) async {
    final db = await database;
    await db.update('users', {'password': passwordHash}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _seedAdminData(Database db) async {
    final companies = await db.query('admin_companies', limit: 1);
    if (companies.isNotEmpty) return;

    await db.insert('admin_companies', {
      'id': 'c1',
      'name': 'المتصدر',
      'description': 'خدمة على مدار الساعة',
      'logo_path': null,
    });
    await db.insert('admin_companies', {
      'id': 'c2',
      'name': 'البركة',
      'description': 'رحلات يومية مريحة',
      'logo_path': null,
    });
    await db.insert('admin_companies', {
      'id': 'c3',
      'name': 'الأفضل',
      'description': 'مقاعد واسعة وخيارات متعددة',
      'logo_path': null,
    });

    await db.insert('admin_trips', {
      'id': 't1',
      'from_region': 'الرياض',
      'to_region': 'جدة',
      'time': '08:30',
      'price_sar': 300,
      'seats': 18,
      'enabled': 1,
    });
    await db.insert('admin_trips', {
      'id': 't2',
      'from_region': 'جدة',
      'to_region': 'المدينة',
      'time': '12:15',
      'price_sar': 250,
      'seats': 10,
      'enabled': 1,
    });
    await db.insert('admin_trips', {
      'id': 't3',
      'from_region': 'الدمام',
      'to_region': 'الرياض',
      'time': '18:45',
      'price_sar': 280,
      'seats': 5,
      'enabled': 0,
    });

    await db.insert('admin_prices', {
      'id': 'p1',
      'title': 'رسوم خدمة',
      'value_sar': 25,
      'enabled': 1,
    });
    await db.insert('admin_prices', {
      'id': 'p2',
      'title': 'ضريبة',
      'value_sar': 15,
      'enabled': 1,
    });

    await db.insert('admin_users', {
      'id': 'u1',
      'name': 'أحمد علي',
      'email': 'ahmed@email.com',
      'role': 'user',
      'active': 1,
    });
    await db.insert('admin_users', {
      'id': 'u2',
      'name': 'سارة محمد',
      'email': 'admin@masari.com',
      'role': 'admin',
      'active': 1,
    });
  }

  Future<List<AdminCompany>> fetchAdminCompanies() async {
    final db = await database;
    final rows = await db.query('admin_companies');
    return rows
        .map(
          (row) => AdminCompany(
            id: row['id'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            logoPath: row['logo_path'] as String?,
          ),
        )
        .toList();
  }

  Future<void> upsertAdminCompany(AdminCompany company) async {
    final db = await database;
    await db.insert(
      'admin_companies',
      {
        'id': company.id,
        'name': company.name,
        'description': company.description,
        'logo_path': company.logoPath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAdminCompany(String id) async {
    final db = await database;
    await db.delete('admin_companies', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AdminTrip>> fetchAdminTrips() async {
    final db = await database;
    final rows = await db.query('admin_trips');
    return rows
        .map(
          (row) => AdminTrip(
            id: row['id'] as String,
            fromRegion: row['from_region'] as String,
            toRegion: row['to_region'] as String,
            time: row['time'] as String,
            priceSar: (row['price_sar'] as num).toDouble(),
            seats: row['seats'] as int,
            enabled: (row['enabled'] as int) == 1,
          ),
        )
        .toList();
  }

  Future<void> upsertAdminTrip(AdminTrip trip) async {
    final db = await database;
    await db.insert(
      'admin_trips',
      {
        'id': trip.id,
        'from_region': trip.fromRegion,
        'to_region': trip.toRegion,
        'time': trip.time,
        'price_sar': trip.priceSar,
        'seats': trip.seats,
        'enabled': trip.enabled ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAdminTrip(String id) async {
    final db = await database;
    await db.delete('admin_trips', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AdminPrice>> fetchAdminPrices() async {
    final db = await database;
    final rows = await db.query('admin_prices');
    return rows
        .map(
          (row) => AdminPrice(
            id: row['id'] as String,
            title: row['title'] as String,
            valueSar: (row['value_sar'] as num).toDouble(),
            enabled: (row['enabled'] as int) == 1,
          ),
        )
        .toList();
  }

  Future<void> upsertAdminPrice(AdminPrice price) async {
    final db = await database;
    await db.insert(
      'admin_prices',
      {
        'id': price.id,
        'title': price.title,
        'value_sar': price.valueSar,
        'enabled': price.enabled ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAdminPrice(String id) async {
    final db = await database;
    await db.delete('admin_prices', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AdminUser>> fetchAdminUsers() async {
    final db = await database;
    final rows = await db.query('admin_users');
    return rows
        .map(
          (row) => AdminUser(
            id: row['id'] as String,
            name: row['name'] as String,
            email: row['email'] as String,
            role: (row['role'] as String) == 'admin' ? UserRole.admin : UserRole.user,
            active: (row['active'] as int) == 1,
          ),
        )
        .toList();
  }

  Future<void> upsertAdminUser(AdminUser user) async {
    final db = await database;
    await db.insert(
      'admin_users',
      {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role.name,
        'active': user.active ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAdminUser(String id) async {
    final db = await database;
    await db.delete('admin_users', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BookingRecord>> fetchBookings() async {
    final db = await database;
    final rows = await db.query('bookings', orderBy: 'id DESC');
    return rows
        .map(
          (row) => BookingRecord(
            ticketId: row['ticket_id'] as String,
            company: row['company'] as String,
            date: DateTime.tryParse(row['date'] as String) ?? DateTime.now(),
            status: row['status'] as String,
          ),
        )
        .toList();
  }

  Future<void> insertBooking(BookingRecord record) async {
    final db = await database;
    await db.insert('bookings', {
      'ticket_id': record.ticketId,
      'company': record.company,
      'date': record.date.toIso8601String(),
      'status': record.status,
    });
  }

  Future<void> updateBookingStatus(String ticketId, String status) async {
    final db = await database;
    await db.update(
      'bookings',
      {'status': status},
      where: 'ticket_id = ?',
      whereArgs: [ticketId],
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
