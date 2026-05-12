import 'package:flutter/foundation.dart' hide Category;
import '../models/routine.dart';
import '../database/database_helper.dart';
import '../models/category.dart';

class RoutineViewModel extends ChangeNotifier {
  // Lista privada que guarda as rotinas carregadas na memória
  List<Routine> _routines = [];

  // Getter para a interface gráfica aceder à lista
  List<Routine> get routines => _routines;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  // Instância da nossa base de dados
  final dbHelper = DatabaseHelper.instance;

  // Construtor: Assim que este ViewModel for criado, carrega as rotinas do SQLite
  RoutineViewModel() {
    loadRoutines();
    loadCategories(); // <-- CORREÇÃO: Adicionado para carregar as categorias ao iniciar!
  }

  // Função para carregar as categorias
  Future<void> loadCategories() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tb_categories');
    _categories = maps.map((map) => Category.fromMap(map)).toList();
    notifyListeners();
  } // <-- CORREÇÃO: Faltava fechar esta chave!


  // Função para ler as rotinas da base de dados (CRUD - Read)
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
    // 1. Convertemos o DateTime recebido para o mesmo formato String do banco
    final dataString = "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";

    for (var routine in _routines) {
      // 2. Usamos 'dataString' e comparamos com 'routine.data'
      // O conflito só existe se for NO MESMO DIA e OS HORÁRIOS SE SOBREPUJEREM
      if (dataString == routine.data &&
          newStart < routine.fimMinutos &&
          newEnd > routine.inicioMinutos) {
        return true; // Existe um choque de horários!
      }
    }
    return false; // Caminho livre!
  }

  // Função para adicionar uma nova rotina (CRUD - Create)
  Future<void> addRoutine(Routine routine) async {
    final db = await dbHelper.database;
    await db.insert('tb_routines', routine.toMap());

    // Recarrega a lista para mostrar a nova rotina
    await loadRoutines();
  }

  // Função para apagar uma rotina (CRUD - Delete)
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

    // 1. Cria uma categoria de teste (ID 1) ignorando se já existir
    await db.rawInsert('''
      INSERT OR IGNORE INTO tb_categories (id_categoria, nome, cor_hexadecimal) 
      VALUES (1, 'Trabalho', '#4CAF50')
    ''');

    // 2. Cria a nossa rotina de teste associada à categoria 1
    final rotinaTeste = Routine(
      titulo: 'Reunião de Alinhamento',
      idCategoria: 1,
      inicioMinutos: 540, // Equivale às 09:00 (9 horas * 60 min)
      fimMinutos: 600,    // Equivale às 10:00 (10 horas * 60 min)
      diasSemana: '1,2,3,4,5',
    );

    await addRoutine(rotinaTeste);
  }
  // Função para adicionar uma nova Categoria
  Future<void> addCategory(String nome, String corHexadecimal) async {
    final db = await dbHelper.database;

    // Cria o objeto da nova categoria
    final novaCategoria = Category(
        nome: nome,
        corHexadecimal: corHexadecimal
    );

    // Insere no banco de dados
    await db.insert('tb_categories', novaCategoria.toMap());

    // Recarrega a lista para a tela atualizar automaticamente
    await loadCategories();
  }

  // Função para deletar uma Categoria
  Future<void> deleteCategory(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'tb_categories',
      where: 'id_categoria = ?',
      whereArgs: [id],
    );
    await loadCategories();
    // É importante recarregar as rotinas também, pois se a categoria sumir,
    // as rotinas ligadas a ela também somem (ON DELETE CASCADE)
    await loadRoutines();
  }
}