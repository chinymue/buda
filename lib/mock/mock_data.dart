// ignore_for_file: avoid_print

enum TypeEnum { income, expense, transfer }

String labelForTypeEnum(TypeEnum type) {
  switch (type) {
    case TypeEnum.income:
      return 'Income';
    case TypeEnum.expense:
      return 'Expense';
    case TypeEnum.transfer:
      return 'Transfer';
  }
}

class MockUser {
  String id;
  String username;
  MockUser({required this.id, required this.username});

  String toStr() => 'User: {id: $id, username: $username}';
}

class MockCategory {
  String id;
  String name;
  TypeEnum type;
  String userId;
  MockCategory({
    required this.id,
    this.name = 'New Category',
    this.type = TypeEnum.expense,
    required this.userId,
  });

  String toStr() =>
      'Category: {id: $id, name: $name, type: $type, userId: $userId}';
}

class MockTransaction {
  String id;
  int amount;
  TypeEnum type;
  DateTime date;
  String? categoryId;
  String userId;
  MockTransaction({
    required this.id,
    required this.amount,
    this.type = TypeEnum.expense,
    required this.date,
    this.categoryId,
    required this.userId,
  });

  MockTransaction.defaultTransaction(
    this.id,
    this.amount,
    type,
    this.categoryId,
    this.userId,
  ) : type = type ?? TypeEnum.expense, // TODO: Resolve conflict if category and trans diff in type
      date = DateTime.now();

  String toStr() =>
      'Transaction: {id: $id, amount: $amount, type: $type, '
      'date: $date, categoryId: $categoryId, userId: $userId}';
}

void main() {
  final testUser = MockUser(id: 'id_user', username: 'username');
  print('User: ${testUser.id}, ${testUser.username}');
  final testCategory = MockCategory(id: 'id_categ', userId: testUser.id);
  print(
    'Category: ${testCategory.id}, ${testCategory.name}, ${testCategory.type}, ${testCategory.userId}',
  );
  final testTransNoCateg = MockTransaction(
    id: 'id_trans',
    amount: 10,
    date: DateTime.now(),
    userId: testUser.id,
  );
  print(
    'Transaction no category: ${testTransNoCateg.id}, ${testTransNoCateg.amount}, ${testTransNoCateg.type}, '
    '${testTransNoCateg.date}, ${testTransNoCateg.categoryId}, ${testTransNoCateg.userId}',
  );

  final testTransWCateg = MockTransaction(
    id: 'id_trans2',
    amount: 10,
    date: DateTime.now(),
    type: testCategory.type,
    categoryId: testCategory.id,
    userId: testUser.id,
  );
  print(
    'Transaction with category: ${testTransWCateg.id}, ${testTransWCateg.amount}, ${testTransWCateg.type}, '
    '${testTransWCateg.date}, ${testTransWCateg.categoryId}, ${testTransWCateg.userId}',
  );
  final testTransDefault = MockTransaction.defaultTransaction(
    'id_trans_def',
    1000,
    null,
    testCategory.id,
    testUser.id,
  );
  print(
    'Transaction default: ${testTransDefault.id}, ${testTransDefault.amount}, ${testTransDefault.type}, '
    '${testTransDefault.date}, ${testTransDefault.categoryId}, ${testTransDefault.userId}',
  );
  final incomeCateg = MockCategory(
    id: 'id_categ2',
    type: TypeEnum.income,
    userId: testUser.id,
  );
  print(
    'Category: ${incomeCateg.id}, ${incomeCateg.name}, ${incomeCateg.type}, ${incomeCateg.userId}',
  );
  final incomeTrans = MockTransaction.defaultTransaction(
    'id_trans3',
    1700,
    incomeCateg.type,
    incomeCateg.id,
    testUser.id,
  );
  print(
    'Transaction default: ${incomeTrans.id}, ${incomeTrans.amount}, ${incomeTrans.type}, '
    '${incomeTrans.date}, ${incomeTrans.categoryId}, ${incomeTrans.userId}',
  );
  final incomeTagTrans = MockTransaction.defaultTransaction(
    'id_trans4',
    1700,
    null,
    incomeCateg.id,
    testUser.id,
  );
  print(
    'Transaction default: ${incomeTagTrans.id}, ${incomeTagTrans.amount}, ${incomeTagTrans.type}, '
    '${incomeTagTrans.date}, ${incomeTagTrans.categoryId}, ${incomeTagTrans.userId}',
  );
}
