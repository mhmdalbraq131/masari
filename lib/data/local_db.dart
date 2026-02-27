import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../data/models/admin_company.dart';
import '../data/models/admin_price.dart';
import '../data/models/admin_trip.dart';
import '../data/models/admin_user.dart';
import '../data/models/audit_log.dart';
import '../data/models/booking_record.dart';
import '../data/models/user_role.dart';
import '../data/models/hajj_umrah_models.dart';
import '../data/models/location_model.dart';

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
      version: 7,
      onCreate: (db, version) async {
        await _createTables(db);
        await _ensureBookingColumns(db);
        await _ensureHajjUmrahColumns(db);
        await _seedAdminData(db);
        await _seedHajjUmrahCampaigns(db);
        await _seedLocations(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
        await _ensureBookingColumns(db);
        await _ensureHajjUmrahColumns(db);
        await _seedAdminData(db);
        await _seedHajjUmrahCampaigns(db);
        await _seedLocations(db);
      },
      onOpen: (db) async {
        await _ensureBookingColumns(db);
        await _ensureHajjUmrahColumns(db);
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
        status TEXT NOT NULL,
        amount_sar REAL NOT NULL,
        user_name TEXT NOT NULL,
        workflow_status TEXT NOT NULL DEFAULT 'received',
        assigned_to TEXT,
        internal_notes TEXT NOT NULL DEFAULT '[]'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id TEXT PRIMARY KEY,
        actor TEXT NOT NULL,
        action TEXT NOT NULL,
        target_type TEXT NOT NULL,
        target_id TEXT NOT NULL,
        details TEXT NOT NULL,
        created_at TEXT NOT NULL
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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hajj_umrah_packages (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        price_sar REAL NOT NULL,
        duration_days INTEGER NOT NULL,
        hotel_name TEXT NOT NULL,
        hotel_lat REAL NOT NULL,
        hotel_lng REAL NOT NULL,
        transport_type TEXT NOT NULL,
        max_seats INTEGER NOT NULL,
        campaign_id TEXT,
        description TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hajj_umrah_applications (
        id TEXT PRIMARY KEY,
        package_id TEXT NOT NULL,
        campaign_id TEXT,
        group_id TEXT,
        user_name TEXT NOT NULL,
        age INTEGER NOT NULL,
        phone TEXT NOT NULL,
        companions INTEGER NOT NULL,
        passport_image_path TEXT NOT NULL,
        visa_type TEXT NOT NULL,
        status TEXT NOT NULL,
        visa_status TEXT NOT NULL DEFAULT 'requested',
        visa_reference TEXT,
        document_status TEXT NOT NULL DEFAULT 'pending',
        document_notes TEXT,
        hotel_room_type TEXT,
        hotel_room_number TEXT,
        transport_plan TEXT,
        supervisor_name TEXT,
        waiting_list INTEGER NOT NULL DEFAULT 0,
        waitlist_position INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hajj_umrah_campaigns (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        season_start TEXT NOT NULL,
        season_end TEXT NOT NULL,
        capacity INTEGER NOT NULL,
        active INTEGER NOT NULL,
        notes TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS hajj_umrah_groups (
        id TEXT PRIMARY KEY,
        campaign_id TEXT NOT NULL,
        name TEXT NOT NULL,
        supervisor_name TEXT NOT NULL,
        transport_plan TEXT NOT NULL,
        capacity INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS locations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<void> _ensureBookingColumns(Database db) async {
    final columns = await db.rawQuery('PRAGMA table_info(bookings)');
    final names = columns.map((row) => row['name'] as String).toSet();
    if (!names.contains('amount_sar')) {
      await db.execute(
        'ALTER TABLE bookings ADD COLUMN amount_sar REAL NOT NULL DEFAULT 0',
      );
    }
    if (!names.contains('user_name')) {
      await db.execute(
        "ALTER TABLE bookings ADD COLUMN user_name TEXT NOT NULL DEFAULT 'غير معروف'",
      );
    }
    if (!names.contains('workflow_status')) {
      await db.execute(
        "ALTER TABLE bookings ADD COLUMN workflow_status TEXT NOT NULL DEFAULT 'received'",
      );
    }
    if (!names.contains('assigned_to')) {
      await db.execute(
        'ALTER TABLE bookings ADD COLUMN assigned_to TEXT',
      );
    }
    if (!names.contains('internal_notes')) {
      await db.execute(
        "ALTER TABLE bookings ADD COLUMN internal_notes TEXT NOT NULL DEFAULT '[]'",
      );
    }
  }

  Future<void> _ensureHajjUmrahColumns(Database db) async {
    final pkgColumns = await db.rawQuery('PRAGMA table_info(hajj_umrah_packages)');
    final pkgNames = pkgColumns.map((row) => row['name'] as String).toSet();
    if (!pkgNames.contains('campaign_id')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_packages ADD COLUMN campaign_id TEXT',
      );
    }

    final appColumns = await db.rawQuery('PRAGMA table_info(hajj_umrah_applications)');
    final appNames = appColumns.map((row) => row['name'] as String).toSet();
    if (!appNames.contains('campaign_id')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN campaign_id TEXT',
      );
    }
    if (!appNames.contains('group_id')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN group_id TEXT',
      );
    }
    if (!appNames.contains('visa_status')) {
      await db.execute(
        "ALTER TABLE hajj_umrah_applications ADD COLUMN visa_status TEXT NOT NULL DEFAULT 'requested'",
      );
    }
    if (!appNames.contains('visa_reference')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN visa_reference TEXT',
      );
    }
    if (!appNames.contains('document_status')) {
      await db.execute(
        "ALTER TABLE hajj_umrah_applications ADD COLUMN document_status TEXT NOT NULL DEFAULT 'pending'",
      );
    }
    if (!appNames.contains('document_notes')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN document_notes TEXT',
      );
    }
    if (!appNames.contains('hotel_room_type')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN hotel_room_type TEXT',
      );
    }
    if (!appNames.contains('hotel_room_number')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN hotel_room_number TEXT',
      );
    }
    if (!appNames.contains('transport_plan')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN transport_plan TEXT',
      );
    }
    if (!appNames.contains('supervisor_name')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN supervisor_name TEXT',
      );
    }
    if (!appNames.contains('waiting_list')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN waiting_list INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!appNames.contains('waitlist_position')) {
      await db.execute(
        'ALTER TABLE hajj_umrah_applications ADD COLUMN waitlist_position INTEGER',
      );
    }
  }

  Future<Map<String, Object?>?> getUserByUsername(String username) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<Map<String, Object?>?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<bool> hasUserWithRole(String role) async {
    final db = await database;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'role = ?',
      whereArgs: [role],
      limit: 1,
    );
    return rows.isNotEmpty;
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
    await db.update(
      'users',
      {'password': passwordHash},
      where: 'id = ?',
      whereArgs: [id],
    );
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
      'role': 'bookingAgent',
      'active': 1,
    });
    await db.insert('admin_users', {
      'id': 'u2',
      'name': 'سارة محمد',
      'email': 'admin@masari.com',
      'role': 'admin',
      'active': 1,
    });
    await db.insert('admin_users', {
      'id': 'u3',
      'name': 'منى حسن',
      'email': 'visa@masari.com',
      'role': 'visaOfficer',
      'active': 1,
    });
    await db.insert('admin_users', {
      'id': 'u4',
      'name': 'خالد سالم',
      'email': 'supervisor@masari.com',
      'role': 'supervisor',
      'active': 1,
    });
  }

  Future<void> _seedLocations(Database db) async {
    final existing = await db.query('locations', limit: 1);
    if (existing.isNotEmpty) return;
    const seed = [
      'الرياض',
      'جدة',
      'الدمام',
      'المدينة',
      'أبها',
      'القاهرة',
      'دبي',
      'الدوحة',
    ];
    for (var i = 0; i < seed.length; i++) {
      final name = seed[i];
      await db.insert('locations', {
        'id': '${DateTime.now().microsecondsSinceEpoch}-$i',
        'name': name,
      });
    }
  }

  Future<void> _seedHajjUmrahCampaigns(Database db) async {
    final existing = await db.query('hajj_umrah_campaigns', limit: 1);
    if (existing.isNotEmpty) return;
    final now = DateTime.now();
    final start = DateTime(now.year, 11, 1);
    final end = DateTime(now.year + 1, 2, 15);

    await db.insert('hajj_umrah_campaigns', {
      'id': 'c-hajj-${now.year}',
      'name': 'حملة الحج ${now.year}',
      'type': 'hajj',
      'season_start': start.toIso8601String(),
      'season_end': end.toIso8601String(),
      'capacity': 250,
      'active': 1,
      'notes': 'الحملة الرئيسية لموسم الحج',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    await db.insert('hajj_umrah_campaigns', {
      'id': 'c-umrah-${now.year}',
      'name': 'حملة العمرة ${now.year}',
      'type': 'umrah',
      'season_start': DateTime(now.year, 9, 1).toIso8601String(),
      'season_end': DateTime(now.year + 1, 5, 1).toIso8601String(),
      'capacity': 400,
      'active': 1,
      'notes': 'حملة العمرة السنوية',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    await db.insert('hajj_umrah_groups', {
      'id': 'g-hajj-1',
      'campaign_id': 'c-hajj-${now.year}',
      'name': 'مجموعة الحج 1',
      'supervisor_name': 'مشرف المجموعة',
      'transport_plan': 'حافلات داخلية + نقل مشترك',
      'capacity': 50,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    await db.insert('hajj_umrah_groups', {
      'id': 'g-umrah-1',
      'campaign_id': 'c-umrah-${now.year}',
      'name': 'مجموعة العمرة 1',
      'supervisor_name': 'مشرف المجموعة',
      'transport_plan': 'حافلات داخلية',
      'capacity': 80,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
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
    await db.insert('admin_companies', {
      'id': company.id,
      'name': company.name,
      'description': company.description,
      'logo_path': company.logoPath,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
    await db.insert('admin_trips', {
      'id': trip.id,
      'from_region': trip.fromRegion,
      'to_region': trip.toRegion,
      'time': trip.time,
      'price_sar': trip.priceSar,
      'seats': trip.seats,
      'enabled': trip.enabled ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
    await db.insert('admin_prices', {
      'id': price.id,
      'title': price.title,
      'value_sar': price.valueSar,
      'enabled': price.enabled ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
            role: _roleFromString(row['role'] as String),
            active: (row['active'] as int) == 1,
          ),
        )
        .toList();
  }

  Future<void> upsertAdminUser(AdminUser user) async {
    final db = await database;
    await db.insert('admin_users', {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role.name,
      'active': user.active ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteAdminUser(String id) async {
    final db = await database;
    await db.delete('admin_users', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LocationEntry>> fetchLocations() async {
    final db = await database;
    final rows = await db.query('locations', orderBy: 'name ASC');
    return rows
        .map(
          (row) => LocationEntry(
            id: row['id'] as String,
            name: row['name'] as String,
          ),
        )
        .toList();
  }

  Future<void> upsertLocation(LocationEntry entry) async {
    final db = await database;
    await db.insert(
      'locations',
      {
        'id': entry.id,
        'name': entry.name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteLocation(String id) async {
    final db = await database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HajjUmrahPackage>> fetchHajjUmrahPackages() async {
    final db = await database;
    final rows = await db.query(
      'hajj_umrah_packages',
      orderBy: 'updated_at DESC',
    );
    return rows
        .map(
          (row) => HajjUmrahPackage(
            id: row['id'] as String,
            name: row['name'] as String,
            type: (row['type'] as String) == 'hajj'
                ? HajjUmrahType.hajj
                : HajjUmrahType.umrah,
            priceSar: (row['price_sar'] as num).toDouble(),
            durationDays: row['duration_days'] as int,
            hotelName: row['hotel_name'] as String,
            hotelLat: (row['hotel_lat'] as num).toDouble(),
            hotelLng: (row['hotel_lng'] as num).toDouble(),
            transportType: row['transport_type'] as String,
            maxSeats: row['max_seats'] as int,
            campaignId: row['campaign_id'] as String?,
            description: row['description'] as String,
            createdAt: DateTime.tryParse(row['created_at'] as String) ??
                DateTime.now(),
            updatedAt: DateTime.tryParse(row['updated_at'] as String) ??
                DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> upsertHajjUmrahPackage(HajjUmrahPackage pkg) async {
    final db = await database;
    await db.insert(
      'hajj_umrah_packages',
      {
        'id': pkg.id,
        'name': pkg.name,
        'type': pkg.type.name,
        'price_sar': pkg.priceSar,
        'duration_days': pkg.durationDays,
        'hotel_name': pkg.hotelName,
        'hotel_lat': pkg.hotelLat,
        'hotel_lng': pkg.hotelLng,
        'transport_type': pkg.transportType,
        'max_seats': pkg.maxSeats,
        'campaign_id': pkg.campaignId,
        'description': pkg.description,
        'created_at': pkg.createdAt.toIso8601String(),
        'updated_at': pkg.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHajjUmrahPackage(String id) async {
    final db = await database;
    await db.delete('hajj_umrah_packages', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HajjUmrahApplication>> fetchHajjUmrahApplications() async {
    final db = await database;
    final rows = await db.query(
      'hajj_umrah_applications',
      orderBy: 'created_at DESC',
    );
    return rows
        .map(
          (row) => HajjUmrahApplication(
            id: row['id'] as String,
            packageId: row['package_id'] as String,
            campaignId: row['campaign_id'] as String?,
            groupId: row['group_id'] as String?,
            userName: row['user_name'] as String,
            age: row['age'] as int,
            phone: row['phone'] as String,
            companions: row['companions'] as int,
            passportImagePath: row['passport_image_path'] as String,
            visaType: row['visa_type'] as String,
            status: _statusFromString(row['status'] as String),
            visaStatus: _visaStatusFromString(
              (row['visa_status'] as String?) ?? 'requested',
            ),
            visaReference: row['visa_reference'] as String?,
            documentStatus: _documentStatusFromString(
              (row['document_status'] as String?) ?? 'pending',
            ),
            documentNotes: row['document_notes'] as String?,
            hotelRoomType: row['hotel_room_type'] as String?,
            hotelRoomNumber: row['hotel_room_number'] as String?,
            transportPlan: row['transport_plan'] as String?,
            supervisorName: row['supervisor_name'] as String?,
            waitingList: (row['waiting_list'] as int? ?? 0) == 1,
            waitlistPosition: row['waitlist_position'] as int?,
            createdAt: DateTime.tryParse(row['created_at'] as String) ??
                DateTime.now(),
            updatedAt: DateTime.tryParse(row['updated_at'] as String) ??
                DateTime.now(),
          ),
        )
        .toList();
  }

  Future<HajjUmrahApplication?> fetchLatestApplicationForUser(
    String userName,
  ) async {
    final db = await database;
    final rows = await db.query(
      'hajj_umrah_applications',
      where: 'user_name = ?',
      whereArgs: [userName],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return HajjUmrahApplication(
      id: row['id'] as String,
      packageId: row['package_id'] as String,
      campaignId: row['campaign_id'] as String?,
      groupId: row['group_id'] as String?,
      userName: row['user_name'] as String,
      age: row['age'] as int,
      phone: row['phone'] as String,
      companions: row['companions'] as int,
      passportImagePath: row['passport_image_path'] as String,
      visaType: row['visa_type'] as String,
      status: _statusFromString(row['status'] as String),
      visaStatus: _visaStatusFromString(
        (row['visa_status'] as String?) ?? 'requested',
      ),
      visaReference: row['visa_reference'] as String?,
      documentStatus: _documentStatusFromString(
        (row['document_status'] as String?) ?? 'pending',
      ),
      documentNotes: row['document_notes'] as String?,
      hotelRoomType: row['hotel_room_type'] as String?,
      hotelRoomNumber: row['hotel_room_number'] as String?,
      transportPlan: row['transport_plan'] as String?,
      supervisorName: row['supervisor_name'] as String?,
      waitingList: (row['waiting_list'] as int? ?? 0) == 1,
      waitlistPosition: row['waitlist_position'] as int?,
      createdAt: DateTime.tryParse(row['created_at'] as String) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String) ??
          DateTime.now(),
    );
  }

  Future<void> insertHajjUmrahApplication(HajjUmrahApplication app) async {
    final db = await database;
    await db.insert('hajj_umrah_applications', {
      'id': app.id,
      'package_id': app.packageId,
      'campaign_id': app.campaignId,
      'group_id': app.groupId,
      'user_name': app.userName,
      'age': app.age,
      'phone': app.phone,
      'companions': app.companions,
      'passport_image_path': app.passportImagePath,
      'visa_type': app.visaType,
      'status': app.status.name,
      'visa_status': app.visaStatus.name,
      'visa_reference': app.visaReference,
      'document_status': app.documentStatus.name,
      'document_notes': app.documentNotes,
      'hotel_room_type': app.hotelRoomType,
      'hotel_room_number': app.hotelRoomNumber,
      'transport_plan': app.transportPlan,
      'supervisor_name': app.supervisorName,
      'waiting_list': app.waitingList ? 1 : 0,
      'waitlist_position': app.waitlistPosition,
      'created_at': app.createdAt.toIso8601String(),
      'updated_at': app.updatedAt.toIso8601String(),
    });
  }

  Future<void> updateHajjUmrahApplicationStatus(
    String id,
    HajjUmrahApplicationStatus status,
  ) async {
    final db = await database;
    await db.update(
      'hajj_umrah_applications',
      {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateHajjUmrahApplicationDetails({
    required String id,
    required HajjUmrahApplicationStatus status,
    required VisaStatus visaStatus,
    required DocumentStatus documentStatus,
    String? visaReference,
    String? documentNotes,
    String? groupId,
    String? supervisorName,
    String? transportPlan,
    String? hotelRoomType,
    String? hotelRoomNumber,
    bool? waitingList,
    int? waitlistPosition,
  }) async {
    final db = await database;
    final data = <String, Object?>{
      'status': status.name,
      'visa_status': visaStatus.name,
      'document_status': documentStatus.name,
      'visa_reference': visaReference,
      'document_notes': documentNotes,
      'group_id': groupId,
      'supervisor_name': supervisorName,
      'transport_plan': transportPlan,
      'hotel_room_type': hotelRoomType,
      'hotel_room_number': hotelRoomNumber,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (waitingList != null) {
      data['waiting_list'] = waitingList ? 1 : 0;
    }
    if (waitlistPosition != null) {
      data['waitlist_position'] = waitlistPosition;
    }
    await db.update(
      'hajj_umrah_applications',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  HajjUmrahApplicationStatus _statusFromString(String value) {
    switch (value) {
      case 'approved':
        return HajjUmrahApplicationStatus.approved;
      case 'rejected':
        return HajjUmrahApplicationStatus.rejected;
      case 'completed':
        return HajjUmrahApplicationStatus.completed;
      default:
        return HajjUmrahApplicationStatus.pending;
    }
  }

  VisaStatus _visaStatusFromString(String value) {
    switch (value) {
      case 'submitted':
        return VisaStatus.submitted;
      case 'approved':
        return VisaStatus.approved;
      case 'rejected':
        return VisaStatus.rejected;
      case 'issued':
        return VisaStatus.issued;
      default:
        return VisaStatus.requested;
    }
  }

  DocumentStatus _documentStatusFromString(String value) {
    switch (value) {
      case 'verified':
        return DocumentStatus.verified;
      case 'rejected':
        return DocumentStatus.rejected;
      default:
        return DocumentStatus.pending;
    }
  }

  Future<List<HajjUmrahCampaign>> fetchHajjUmrahCampaigns() async {
    final db = await database;
    final rows = await db.query(
      'hajj_umrah_campaigns',
      orderBy: 'season_start DESC',
    );
    return rows
        .map(
          (row) => HajjUmrahCampaign(
            id: row['id'] as String,
            name: row['name'] as String,
            type: (row['type'] as String) == 'hajj'
                ? HajjUmrahType.hajj
                : HajjUmrahType.umrah,
            seasonStart: DateTime.tryParse(row['season_start'] as String) ??
                DateTime.now(),
            seasonEnd: DateTime.tryParse(row['season_end'] as String) ??
                DateTime.now(),
            capacity: row['capacity'] as int,
            active: (row['active'] as int) == 1,
            notes: row['notes'] as String,
            createdAt: DateTime.tryParse(row['created_at'] as String) ??
                DateTime.now(),
            updatedAt: DateTime.tryParse(row['updated_at'] as String) ??
                DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> upsertHajjUmrahCampaign(HajjUmrahCampaign campaign) async {
    final db = await database;
    await db.insert(
      'hajj_umrah_campaigns',
      {
        'id': campaign.id,
        'name': campaign.name,
        'type': campaign.type.name,
        'season_start': campaign.seasonStart.toIso8601String(),
        'season_end': campaign.seasonEnd.toIso8601String(),
        'capacity': campaign.capacity,
        'active': campaign.active ? 1 : 0,
        'notes': campaign.notes,
        'created_at': campaign.createdAt.toIso8601String(),
        'updated_at': campaign.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHajjUmrahCampaign(String id) async {
    final db = await database;
    await db.delete('hajj_umrah_campaigns', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<HajjUmrahGroup>> fetchHajjUmrahGroups() async {
    final db = await database;
    final rows = await db.query(
      'hajj_umrah_groups',
      orderBy: 'created_at DESC',
    );
    return rows
        .map(
          (row) => HajjUmrahGroup(
            id: row['id'] as String,
            campaignId: row['campaign_id'] as String,
            name: row['name'] as String,
            supervisorName: row['supervisor_name'] as String,
            transportPlan: row['transport_plan'] as String,
            capacity: row['capacity'] as int,
            createdAt: DateTime.tryParse(row['created_at'] as String) ??
                DateTime.now(),
            updatedAt: DateTime.tryParse(row['updated_at'] as String) ??
                DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> upsertHajjUmrahGroup(HajjUmrahGroup group) async {
    final db = await database;
    await db.insert(
      'hajj_umrah_groups',
      {
        'id': group.id,
        'campaign_id': group.campaignId,
        'name': group.name,
        'supervisor_name': group.supervisorName,
        'transport_plan': group.transportPlan,
        'capacity': group.capacity,
        'created_at': group.createdAt.toIso8601String(),
        'updated_at': group.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHajjUmrahGroup(String id) async {
    final db = await database;
    await db.delete('hajj_umrah_groups', where: 'id = ?', whereArgs: [id]);
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
            amountSar: (row['amount_sar'] as num?)?.toDouble() ?? 0,
            userName: (row['user_name'] as String?) ?? 'غير معروف',
            workflowStatus: _workflowFromString(
              (row['workflow_status'] as String?) ?? 'received',
            ),
            assignedTo: row['assigned_to'] as String?,
            internalNotes: _decodeNotes(row['internal_notes'] as String?),
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
      'amount_sar': record.amountSar,
      'user_name': record.userName,
      'workflow_status': record.workflowStatus.name,
      'assigned_to': record.assignedTo,
      'internal_notes': jsonEncode(record.internalNotes),
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

  Future<void> insertAuditLog(AuditLog log) async {
    final db = await database;
    await db.insert('audit_logs', {
      'id': log.id,
      'actor': log.actor,
      'action': log.action,
      'target_type': log.targetType,
      'target_id': log.targetId,
      'details': log.details,
      'created_at': log.createdAt.toIso8601String(),
    });
  }

  Future<List<AuditLog>> fetchAuditLogs({int limit = 200}) async {
    final db = await database;
    final rows = await db.query(
      'audit_logs',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows
        .map(
          (row) => AuditLog(
            id: row['id'] as String,
            actor: row['actor'] as String,
            action: row['action'] as String,
            targetType: row['target_type'] as String,
            targetId: row['target_id'] as String,
            details: row['details'] as String,
            createdAt: DateTime.tryParse(row['created_at'] as String) ??
                DateTime.now(),
          ),
        )
        .toList();
  }

  Future<void> updateBookingWorkflow({
    required String ticketId,
    required WorkflowStatus workflowStatus,
    String? assignedTo,
    List<String>? internalNotes,
  }) async {
    final db = await database;
    await db.update(
      'bookings',
      {
        'workflow_status': workflowStatus.name,
        'assigned_to': assignedTo,
        if (internalNotes != null) 'internal_notes': jsonEncode(internalNotes),
      },
      where: 'ticket_id = ?',
      whereArgs: [ticketId],
    );
  }

  List<String> _decodeNotes(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return const [];
  }

  WorkflowStatus _workflowFromString(String value) {
    switch (value) {
      case 'verified':
        return WorkflowStatus.verified;
      case 'approved':
        return WorkflowStatus.approved;
      case 'paid':
        return WorkflowStatus.paid;
      case 'completed':
        return WorkflowStatus.completed;
      default:
        return WorkflowStatus.received;
    }
  }

  UserRole _roleFromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'subAdmin':
        return UserRole.subAdmin;
      case 'bookingAgent':
        return UserRole.bookingAgent;
      case 'visaOfficer':
        return UserRole.visaOfficer;
      case 'supervisor':
        return UserRole.supervisor;
      default:
        return UserRole.user;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
