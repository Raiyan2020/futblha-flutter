
import '../../models/request_model/tasks/successful_status_model/successful_status_request_model.dart';

abstract class TasksLocalDataSource {
  Future<int> addNewTask(SuccessfulStatusRequestModel model);
  Future<void> removeTask(SuccessfulStatusRequestModel model);
  Future<void> editTask(SuccessfulStatusRequestModel model);
  Future<SuccessfulStatusRequestModel?> getTaskById(int id);
  Future<List<SuccessfulStatusRequestModel>> getTasks();
}
