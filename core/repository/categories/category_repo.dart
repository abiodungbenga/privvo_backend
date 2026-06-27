import 'package:mongo_dart/mongo_dart.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/model/v1/category_model.dart';
import '../../../shared/utils/id_generator.dart';
import '../../data/mongo/mongo_service.dart';

class CategoryRepo {
  Future<List<CategoryModel>> getCategories(MongoService mongoService) async {
    final collection =
        mongoService.db!.collection(AppConstants.categoryCollection);
    final documents = await collection.find().toList();
    return documents.map(CategoryModel.fromJson).toList();
  }

  Future<CategoryModel> addCategory({
    required String name,
    required String userId,
    required String description,
    required MongoService mongoService,
  }) async {
    final collection =
        mongoService.db!.collection(AppConstants.categoryCollection);
    final catModel = CategoryModel(
        id: getRandomId, name: name, description: description, userId: userId);
    await collection.insertOne(catModel.toJson());
    return catModel;
  }

  Future<void> deleteCategory({
    required String id,
    required MongoService mongoService,
  }) async {
    final collection =
        mongoService.db!.collection(AppConstants.categoryCollection);
    await collection.deleteOne({'id': id});
  }

  Future<CategoryModel> getCategory({
    required String id,
    required MongoService mongoService,
  }) async {
    final collection =
        mongoService.db!.collection(AppConstants.categoryCollection);
    final document = await collection.findOne({'id': id});
    return CategoryModel.fromJson(document!);
  }

  Future<CategoryModel> updateCategory({
    required CategoryModel category,
    required MongoService mongoService,
  }) async {
    final collection =
        mongoService.db!.collection(AppConstants.categoryCollection);
    await collection.updateOne(where.eq('id', category.id), category.toJson());
    return category;
  }
}
