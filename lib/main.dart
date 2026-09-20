import 'package:flutter/material.dart';
import 'package:buda_mvp/views/list_tpl.dart';

import 'mock/mock_repos.dart';
import 'mock/mock_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final userRepo = MockUserRepo();
    final categoryRepo = MockCategoryRepo();
    final transactionRepo = MockTransactionRepo();
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
  final MockUserRepo uRepo;
  final MockCategoryRepo cRepo;
  final MockTransactionRepo tRepo;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<MockUser> _users;
  late List<MockCategory> _categories;
  late List<MockTransaction> _transactions;

  void updateState() => setState(() {
    _users = widget.uRepo.getAll();
    _categories = widget.cRepo.getAll();
    _transactions = widget.tRepo.getAll();
  });
  void updateUsersState() => setState(() => _users = widget.uRepo.getAll());
  void updateCategoriesState() =>
      setState(() => _categories = widget.cRepo.getAll());
  void updateTransactionsState() =>
      setState(() => _transactions = widget.tRepo.getAll());

  void showData() {
    showUsers();
    showCategories();
    showTransactions();
  }

  void showUsers() => _users.forEach((u) => print(u.toStr()));
  void showCategories() => _categories.forEach((c) => print(c.toStr()));
  void showTransactions() => _transactions.forEach((t) => print(t.toStr()));

  @override
  void initState() {
    super.initState();
    _users = widget.uRepo.getAll();
    _categories = widget.cRepo.getAll();
    _transactions = widget.tRepo.getAll();
  }

  void addUser() {
    final data = DateTime.now().toString();
    print('Add User: $data ${'-' * 100}');
    widget.uRepo.add(MockUser(id: data, username: 'User ${_users.length + 1}'));
    updateUsersState();
    showUsers();
  }

  void addCategory() {
    final data = DateTime.now().toString();
    print('Add Category: $data ${'-' * 100}');
    widget.cRepo.add(
      MockCategory(
        id: data,
        name: 'Category ${_categories.length + 1}',
        userId: _users.last.id,
      ),
    );
    updateCategoriesState();
    showCategories();
  }

  void addTransaction() {
    final data = DateTime.now();
    print('Add Transactions: ${data.toString()} ${'-' * 100}');
    widget.tRepo.add(
      MockTransaction(
        id: data.toString(),
        amount: data.millisecondsSinceEpoch,
        date: data,
        categoryId: _categories.last.id,
        userId: _users.last.id,
      ),
    );
    updateTransactionsState();
    showTransactions();
  }

  void removeUser(String id) {
    print('Remove User $id ${'-' * 100}');
    widget.tRepo.removeByUserId(id);
    widget.cRepo.removeByUserId(id);
    widget.uRepo.removeById(id);
    updateState();
    showData();
  }

  void removeCategory(String id) {
    print('Remove Category $id ${'-' * 100}');
    widget.tRepo.removeByCategoryId(id);
    widget.cRepo.removeById(id);
    updateTransactionsState();
    updateCategoriesState();
    showCategories();
    showTransactions();
  }

  void removeTransaction(String id) {
    print('Remove Transaction $id ${'-' * 100}');
    widget.tRepo.removeById(id = id);
    updateTransactionsState();
    showTransactions();
  }

  void filterDataOfUser(String id) {
    print('Filter Data By userId $id ${'-' * 100}');
    setState(() {
      _categories = widget.cRepo.getByUser(id);
      _transactions = widget.tRepo.getByUser(id);
    });
    showCategories();
    showTransactions();
  }

  void filterTransactionsByCategory(String id) {
    print('Filter Transactions By categoryId $id ${'-' * 100}');
    setState(() => _transactions = widget.tRepo.getByCategory(id));
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
