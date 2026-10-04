import 'package:injectable/injectable.dart';

import '../../../application/core/utils/helpers/cache/db.dart';
import '../../models/enums/db_boxes.dart';
import '../../models/request_model/tasks/successful_status_model/successful_status_request_model.dart';
import 'tasks_local_datasource.dart';

@Injectable(as: TasksLocalDataSource)
class TasksLocalDataSourceImpl implements TasksLocalDataSource {
  DbManager? _dbManager;

  Future<DbManager> get _db async {
    _dbManager ??= await DbManager.init(HiveBoxes.tasks);
    return _dbManager!;
  }

  @override
  Future<int> addNewTask(SuccessfulStatusRequestModel model) async {
    final db = await _db;
    await db.add(model.TaskId, model.toJson());

    return 1;
  }

  @override
  Future<void> editTask(SuccessfulStatusRequestModel model) async {
    final db = await _db;
    await db.editById(model.TaskId, model.toJson());
  }

  @override
  Future<SuccessfulStatusRequestModel?> getTaskById(int id) async {
    final db = await _db;
    final result = await db.getById(id);
    return result != null ? SuccessfulStatusRequestModel.fromJson(result) : null;
  }

  @override
  Future<List<SuccessfulStatusRequestModel>> getTasks() async {
    final db = await _db;
    final result = await db.getAll();
    return result.map((e) => SuccessfulStatusRequestModel.fromJson(e)).toList();
  }

  @override
  Future<void> removeTask(SuccessfulStatusRequestModel model) async {
    final db = await _db;
    await db.removeById(model.TaskId);
  }
}
