enum TransactionType { income, expense, transfer }

String labelForTransactionType(TransactionType type) {
  switch (type) {
    case TransactionType.income:
      return 'Income';
    case TransactionType.expense:
      return 'Expense';
    case TransactionType.transfer:
      return 'Transfer';
  }
}

class MockAccount {
  final String id;
  final String name;

  MockAccount({required this.id, required this.name});

  MockAccount.defaultAccount(int id, {String? name})
    : id = id.toString(),
      name = name ?? 'Account $id';

  MockAccount printAccount() {
    print('Account ID: $id');
    print('Account Name: $name');
    return this;
  }
}

class MockAccountRepository {
  final List<MockAccount> _accounts = [];

  List<MockAccount> getAccounts() => _accounts;

  void _addAccount(MockAccount a) => _accounts.add(a);
  void removeAccount(MockAccount a) => _accounts.remove(a);
  void clearAccounts() => _accounts.clear();
  void addAccount(int id, {String? name}) =>
      _addAccount(MockAccount.defaultAccount(id, name: name));
}

class MockCategory {
  final String id;
  final String name;
  final String? accountId;
  final TransactionType type;

  MockCategory({
    required this.id,
    required this.name,
    this.accountId,
    required this.type,
  });

  MockCategory.defaultCategory(
    int id, {
    String? name,
    String? accountId,
    TransactionType? type,
  }) : id = id.toString(),
       name = name ?? 'Category $id',
       accountId = accountId ?? 'None',
       type = type ?? TransactionType.expense;

  MockCategory printCategory() {
    print('Category ID: $id');
    print('Category Name: $name');
    print('Account ID: ${accountId ?? "None"}');
    print('Transaction Type: ${labelForTransactionType(type)}');
    return this;
  }
}

class MockCategoryRepository {
  final List<MockCategory> _categories = [];

  List<MockCategory> getCategories() => _categories;

  void _addCategory(MockCategory c) => _categories.add(c);
  void removeCategory(MockCategory c) => _categories.remove(c);
  void clearCategories() => _categories.clear();

  void addCategory(
    int id, {
    String? name,
    String? accountId,
    TransactionType? type,
  }) => _addCategory(
    MockCategory.defaultCategory(
      id,
      name: name,
      accountId: accountId,
      type: type,
    ),
  );
}

void main() {
  var accRepo = MockAccountRepository(), catRepo = MockCategoryRepository();
  for (int i = 1; i <= 5; i++) {
    accRepo.addAccount(i);
    catRepo.addCategory(i, accountId: i.toString());
  }
  var accounts = accRepo.getAccounts(), categories = catRepo.getCategories();
  for (MockAccount account in accounts) {
    account.printAccount();
  }
  for (MockCategory category in categories) {
    category.printCategory();
  }
}
