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
  Category? _currentCategory, _editingCategory;
  Transaction? _currentTransaction, _editingTransaction;
  final _categoryNameController = TextEditingController();
  final _transactionAmountController = TextEditingController();
  final _categoryFormKey = GlobalKey<FormState>();
  final _transactionFormKey = GlobalKey<FormState>();
  String? _categoryFormError, _transactionFormError;
  bool _isSavingCategory = false, _isSavingTransaction = false;
  TypeEnum _categoryFormType = TypeEnum.expense,
      _transactionFormType = TypeEnum.expense;
  TypeEnum _currentTransType = TypeEnum.expense;

  @override
  void dispose() {
    _categoryNameController.dispose();
    _transactionAmountController.dispose();
    super.dispose();
  }

  void startNewCategoryForm() {
    setState(() {
      _editingCategory = null;
      _categoryNameController.clear();
      _categoryFormType = TypeEnum.expense;
      _categoryFormError = null;
    });
  }

  void editCategory(Category category) {
    setState(() {
      _editingCategory = category;
      _categoryNameController.text = category.name;
      _categoryFormType = TypeEnum.values.firstWhere(
        (type) => type.name == category.type,
      );
      _categoryFormError = null;
    });
  }

  void cancelCategoryEdit() {
    setState(() {
      _editingCategory = null;
      _categoryNameController.clear();
      _categoryFormType = TypeEnum.expense;
      _categoryFormError = null;
    });
  }

  void updateCategoryFormType(TypeEnum newType) =>
      setState(() => _categoryFormType = newType);

  void startNewTransactionForm() {
    setState(() {
      _editingTransaction = null;
      _transactionAmountController.clear();
      _transactionFormType = TypeEnum.expense;
      _transactionFormError = null;
    });
  }

  void editTransaction(Transaction transaction) {
    setState(() {
      _editingTransaction = transaction;
      _transactionAmountController.text = transaction.amount.toString();
      _transactionFormType = TypeEnum.values.firstWhere(
        (type) => type.name == transaction.type,
      );
      _transactionFormError = null;
    });
  }

  void cancelTransactionEdit() {
    setState(() {
      _editingTransaction = null;
      _transactionAmountController.clear();
      _transactionFormType = TypeEnum.expense;
      _transactionFormError = null;
    });
  }

  void updateTransactionFormType(TypeEnum newType) =>
      setState(() => _transactionFormType = newType);

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
      if (!mounted) return;
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
      if (!mounted) return;
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
      if (!mounted) return;
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
      final result = await widget.uRepo.createUser(
        id: data,
        username: 'User ${_users.length + 1} $data',
      );
      if (!mounted) return;
      setState(() {
        if (result != null) {
          _users.add(result);
          _currentUser = result;
        }
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

  Future<void> saveCategory() async {
    if (_isSavingCategory ||
        !(_categoryFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final userId =
        _currentUser?.id ?? (_users.isNotEmpty ? _users.last.id : null);
    if (userId == null && _editingCategory == null) {
      setState(
        () => _categoryFormError = 'Add a user before creating a category.',
      );
      return;
    }

    final name = _categoryNameController.text.trim();
    final type = _categoryFormType;
    final categoryBeingEdited = _editingCategory;
    setState(() {
      _isSavingCategory = true;
      _categoryFormError = null;
    });

    try {
      late final Category result;
      if (categoryBeingEdited == null) {
        final id = DateTime.now().toString();
        final createdCategory = await widget.cRepo.createCategory(
          id: id,
          name: name,
          type: type.name,
          userId: userId!,
        );
        if (createdCategory == null) {
          throw StateError('Category creation returned no category.');
        }
        result = createdCategory;
      } else {
        final updatedCount = await widget.cRepo.updateCategory(
          id: categoryBeingEdited.id,
          name: name,
          type: type.name,
        );
        if (updatedCount == 0) {
          throw StateError('No category was updated.');
        }
        final updatedCategory = await widget.cRepo.getById(
          categoryBeingEdited.id,
        );
        if (updatedCategory == null) {
          throw StateError('Updated category could not be loaded.');
        }
        result = updatedCategory;
      }

      if (!mounted) return;
      setState(() {
        if (categoryBeingEdited == null) {
          _categories.add(result);
          _currentCategory = result;
        } else {
          final index = _categories.indexWhere(
            (category) => category.id == result.id,
          );
          if (index != -1) _categories[index] = result;
          if (_currentCategory?.id == result.id) _currentCategory = result;
        }
        _editingCategory = null;
        _categoryNameController.clear();
        _categoryFormType = TypeEnum.expense;
        _categoryFormError = null;
        _cMsg = _categories.isEmpty ? 'No categories yet.' : '';
        _pageMsg =
            _users.isEmpty && _categories.isEmpty && _transactions.isEmpty
            ? 'No data yet.'
            : '';
      });
      showCategories();
    } catch (e) {
      debugPrint('Error saving category: $e');
      if (!mounted) return;
      setState(() {
        _categoryFormError = 'Could not save category. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSavingCategory = false);
      }
    }
  }

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
      final result = await widget.tRepo.createTransaction(
        id: data.toString(),
        amount: amount!,
        date: data,
        categoryId: catgId,
        userId: checkUserId,
      );
      debugPrint('results: $result');
      if (!mounted) return;
      setState(() {
        if (result != null) _transactions.add(result);
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

  Future<void> saveTransaction() async {
    if (_isSavingTransaction ||
        !(_transactionFormKey.currentState?.validate() ?? false)) {
      return;
    }

    final userId =
        _currentUser?.id ?? (_users.isNotEmpty ? _users.last.id : null);
    if (userId == null && _editingTransaction == null) {
      setState(
        () =>
            _transactionFormError = 'Add a user before creating a transaction.',
      );
      return;
    }

    final amount = int.tryParse(_transactionAmountController.text.trim()) ?? 0;
    final type = _transactionFormType;
    final catgId =
        _currentCategory?.id ??
        (_categories.isNotEmpty ? _categories.last.id : null);
    final transactionBeingEdited = _editingTransaction;
    setState(() {
      _isSavingTransaction = true;
      _transactionFormError = null;
    });

    try {
      late final Transaction result;
      if (transactionBeingEdited == null) {
        final id = DateTime.now().toString();
        final createdTransaction = await widget.tRepo.createTransaction(
          id: id,
          amount: amount,
          type: type.name,
          categoryId: catgId,
          userId: userId!,
        );
        if (createdTransaction == null) {
          throw StateError('Transaction creation returned no transaction.');
        }
        result = createdTransaction;
      } else {
        final updatedCount = await widget.tRepo.updateT(
          transactionBeingEdited.id,
          amount: amount,
          type: type.name,
        );
        if (updatedCount == 0) {
          throw StateError('No transaction was updated.');
        }
        final updatedTransaction = await widget.tRepo.getById(
          transactionBeingEdited.id,
        );
        if (updatedTransaction == null) {
          throw StateError('Updated transaction could not be loaded.');
        }
        result = updatedTransaction;
      }

      if (!mounted) return;
      setState(() {
        if (transactionBeingEdited == null) {
          _transactions.add(result);
          _currentTransaction = result;
        } else {
          final index = _transactions.indexWhere(
            (transaction) => transaction.id == result.id,
          );
          if (index != -1) _transactions[index] = result;
          if (_currentTransaction?.id == result.id) {
            _currentTransaction = result;
          }
        }
        _editingTransaction = null;
        _transactionAmountController.clear();
        _transactionFormType = TypeEnum.expense;
        _transactionFormError = null;
        _tMsg = _transactions.isEmpty ? 'No transactions yet.' : '';
        _pageMsg =
            _users.isEmpty && _categories.isEmpty && _transactions.isEmpty
            ? 'No data yet.'
            : '';
      });
      showTransactions();
    } catch (e) {
      debugPrint('Error saving transaction: $e');
      if (!mounted) return;
      setState(() {
        _transactionFormError = 'Could not save transaction. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSavingTransaction = false);
      }
    }
  }

  Future<void> removeUser(String id) async {
    debugPrint('Remove User $id ${'-' * 100}');
    if (_currentUser?.id == id && _users.isNotEmpty) {
      final index = _users.indexWhere((u) => u.id == id);
      if (!mounted) return;
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
    if (_editingCategory?.id == id) cancelCategoryEdit();
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

  Future<void> filterDataOfUser(User u) async {
    debugPrint('Filter Data By userId ${u.id} ${'-' * 100}');
    final index = _users.indexWhere((user) => user.id == u.id);
    try {
      final result = await Future.wait([
        widget.cRepo.getByUserId(u.id),
        widget.tRepo.getByUserId(u.id),
      ]);
      if (!mounted || index == -1) return;
      setState(() {
        _currentUser = u;
        _categories = result[0] as List<Category>;
        if (_categories.isNotEmpty) _currentCategory = _categories.last;
        _transactions = result[1] as List<Transaction>;
        _cMsg = _categories.isEmpty ? 'No categories for this user.' : '';
        _tMsg = _transactions.isEmpty ? 'No transactions for this user.' : '';
        _pageMsg = _categories.isEmpty && _transactions.isEmpty
            ? 'No data for this user.'
            : '';
      });
    } catch (e) {
      debugPrint('Error filtering data by user: $e');
      if (!mounted) return;
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

  Future<void> filterTransactionsByCategory(Category c) async {
    debugPrint('Filter Transactions By categoryId ${c.id} ${'-' * 100}');
    try {
      final transactionsList = await widget.tRepo.getByCategoryId(c.id);
      if (!mounted) return;
      setState(() {
        _currentCategory = c;
        _transactions = transactionsList;
        _tMsg = _transactions.isEmpty
            ? 'No transactions for this category.'
            : '';
      });
    } catch (e) {
      debugPrint('Error filtering transactions by category: $e');
      if (!mounted) return;
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
        final result = await widget.uRepo.updateUser(
          id: _currentUser!.id,
          username: username,
        );
        if (result == null) {
          debugPrint('Update user info gone wrong, no result.');
          return;
        }
        if (!mounted) return;
        setState(() {
          _uMsg =
              'User ${_currentUser != null ? _currentUser!.username : 'Unknown'} has been updated to $username.';
          _currentUser = _users[checkUserId] = result;
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
      if (!mounted) return;
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
                      // TODO: change list template call as newest update of widget
                      children: [
                        TListTemplate(
                          maxWidth: MediaQuery.of(context).size.width * 0.3,
                          items: _users,
                          item2String: ((u) => u.username),
                          title: 'Users',
                          subtitle: _uMsg,
                          actions: const {
                            ListItemAction.remove,
                            ListItemAction.filter,
                          },
                          onAction: (user, action) {
                            switch (action) {
                              case ListItemAction.remove:
                                removeUser(user.id);
                              case ListItemAction.filter:
                                filterDataOfUser(user);
                              case ListItemAction.edit:
                                break;
                            }
                          },
                        ),
                        TListTemplate(
                          maxWidth: MediaQuery.of(context).size.width * 0.3,
                          items: _categories,
                          item2String: ((c) => c.name),
                          title: 'Categories',
                          subtitle: _cMsg,
                          actions: const {
                            ListItemAction.remove,
                            ListItemAction.edit,
                            ListItemAction.filter,
                          },
                          onAction: (catg, action) {
                            switch (action) {
                              case ListItemAction.remove:
                                removeCategory(catg.id);
                              case ListItemAction.edit:
                                editCategory(catg);
                              case ListItemAction.filter:
                                filterTransactionsByCategory(catg);
                            }
                          },
                        ),
                        TListTemplate(
                          maxWidth: MediaQuery.of(context).size.width * 0.3,
                          items: _transactions,
                          item2String: ((t) => t.id),
                          title: 'Transactions',
                          subtitle: _tMsg,
                          actions: const {ListItemAction.remove},
                          onAction: (trans, action) {
                            switch (action) {
                              case ListItemAction.remove:
                                removeTransaction(trans.id);
                              case ListItemAction.filter:
                                break;
                              case ListItemAction.edit:
                                editTransaction(trans);
                            }
                          },
                        ),
                      ],
                    ),
                  // TODO: fix space gap bettween the list and the actions. For now, we will just add a SizedBox to create some space.
                  ListActionTemplate(
                    actions: [
                      ('Add user', addUser),
                      ('Add category', startNewCategoryForm),
                      ('Add Transaction', startNewTransactionForm),
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
                                value: u,
                                label: u.username,
                              ),
                            )
                            .toList(),
                        initialSelection: _currentUser,
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
                  Form(
                    key: _categoryFormKey,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextFormField(
                          controller: _categoryNameController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: _editingCategory == null
                                ? 'Category name'
                                : 'Edit category name',
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => saveCategory(),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter a category name.'
                              : null,
                        ),
                        DropdownMenu<TypeEnum>(
                          key: ValueKey(_categoryFormType),
                          width: 200,
                          label: const Text('Type'),
                          dropdownMenuEntries: TypeEnum.values
                              .map(
                                (type) => DropdownMenuEntry(
                                  value: type,
                                  label: type.name,
                                ),
                              )
                              .toList(),
                          initialSelection: _categoryFormType,
                          onSelected: (value) {
                            if (value != null) {
                              updateCategoryFormType(value);
                            }
                          },
                        ),
                        ElevatedButton(
                          onPressed: _isSavingCategory ? null : saveCategory,
                          child: _isSavingCategory
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _editingCategory == null
                                      ? 'Create category'
                                      : 'Save changes',
                                ),
                        ),
                        if (_editingCategory != null)
                          TextButton(
                            onPressed: _isSavingCategory
                                ? null
                                : cancelCategoryEdit,
                            child: const Text('Cancel'),
                          ),
                        if (_categoryFormError != null)
                          Text(
                            _categoryFormError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey, thickness: 1),
                  Form(
                    key: _transactionFormKey,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextFormField(
                          controller: _transactionAmountController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: _editingTransaction == null
                                ? 'Transaction amount'
                                : 'Edit transaction amount',
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => saveTransaction(),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter a valid amount.'
                              : null,
                        ),
                        DropdownMenu<TypeEnum>(
                          key: ValueKey(_transactionFormKey),
                          width: 200,
                          label: const Text('Type'),
                          dropdownMenuEntries: TypeEnum.values
                              .map(
                                (type) => DropdownMenuEntry(
                                  value: type,
                                  label: type.name,
                                ),
                              )
                              .toList(),
                          initialSelection: _transactionFormType,
                          onSelected: (value) {
                            if (value != null) {
                              updateTransactionFormType(value);
                            }
                          },
                        ),
                        ElevatedButton(
                          onPressed: _isSavingTransaction
                              ? null
                              : saveTransaction,
                          child: _isSavingTransaction
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _editingTransaction == null
                                      ? 'Create transaction'
                                      : 'Save changes',
                                ),
                        ),
                        if (_editingTransaction != null)
                          TextButton(
                            onPressed: _isSavingTransaction
                                ? null
                                : cancelTransactionEdit,
                            child: const Text('Cancel'),
                          ),
                        if (_transactionFormError != null)
                          Text(
                            _transactionFormError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
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
