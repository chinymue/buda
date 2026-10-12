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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final appDb = AppDatabase();
    final userRepo = UserRepo(db: appDb);
    final categoryRepo = CategoryRepo(db: appDb);
    final transactionRepo = TransactionRepo(db: appDb);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
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

class _MyHomePageState extends State<MyHomePage> {
  late List<User> _users;
  late List<Category> _categories;
  late List<Transaction> _transactions;

  Future<void> updateUsersState() async {
    try {
      final usersList = await widget.uRepo.getAll();
      if (!mounted) return;
      setState(() => _users = usersList);
    } catch (e) {
      print('Error updating users state: $e');
      setState(() => _users = []);
    }
  }

  Future<void> updateCategoriesState() async {
    try {
      final categoriesList = await widget.cRepo.getAll();
      if (!mounted) return;
      setState(() => _categories = categoriesList);
    } catch (e) {
      print('Error updating categories state: $e');
      setState(() => _categories = []);
    }
  }

  Future<void> updateTransactionsState() async {
    try {
      final transactionsList = await widget.tRepo.getAll();
      if (!mounted) return;
      setState(() => _transactions = transactionsList);
    } catch (e) {
      print('Error updating transactions state: $e');
      setState(() => _transactions = []);
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final usersList = await widget.uRepo.getAll();
      final categoriesList = await widget.cRepo.getAll();
      final transactionsList = await widget.tRepo.getAll();
      if (!mounted) return;
      setState(() {
        _users = usersList;
        _categories = categoriesList;
        _transactions = transactionsList;
      });
    } catch (e) {
      print('Error loading data: $e');
      // TODO: Handle empty database case, show message to user
      setState(() {
        _users = [];
        _categories = [];
        _transactions = [];
      });
    }
  }

  Future<void> addUser() async {
    final data = DateTime.now().toString();
    print('Add User: $data ${'-' * 100}');
    await widget.uRepo.createUser(
      id: data,
      username: 'User ${_users.length + 1} $data',
    );
    await updateUsersState();
    showUsers();
  }

  Future<void> addCategory() async {
    final data = DateTime.now().toString();
    print('Add Category: $data ${'-' * 100}');
    await widget.cRepo.createCategory(
      id: data,
      name: 'Category ${_categories.length + 1} $data',
      userId: _users.isNotEmpty ? _users.last.id : 'default_user_id',
    );
    await updateCategoriesState();
    showCategories();
  }

  Future<void> addTransaction() async {
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
  }

  Future<void> removeUser(String id) async {
    print('Remove User $id ${'-' * 100}');
    await widget.tRepo.deleteByUserId(id: id);
    await widget.cRepo.deleteByUserId(id: id);
    await widget.uRepo.deleteById(id: id);
    _loadData();
    showData();
  }

  Future<void> removeCategory(String id) async {
    print('Remove Category $id ${'-' * 100}');
    await widget.tRepo.deleteByCategoryId(id: id);
    await widget.cRepo.deleteById(id: id);
    _loadData();
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
      });
    } catch (e) {
      print('Error filtering data by user: $e');
      setState(() {
        _categories = [];
        _transactions = [];
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
      setState(() => _transactions = transactionsList);
    } catch (e) {
      print('Error filtering transactions by category: $e');
      setState(() => _transactions = []);
    }
    showTransactions();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
