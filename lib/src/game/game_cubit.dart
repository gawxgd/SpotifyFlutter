import 'package:flutter_bloc/flutter_bloc.dart';

class GameState {
  final List<Map<String, String>> users;

  const GameState(this.users);
}

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(const GameState([]));

  void loadUsers() {
    emit(const GameState([
      {'userName': 'User 1', 'userImageUrl': 'https://via.placeholder.com/150'},
      {'userName': 'User 2', 'userImageUrl': 'https://via.placeholder.com/150'},
      {'userName': 'User 3', 'userImageUrl': 'https://via.placeholder.com/150'},
      {'userName': 'User 4', 'userImageUrl': 'https://via.placeholder.com/150'},
    ]));
  }
}
