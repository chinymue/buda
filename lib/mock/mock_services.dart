import 'mock_repos.dart';

class UserService {
  final MockUserRepo uRepo;
  final MockCategoryRepo cRepo;
  final MockTransactionRepo tRepo;

  UserService({required this.uRepo, required this.cRepo, required this.tRepo});

  void removeUser(String id) {
    tRepo.removeByUserId(id);
    cRepo.removeByUserId(id);
    uRepo.removeById(id);
  }
}

class CategoryService {
  final MockCategoryRepo cRepo;
  final MockTransactionRepo tRepo;
  CategoryService({required this.cRepo, required this.tRepo});

  void removeCategory(String id) {
    tRepo.removeByCategoryId(id);
    cRepo.removeById(id);
  }
}
