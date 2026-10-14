import 'package:flutter/material.dart';

import 'views/list_tpl.dart';
import 'data/database/app_database.dart';
import 'data/repositories/repo.dart';

// $time = Get-Date -Format "yyyyMMdd_HHmmss"
// flutter run -d chrome --web-port 8080 D:\Project\Flutter\buda_mvp\lib\main.dart 2>&1 | Tee-Object -FilePath capture_log/"web_build_$time.txt"
// $time = Get-Date -Format "yyyyMMdd_HHmmss"
// flutter run -d window D:\Project\Flutter\buda_mvp\lib\main.dart 2>&1 | Tee-Object -FilePath capture_log/"window_build_$time.txt"
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appDb = AppDatabase();
    final userRepo = UserRepo(db: appDb);
    final categoryRepo = CategoryRepo(db: appDb);
    final transactionRepo = TransactionRepo(db: appDb);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        uRepo: userRepo,
        cRepo: categoryRepo,
        tRepo: transactionRepo,
      ),
    );
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
  late List<User> _users;
  late List<Category> _categories;
  late List<Transaction> _transactions;
  String _pageMsg = "", _uMsg = "", _cMsg = "", _tMsg = "";

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
      print('Error loading data: $e');
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
        _uMsg = _users.isEmpty ? 'No users yet.' : '';
      });
    } catch (e) {
      print('Error updating users state: $e');
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
      });
    } catch (e) {
      print('Error updating categories state: $e');
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
      });
    } catch (e) {
      print('Error updating transactions state: $e');
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

  void showUsers() => _users.forEach((u) => print(u.toString()));
  void showCategories() => _categories.forEach((c) => print(c.toString()));
  void showTransactions() => _transactions.forEach((t) => print(t.toString()));

  Future<void> addUser() async {
    try {
      final data = DateTime.now().toString();
      await widget.uRepo.createUser(
        id: data,
        username: 'User ${_users.length + 1} $data',
      );
      await updateUsersState();
      showUsers();
    } catch (e) {
      print('Error adding user: $e');
      setState(() {
        _users = [];
        _uMsg = 'No users yet.';
        _pageMsg = 'Error adding user.';
      });
    }
  }

  Future<void> addCategory() async {
    try {
      final data = DateTime.now().toString();
      print('Add Category: $data ${'-' * 100}');
      await widget.cRepo.createCategory(
        id: data,
        name: 'Category ${_categories.length + 1} $data',
        userId: _users.isNotEmpty ? _users.last.id : 'default_user_id',
      );
      await updateCategoriesState();
      showCategories();
    } catch (e) {
      print('Error adding category: $e');
      setState(() {
        _categories = [];
        _cMsg = 'No categories yet.';
        _pageMsg = 'Error adding category.';
      });
    }
  }

  Future<void> addTransaction() async {
    try {
      final data = DateTime.now();
      print('Add Transactions: ${data.toString()} ${'-' * 100}');
      if (_categories.isNotEmpty) {
        await widget.tRepo.createTransaction(
          id: data.toString(),
          amount: data.millisecondsSinceEpoch,
          date: data,
          categoryId: _categories.last.id,
          userId: _users.isNotEmpty ? _users.last.id : 'default_user_id',
        );
      } else {
        await widget.tRepo.createTransaction(
          id: data.toString(),
          amount: data.millisecondsSinceEpoch,
          date: data,
          userId: _users.isNotEmpty ? _users.last.id : 'default_user_id',
        );
      }

      await updateTransactionsState();
      showTransactions();
    } catch (e) {
      print('Error adding transaction: $e');
      setState(() {
        _transactions = [];
        _tMsg = 'No transactions yet.';
        _pageMsg = 'Error adding transaction.';
      });
    }
  }

  Future<void> removeUser(String id) async {
    print('Remove User $id ${'-' * 100}');
    await widget.tRepo.deleteByUserId(id: id);
    await widget.cRepo.deleteByUserId(id: id);
    await widget.uRepo.deleteById(id: id);
    loadData();
    showData();
  }

  Future<void> removeCategory(String id) async {
    print('Remove Category $id ${'-' * 100}');
    await widget.tRepo.deleteByCategoryId(id: id);
    await widget.cRepo.deleteById(id: id);
    loadData();
    showData();
  }

  Future<void> removeTransaction(String id) async {
    print('Remove Transaction $id ${'-' * 100}');
    await widget.tRepo.deleteById(id: id);
    await updateTransactionsState();
    showTransactions();
  }

  Future<void> filterDataOfUser(String id) async {
    print('Filter Data By userId $id ${'-' * 100}');
    try {
      final categoriesList = await widget.cRepo.getByUserId(id);
      final transactionsList = await widget.tRepo.getByUserId(id);
      if (!mounted) return;
      setState(() {
        _categories = categoriesList;
        _transactions = transactionsList;
        _cMsg = _categories.isEmpty ? 'No categories for this user.' : '';
        _tMsg = _transactions.isEmpty ? 'No transactions for this user.' : '';
      });
    } catch (e) {
      print('Error filtering data by user: $e');
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
    print('Filter Transactions By categoryId $id ${'-' * 100}');
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
      print('Error filtering transactions by category: $e');
      setState(() {
        _transactions = [];
        _tMsg = 'No transactions for this category. \nError: $e';
      });
    }
    showTransactions();
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
      body: Center(
        child: Column(
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
              SizedBox(
                height: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TListTemplate(
                      maxWidth: 300,
                      items: _users,
                      item2String: ((u) => u.id),
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
                      maxWidth: 300,
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
                      maxWidth: 300,
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
              ),
            SizedBox(height: 10),
            ListActionTemplate(
              actions: [
                ('Add user', addUser),
                ('Add category', addCategory),
                ('Add Transaction', addTransaction),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
