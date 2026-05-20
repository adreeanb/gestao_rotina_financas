import 'package:flutter/foundation.dart';
import '../models/habit.dart';
import '../database/database_helper.dart';

class HabitViewModel extends ChangeNotifier {
  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  final dbHelper = DatabaseHelper.instance;

  HabitViewModel() {
    loadHabits();
  }

  Future<void> loadHabits() async {
    final db = await dbHelper.database;
    final maps = await db.query('tb_habits');
    _habits = maps.map((map) => Habit.fromMap(map)).toList();
    notifyListeners();
  }
  Future<void> addHabit(String nome) async {
    final db = await dbHelper.database;
    final novoHabito = Habit(nome: nome, ofensivaAtual: 0);
    await db.insert('tb_habits', novoHabito.toMap());
    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    final db = await dbHelper.database;
    await db.delete('tb_habits', where: 'id_habito = ?', whereArgs: [id]);
    await loadHabits();
  }

  Future<void> checkInHabit(Habit habit) async {
    final db = await dbHelper.database;
    final hoje = DateTime.now();
    final hojeStr = "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";


    final logs = await db.query(
      'tb_habit_logs',
      where: 'id_habito = ?',
      whereArgs: [habit.idHabito],
      orderBy: 'data_conclusao DESC',
      limit: 1,
    );

    int novaOfensiva = 1;

    if (logs.isNotEmpty) {
      final ultimaDataStr = logs.first['data_conclusao'] as String;

      // Se já foi feito hoje saímos da função
      if (ultimaDataStr == hojeStr) return;

      final ultimaData = DateTime.parse(ultimaDataStr);
      final diferencaDias = DateTime(hoje.year, hoje.month, hoje.day)
          .difference(DateTime(ultimaData.year, ultimaData.month, ultimaData.day))
          .inDays;

      if (diferencaDias == 1) {
        // se fez ontem A ofensiva cresce.
        novaOfensiva = habit.ofensivaAtual + 1;
      } else {
        // Falhou a ofensiva, recomeça a 1.
        novaOfensiva = 1;
      }
    }

    await db.insert('tb_habit_logs', {
      'id_habito': habit.idHabito,
      'data_conclusao': hojeStr,
    });

    await db.update(
      'tb_habits',
      {'ofensiva_atual': novaOfensiva},
      where: 'id_habito = ?',
      whereArgs: [habit.idHabito],
    );

    await loadHabits();
  }
}