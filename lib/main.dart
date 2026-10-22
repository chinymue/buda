import 'package:flutter/material.dart';

import 'views/list_tpl.dart';
import 'data/database/app_database.dart';
import 'data/repositories/repo.dart';

// $time = Get-Date -Format "yyyyMMdd_HHmmss"
// flutter run -d chrome --web-port 8080 D:\Project\Flutter\buda_mvp\lib\main.dart 2>&1 | Tee-Object -FilePath capture_log/"web_build_$time.txt"
// $time = Get-Date -Format "yyyyMMdd_HHmmss"
// flutter run -d window D:\Project\Flutter\buda_mvp\lib\main.dart 2>&1 | Tee-Object -FilePath capture_log/"window_build_$time.txt"

late AppDatabase database;

void main() {
  database = AppDatabase();
  runApp(MyApp(db: database));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    try {
      final userRepo = UserRepo(db: db);
      final categoryRepo = CategoryRepo(db: db);
      final transactionRepo = TransactionRepo(db: db);
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: MyHomePage(
          title: 'Flutter Demo Home Page',
          uRepo: userRepo,
          cRepo: categoryRepo,
          tRepo: transactionRepo,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing repositories: $e');
      throw Exception('Error initializing repositories: $e');
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.uRepo,
    required this.cRepo,
    required this.tRepo,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final UserRepo uRepo;
  final CategoryRepo cRepo;
  final TransactionRepo tRepo;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// TODO: Add a state management solution to avoid passing the repositories down the widget tree. For now, we will pass them down to the MyHomePage widget.
class _MyHomePageState extends State<MyHomePage> {
  List<User> _users = [];
  List<Category> _categories = [];
  List<Transaction> _transactions = [];
  String _pageMsg = "", _uMsg = "", _cMsg = "", _tMsg = "";
  User? _currentUser;
  Category? _currentCategory;
  TypeEnum _currentCatgType = TypeEnum.expense,
      _currentTransType = TypeEnum.expense;

  void updateCatgType(TypeEnum newType) =>
      setState(() => _currentCatgType = newType);

  void updateTransType(TypeEnum newType) =>
      setState(() => _currentTransType = newType);

  void updateCurrentCatg(Category catg) =>
      setState(() => _currentCategory = catg);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        widget.uRepo.getAll(),
        widget.cRepo.getAll(),
        widget.tRepo.getAll(),
      ]);
      if (!mounted) return;
      setState(() {
        _users = results[0] as List<User>;
        if (_users.isNotEmpty && _currentUser == null) {
          _currentUser = _users.last;
        }
        _categories = results[1] as List<Category>;
        _transactions = results[2] as List<Transaction>;
        _pageMsg =
            _users.isEmpty && _categories.isEmpty && _transactions.isEmpty
            ? 'No data yet.'
            : '';
        _uMsg = _users.isEmpty ? 'No users yet.' : '';
        _cMsg = _categories.isEmpty ? 'No categories yet.' : '';
        _tMsg = _transactions.isEmpty ? 'No transactions yet.' : '';
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _users = [];
        _categories = [];
        _transactions = [];
        _pageMsg = 'No data yet. Error: $e';
        _uMsg = 'No users yet. \nError: $e';
        _cMsg = 'No categories yet. \nError: $e';
        _tMsg = 'No transactions yet. \nError: $e';
      });
    }
  }

  Future<void> updateUsersState() async {
    try {
      final usersList = await widget.uRepo.getAll();
      if (!mounted) return;
      setState(() {
        _users = usersList;
        if (_users.isNotEmpty && _currentUser == null) {
          _currentUser = _users.last;
        }
        _uMsg = _users.isEmpty ? 'No users yet.' : '';
        _pageMsg =
            _users.isEmpty && _categories.isEmpty && _transactions.isEmpty
            ? 'No data yet.'
            : '';
      });
    } catch (e) {
      debugPrint('Error updating users state: $e');
      setState(() {
        _users = [];
        _uMsg = 'No users yet.';
        _pageMsg = 'Error updating users state.';
      });
    }
  }

  Future<void> updateCategoriesState() async {
    try {
      final categoriesList = await widget.cRepo.getAll();
      if (!mounted) return;
      setState(() {
        _categories = categoriesList;
        _cMsg = _categories.isEmpty ? 'No categories yet.' : '';
        _pageMsg =
            _users.isEmpty && _categories.isEmpty && _transactions.isEmpty
            ? 'No data yet.'
            : '';
      });
    } catch (e) {
      debugPrint('Error updating categories state: $e');
      setState(() {
        _categories = [];
        _cMsg = 'No categories yet.';
        _pageMsg = 'Error updating categories state.';
      });
    }
  }

  Future<void> updateTransactionsState() async {
    try {
      final transactionsList = await widget.tRepo.getAll();
      if (!mounted) return;
      setState(() {
        _transactions = transactionsList;
        _tMsg = _transactions.isEmpty ? 'No transactions yet.' : '';
        _pageMsg =
            _users.isEmpty && _categories.isEmpty && _transactions.isEmpty
            ? 'No data yet.'
            : '';
      });
    } catch (e) {
      debugPrint('Error updating transactions state: $e');
      setState(() {
        _transactions = [];
        _tMsg = 'No transactions yet.';
        _pageMsg = 'Error updating transactions state.';
      });
    }
  }

  void showData() {
    showUsers();
    showCategories();
    showTransactions();
  }

  void showUsers() => _users.forEach((u) => debugPrint(u.toString()));
  void showCategories() => _categories.forEach((c) => debugPrint(c.toString()));
  void showTransactions() =>
      _transactions.forEach((t) => debugPrint(t.toString()));
  void clearData() async {
    debugPrint('Clear all data ${'-' * 100}');
    await widget.tRepo.clear();
    await widget.cRepo.clear();
    await widget.uRepo.clear();
    loadData();
    showData();
  }

  Future<void> addUser() async {
    final data = DateTime.now().toString();
    debugPrint('Add User: $data ${'-' * 100}');
    try {
      final result = await Future.wait([
        widget.uRepo.createUser(
          id: data,
          username: 'User ${_users.length + 1} $data',
        ),
        widget.uRepo.getById(data),
      ]);
      if (!mounted) return;
      setState(() {
        _users.add(result[1] as User);
        _currentUser = result[1] as User;
        _uMsg = _users.isEmpty ? 'No users yet.' : '';
        _pageMsg =
            _users.isEmpty && _categories.isEmpty && _transactions.isEmpty
            ? 'No data yet.'
            : '';
      });
      showUsers();
    } catch (e) {
      debugPrint('Error adding user: $e');
      if (!mounted) return;
      setState(() {
        _users = [];
        _uMsg = 'No users yet.';
        _pageMsg = 'Error adding user.';
      });
    }
  }

  Future<void> addCategory({String? name, TypeEnum? type}) async {
    final data = DateTime.now().toString();
    debugPrint('Add Category: $data ${'-' * 100}');
    try {
      final checkUserId =
          _currentUser?.id ?? (_users.isNotEmpty ? _users.last.id : null);
      if (checkUserId == null) {
        setState(() => _pageMsg = 'Add a user before creating a category.');
        return;
      }
      name ??= 'Category ${_categories.length + 1} $data';
      type ??= TypeEnum.expense;
      final result = await Future.wait([
        widget.cRepo.createCategory(
          id: data,
          name: name,
          type: type.name,
          userId: checkUserId,
        ),
        widget.cRepo.getById(data),
        widget.cRepo.getByAttribute(
          name: name,
          type: type.name,
          userId: checkUserId,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _categories.add(result[1] as Category);
        _currentCategory = result[1] as Category;
        _cMsg = _categories.isEmpty ? 'No categories yet.' : '';
        _pageMsg =
            _users.isEmpty && _categories.isEmpty && _transactions.isEmpty
            ? 'No data yet.'
            : '';
      });
      showCategories();
    } catch (e) {
      debugPrint('Error adding category: $e');
      if (!mounted) return;
      setState(() {
        _categories = [];
        _cMsg = 'No categories yet.';
        _pageMsg = 'Error adding category.';
      });
    }
  }

  // TODO: fix error add transaction
  Future<void> addTransaction({String? strAmount, TypeEnum? type}) async {
    final data = DateTime.now();
    debugPrint('Add Transactions: ${data.toString()} ${'-' * 100}');
    try {
      final checkUserId =
          _currentUser?.id ?? (_users.isNotEmpty ? _users.last.id : null);
      if (checkUserId == null) {
        setState(() => _pageMsg = 'Add a user before creating a transaction.');
        return;
      }
      final amount = strAmount?.trim() != null
          ? int.tryParse(strAmount!.trim())
          : data.millisecondsSinceEpoch;
      type ??= TypeEnum.expense;
      final catgId =
          _currentCategory?.id ??
          (_categories.isNotEmpty ? _categories.last.id : null);
      debugPrint('$amount; $type; $catgId');
      final result = await Future.wait([
        widget.tRepo.createTransaction(
          id: data.toString(),
          amount: amount!,
          date: data,
          categoryId: catgId,
          userId: checkUserId,
        ),
        widget.tRepo.getById(data.toString()),
        widget.tRepo.getByAttribute(
          amountMin: amount,
          type: type.name,
          categoryId: catgId,
          userId: checkUserId,
        ),
      ]);
      debugPrint('results: $result');
      if (!mounted) return;
      setState(() {
        _transactions.add(result[1] as Transaction);
        _tMsg = _transactions.isEmpty ? 'No transactions yet.' : '';
        _pageMsg =
            _users.isEmpty && _transactions.isEmpty && _transactions.isEmpty
            ? 'No data yet.'
            : '';
      });
      showTransactions();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      debugPrint('Para of method: $strAmount, $type');
      if (!mounted) return;
      setState(() {
        _transactions = [];
        _tMsg = 'No transactions yet.';
        _pageMsg = 'Error adding transaction.';
      });
    }
  }

  Future<void> removeUser(String id) async {
    debugPrint('Remove User $id ${'-' * 100}');
    if (_currentUser?.id == id && _users.isNotEmpty) {
      final index = _users.indexWhere((u) => u.id == id);
      setState(() {
        _currentUser = index > 0 ? _users[index - 1] : _users.first;
      });
    }
    await widget.tRepo.deleteByUserId(id: id);
    await widget.cRepo.deleteByUserId(id: id);
    await widget.uRepo.deleteById(id: id);
    loadData();
    showData();
  }

  Future<void> removeCategory(String id) async {
    debugPrint('Remove Category $id ${'-' * 100}');
    await widget.tRepo.deleteByCategoryId(id: id);
    await widget.cRepo.deleteById(id: id);
    loadData();
    showData();
  }

  Future<void> removeTransaction(String id) async {
    debugPrint('Remove Transaction $id ${'-' * 100}');
    await widget.tRepo.deleteById(id: id);
    await updateTransactionsState();
    showTransactions();
  }

  Future<void> filterDataOfUser(String id) async {
    debugPrint('Filter Data By userId $id ${'-' * 100}');
    final index = _users.indexWhere((u) => u.id == id);
    try {
      final result = await Future.wait([
        widget.cRepo.getByUserId(id),
        widget.tRepo.getByUserId(id),
      ]);
      if (!mounted || index == -1) return;
      setState(() {
        _categories = result[0] as List<Category>;
        _transactions = result[1] as List<Transaction>;
        _cMsg = _categories.isEmpty ? 'No categories for this user.' : '';
        _tMsg = _transactions.isEmpty ? 'No transactions for this user.' : '';
        _pageMsg = _categories.isEmpty && _transactions.isEmpty
            ? 'No data for this user.'
            : '';
        _currentUser = _users.firstWhere((u) => u.id == id);
      });
    } catch (e) {
      debugPrint('Error filtering data by user: $e');
      setState(() {
        _categories = [];
        _transactions = [];
        _cMsg = 'No categories for this user.';
        _tMsg = 'No transactions for this user.';
      });
    }
    showCategories();
    showTransactions();
  }

  Future<void> filterTransactionsByCategory(String id) async {
    debugPrint('Filter Transactions By categoryId $id ${'-' * 100}');
    try {
      final transactionsList = await widget.tRepo.getByCategoryId(id);
      if (!mounted) return;
      setState(() {
        _transactions = transactionsList;
        _tMsg = _transactions.isEmpty
            ? 'No transactions for this category.'
            : '';
      });
    } catch (e) {
      debugPrint('Error filtering transactions by category: $e');
      setState(() {
        _transactions = [];
        _tMsg = 'No transactions for this category. \nError: $e';
      });
    }
    showTransactions();
  }

  Future<void> updateUser(String username) async {
    debugPrint('Update User $username ${'-' * 100}');
    try {
      final checkUser = await widget.uRepo.getByName(username);
      final checkUserId = _currentUser != null
          ? _users.indexOf(_currentUser!)
          : -1;
      if (checkUser == null && checkUserId != -1) {
        final result = await Future.wait([
          widget.uRepo.updateUser(id: _currentUser!.id, username: username),
          widget.uRepo.getById(_currentUser!.id),
        ]);
        setState(() {
          _uMsg =
              'User ${_currentUser != null ? _currentUser!.username : 'Unknown'} has been updated to $username.';
          _currentUser = _users[checkUserId] = result[1] as User;
          _pageMsg = '';
        });
        showUsers();
      } else {
        debugPrint(
          'Username $username was already taken. Cannot update user info.',
        );
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      setState(() {
        _users = [];
        _uMsg = 'No users yet.';
        _pageMsg = 'Error updating user.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      // TODO: Refactor for one end-to-end flow of actions as if the user is using the app. For now, we will just show the data in a list.
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_pageMsg.isNotEmpty)
                    Center(
                      child: Text(
                        _pageMsg,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  if (_users.isNotEmpty ||
                      _categories.isNotEmpty ||
                      _transactions.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      children: [
                        TListTemplate(
                          maxWidth: MediaQuery.of(context).size.width * 0.3,
                          items: _users,
                          item2String: ((u) => u.username),
                          title: 'Users',
                          subtitle: _uMsg,
                          onChanged: (id, type) {
                            switch (type) {
                              case 'remove':
                                removeUser(id);
                              case 'filter':
                                filterDataOfUser(id);
                            }
                          },
                        ),
                        TListTemplate(
                          maxWidth: MediaQuery.of(context).size.width * 0.3,
                          items: _categories,
                          item2String: ((c) => c.id),
                          title: 'Categories',
                          subtitle: _cMsg,
                          onChanged: (id, type) {
                            switch (type) {
                              case 'remove':
                                removeCategory(id);
                              case 'filter':
                                filterTransactionsByCategory(id);
                            }
                          },
                        ),
                        TListTemplate(
                          maxWidth: MediaQuery.of(context).size.width * 0.3,
                          items: _transactions,
                          item2String: ((t) => t.id),
                          title: 'Transactions',
                          subtitle: _tMsg,
                          onChanged: (id, type) {
                            switch (type) {
                              case 'remove':
                                removeTransaction(id);
                            }
                          },
                        ),
                      ],
                    ),
                  // TODO: fix space gap bettween the list and the actions. For now, we will just add a SizedBox to create some space.
                  ListActionTemplate(
                    actions: [
                      ('Add user', addUser),
                      ('Add category', addCategory),
                      ('Add Transaction', addTransaction),
                      ('Clear all data', clearData),
                    ],
                  ),
                  Divider(color: Colors.grey, thickness: 2),
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: [
                      DropdownMenu(
                        width: 400,
                        label: const Text('Current User'),
                        dropdownMenuEntries: _users
                            .map(
                              (u) => DropdownMenuEntry(
                                value: u.id,
                                label: u.username,
                              ),
                            )
                            .toList(),
                        initialSelection: _currentUser?.id,
                        onSelected: (value) {
                          if (value != null) {
                            filterDataOfUser(value);
                          }
                        },
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Input username to update user info',
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            updateUser(value);
                          } else {
                            debugPrint(
                              'Username is empty. Cannot update user info.',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey, thickness: 1),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText:
                              'Input category name to create new category',
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            addCategory(name: value, type: _currentCatgType);
                          } else {
                            debugPrint(
                              'Category name is empty. Cannot create new category.',
                            );
                          }
                        },
                      ),
                      DropdownMenu(
                        width: 200,
                        label: const Text('Type'),
                        dropdownMenuEntries: TypeEnum.values
                            .map(
                              (i) => DropdownMenuEntry(value: i, label: i.name),
                            )
                            .toList(),
                        initialSelection: _currentCatgType,
                        onSelected: (value) {
                          if (value != null) {
                            updateCatgType(value);
                          }
                        },
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey, thickness: 1),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Input amount to create new transaction',
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            addTransaction(
                              strAmount: value,
                              type: _currentTransType,
                            );
                          } else {
                            debugPrint(
                              'Transaction amount is empty. Cannot create new transaction.',
                            );
                          }
                        },
                      ),
                      DropdownMenu(
                        width: 200,
                        label: const Text('Type'),
                        dropdownMenuEntries: TypeEnum.values
                            .map(
                              (i) => DropdownMenuEntry(value: i, label: i.name),
                            )
                            .toList(),
                        initialSelection: _currentTransType,
                        onSelected: (value) {
                          if (value != null) {
                            updateTransType(value);
                          }
                        },
                      ),
                      DropdownMenu(
                        width: 200,
                        label: const Text('Category'),
                        dropdownMenuEntries: _categories
                            .map(
                              (i) => DropdownMenuEntry(value: i, label: i.name),
                            )
                            .toList(),
                        initialSelection: _currentCategory,
                        onSelected: (value) {
                          if (value != null) {
                            updateCurrentCatg(value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
