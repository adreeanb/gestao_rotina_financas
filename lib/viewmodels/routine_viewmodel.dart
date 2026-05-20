import 'package:flutter/foundation.dart' hide Category;
import '../models/routine.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

class RoutineViewModel extends ChangeNotifier {

  List<Routine> _routines = [];


  List<Routine> get routines => _routines;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  final dbHelper = DatabaseHelper.instance;

  // Construtor: Assim que este ViewModel for criado, carrega as rotinas do SQLite
  RoutineViewModel() {
    loadRoutines();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tb_categories');
    _categories = maps.map((map) => Category.fromMap(map)).toList();
    notifyListeners();
  } // <-- CORREÇÃO: Faltava fechar esta chave!

  Future<void> loadRoutines() async {
    final db = await dbHelper.database;
    // Faz a query à tabela
    final List<Map<String, dynamic>> maps = await db.query('tb_routines');

    // Converte a lista de Mapas para uma lista de objetos Routine
    _routines = maps.map((map) => Routine.fromMap(map)).toList();

    // AVISA O ECRÃ PARA SE REDESENHAR! (Isto é a magia do Provider)
    notifyListeners();
  }

  bool hasTimeConflict(int newStart, int newEnd, DateTime data) {
    final dataString = "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";

    for (var routine in _routines) {

      if (dataString == routine.data &&
          newStart < routine.fimMinutos &&
          newEnd > routine.inicioMinutos) {
        return true;
      }
    }
    return false;
  }


  Future<void> addRoutine(Routine routine) async {
    final db = await dbHelper.database;
    await db.insert('tb_routines', routine.toMap());

    await loadRoutines();
  }


  Future<void> deleteRoutine(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'tb_routines',
      where: 'id_rotina = ?',
      whereArgs: [id],
    );
    await loadRoutines();
  }

  Future<void> addTestRoutine() async {
    final db = await dbHelper.database;

    await db.rawInsert('''
      INSERT OR IGNORE INTO tb_categories (id_categoria, nome, cor_hexadecimal) 
      VALUES (1, 'Trabalho', '#4CAF50')
    ''');

    final rotinaTeste = Routine(
      titulo: 'Reunião de Alinhamento',
      idCategoria: 1,
      inicioMinutos: 540, // Equivale às 09:00 (9 horas * 60 min)
      fimMinutos: 600,    // Equivale às 10:00 (10 horas * 60 min)
      diasSemana: '1,2,3,4,5',
    );

    await addRoutine(rotinaTeste);
  }

  Future<void> addCategory(String nome, String corHexadecimal) async {
    final db = await dbHelper.database;

    final novaCategoria = Category(
        nome: nome,
        corHexadecimal: corHexadecimal
    );

    await db.insert('tb_categories', novaCategoria.toMap());

    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'tb_categories',
      where: 'id_categoria = ?',
      whereArgs: [id],
    );
    await loadCategories();

    await loadRoutines();
  }
}