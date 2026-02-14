class SecureStorageMock {
  final Map<String, String> _store = {};

  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  Future<String?> read(String key) async {
    return _store[key];
  }

  Future<void> delete(String key) async {
    _store.remove(key);
  }

  Future<void> clear() async {
    _store.clear();
  }
}
