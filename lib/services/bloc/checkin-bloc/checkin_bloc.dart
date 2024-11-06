import 'package:checkin/store/storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class CheckIn {
  final String name;
  final DateTime time;
  final String username;
  final String gambled;

  CheckIn({required this.name, required this.time, required this.username,required this.gambled});

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'time': time.toIso8601String(),
    'gambled':gambled
  };

  factory CheckIn.fromJson(Map<String, dynamic> json) => CheckIn(
    name: json['name'],
    username: json['username'] ?? 'Guest',
    gambled: json['gambled'] ?? 'No',
    time: DateTime.parse(json['time']),
  );
}

abstract class CheckInEvent {}

class AddCheckIn extends CheckInEvent {
  final String name;
  final String username;
  final String gambled;

  AddCheckIn(this.name, this.username,this.gambled);
}

class LoadCheckIns extends CheckInEvent {}

class DeleteAllCheckIns extends CheckInEvent {}

abstract class CheckInState {}

class CheckInInitial extends CheckInState {}

class CheckInLoaded extends CheckInState {
  final List<CheckIn> checkIns;
  CheckInLoaded(this.checkIns);
}
class CheckInBloc extends Bloc<CheckInEvent, CheckInState> {
  final StorageManager _storageManager;
  static const String CHECK_INS_KEY = 'check_ins';

  CheckInBloc(StorageManager storageManager)
      : _storageManager = storageManager,
        super(CheckInInitial()) {
    on<LoadCheckIns>(_onLoadCheckIns);
    on<AddCheckIn>(_onAddCheckIn);
    on<DeleteAllCheckIns>(_onDeleteAllCheckIns);
  }

  void _onLoadCheckIns(LoadCheckIns event, Emitter<CheckInState> emit) {
    final data = _storageManager.getData<List<dynamic>>(CHECK_INS_KEY);
    if (data != null) {
      final checkIns = data.map((json) => CheckIn.fromJson(Map<String, dynamic>.from(json))).toList();
      emit(CheckInLoaded(checkIns));
    } else {
      emit(CheckInLoaded([]));
    }
  }

  void _onAddCheckIn(AddCheckIn event, Emitter<CheckInState> emit) async {
    final currentState = state;
    if (currentState is CheckInLoaded) {
      final newCheckIn = CheckIn(name: event.name,username: event.username,gambled:  event.gambled,  time: DateTime.now());
      final updatedCheckIns = [...currentState.checkIns, newCheckIn];

      final checkInsJson = updatedCheckIns.map((checkIn) => checkIn.toJson()).toList();
      await _storageManager.saveData(CHECK_INS_KEY, checkInsJson);
      emit(CheckInLoaded(updatedCheckIns));
    }
  }

  void _onDeleteAllCheckIns(DeleteAllCheckIns event, Emitter<CheckInState> emit) async {
    await _storageManager.deleteData(CHECK_INS_KEY);
    emit(CheckInLoaded([]));
  }
}