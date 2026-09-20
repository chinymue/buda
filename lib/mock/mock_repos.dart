import 'mock_data.dart';

class MockUserRepo {
  final List<MockUser> _users = [
    MockUser(id: '1', username: 'username1'),
    MockUser(id: '2', username: 'username2'),
  ];

  List<MockUser> getAll() => List.unmodifiable(_users);

  MockUser? getById(String id) => _users.where((u) => u.id == id).firstOrNull;
  MockUser? getByName(String name) =>
      _users.where((u) => u.username == name.trim().toLowerCase()).firstOrNull;

  void add(MockUser user) => _users.add(user);
  void clear() => _users.clear();
  bool removeById(String id) {
    final index = _users.indexWhere((u) => u.id == id);
    if (index == -1) {
      return false;
    }
    _users.removeAt(index);
    return true;
  }

  bool removeByList(List<MockUser> uList) {
    try {
      for (final u in uList) {
        _users.remove(u);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  bool update(MockUser user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      return false;
    }
    _users[index] = user;
    return true;
  }
}

class MockCategoryRepo {
  final List<MockCategory> _categories = [
    MockCategory(
      id: '1',
      name: 'Categoryname1',
      type: TypeEnum.expense,
      userId: '1',
    ),
    MockCategory(
      id: '2',
      name: 'Categoryname2',
      type: TypeEnum.income,
      userId: '1',
    ),
  ];

  List<MockCategory> getAll() => List.unmodifiable(_categories);

  MockCategory? getById(String id) =>
      _categories.where((u) => u.id == id).firstOrNull;
  MockCategory? getByName(String name) => _categories
      .where((u) => u.name.toLowerCase() == name.trim().toLowerCase())
      .firstOrNull;
  List<MockCategory> getByType(TypeEnum type) =>
      _categories.where((c) => c.type == type).toList();
  List<MockCategory> getByUser(String userId) =>
      _categories.where((c) => c.userId == userId).toList();

  void add(MockCategory category) => _categories.add(category);
  void clear() => _categories.clear();
  bool removeById(String id) {
    final index = _categories.indexWhere((u) => u.id == id);
    if (index == -1) {
      return false;
    }
    _categories.removeAt(index);
    return true;
  }

  void removeByUserId(String id) =>
      _categories.removeWhere((c) => c.userId == id);

  bool update(MockCategory category) {
    final index = _categories.indexWhere((u) => u.id == category.id);
    if (index == -1) {
      return false;
    }
    _categories[index] = category;
    return true;
  }
}

class MockTransactionRepo {
  final List<MockTransaction> _transactions = [
    MockTransaction(
      id: '1',
      amount: 100,
      type: TypeEnum.expense,
      date: DateTime(2026, 09, 16),
      categoryId: '1',
      userId: '1',
    ),
    MockTransaction(
      id: '2',
      amount: 20000,
      type: TypeEnum.income,
      date: DateTime(2026, 09, 16),
      userId: '1',
    ),
  ];

  List<MockTransaction> getAll() => List.unmodifiable(_transactions);

  MockTransaction? getById(String id) =>
      _transactions.where((u) => u.id == id).firstOrNull;
  List<MockTransaction> getByType(TypeEnum type) =>
      _transactions.where((t) => t.type == type).toList();

  List<MockTransaction> getByCategory(String categoryId) =>
      _transactions.where((t) => t.categoryId == categoryId).toList();

  List<MockTransaction> getByUser(String userId) =>
      _transactions.where((t) => t.userId == userId).toList();

  void add(MockTransaction transaction) => _transactions.add(transaction);
  void clear() => _transactions.clear();
  bool removeById(String id) {
    final index = _transactions.indexWhere((u) => u.id == id);
    if (index == -1) {
      return false;
    }
    _transactions.removeAt(index);
    return true;
  }

  void removeByUserId(String id) =>
      _transactions.removeWhere((t) => t.userId == id);
  void removeByCategoryId(String id) =>
      _transactions.removeWhere((t) => t.categoryId == id);

  bool update(MockTransaction transaction) {
    final index = _transactions.indexWhere((u) => u.id == transaction.id);
    if (index == -1) {
      return false;
    }
    _transactions[index] = transaction;
    return true;
  }
}
