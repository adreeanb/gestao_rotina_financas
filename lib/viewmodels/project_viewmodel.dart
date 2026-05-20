import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../database/database_helper.dart';

class ProjectViewModel extends ChangeNotifier {
  List<Project> _projects = [];
  List<Project> get projects => _projects;

  final dbHelper = DatabaseHelper.instance;

  ProjectViewModel() {
    loadProjects();
  }

  // Le os projetos do banco de dados
  Future<void> loadProjects() async {
    final db = await dbHelper.database;
    final maps = await db.query('tb_projects');
    _projects = maps.map((map) => Project.fromMap(map)).toList();
    notifyListeners();
  }

  // Adiciona um novo projeto
  Future<void> addProject(String nome, int metaHoras) async {
    final db = await dbHelper.database;
    final novoProjeto = Project(nome: nome, metaHorasSemana: metaHoras);
    await db.insert('tb_projects', novoProjeto.toMap());
    await loadProjects();
  }

  // Apaga um projeto
  Future<void> deleteProject(int id) async {
    final db = await dbHelper.database;
    await db.delete('tb_projects', where: 'id_projeto = ?', whereArgs: [id]);
    await loadProjects();
  }
}