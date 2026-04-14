import 'package:progress_potion/models/default_task_session_state.dart';
import 'package:progress_potion/models/task_session_state.dart';
import 'package:progress_potion/services/task_service.dart';

class InMemoryTaskService implements TaskService {
  InMemoryTaskService({TaskSessionState? initialState})
    : _state = initialState ?? seedState;

  static TaskSessionState get seedState => createDefaultTaskSessionState();

  TaskSessionState _state;

  @override
  Future<TaskSessionState> loadState() async {
    return _state;
  }

  @override
  Future<void> saveState(TaskSessionState state) async {
    _state = state;
  }
}
