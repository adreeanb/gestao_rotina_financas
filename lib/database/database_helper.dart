import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Padrão Singleton para garantir apenas uma instância da base de dados
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rotina_financas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // Ativar o suporte a chaves estrangeiras (Foreign Keys) no SQLite
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // Criação das tabelas
  Future _createDB(Database db, int version) async {

    // 1. Tabela de Categorias
    await db.execute('''
      CREATE TABLE tb_categories (
        id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        cor_hexadecimal TEXT NOT NULL
      )
    ''');

    // 2. Tabela de Projetos (Deve vir antes das rotinas devido à chave estrangeira)
    await db.execute('''
      CREATE TABLE tb_projects (
        id_projeto INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        meta_horas_semana INTEGER NOT NULL
      )
    ''');

    // 3. Tabela de Rotinas
    // O SQLite não tem tipo booleano, usamos INTEGER (0 para falso, 1 para verdadeiro)
    await db.execute('''
      CREATE TABLE tb_routines (
        id_rotina INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        id_categoria INTEGER NOT NULL,
        id_projeto INTEGER,
        inicio_minutos INTEGER NOT NULL,
        fim_minutos INTEGER NOT NULL,
        dias_semana TEXT NOT NULL,
        data TEXT, -- <--- ADICIONAR ESTA LINHA
        ativo INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (id_categoria) REFERENCES tb_categories (id_categoria) ON DELETE CASCADE,
        FOREIGN KEY (id_projeto) REFERENCES tb_projects (id_projeto) ON DELETE SET NULL
      )
    ''');

    // 4. Tabela de Hábitos
    await db.execute('''
      CREATE TABLE tb_habits (
        id_habito INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        ofensiva_atual INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 5. Tabela de Registos de Hábitos (Log diário)
    await db.execute('''
      CREATE TABLE tb_habit_logs (
        id_log INTEGER PRIMARY KEY AUTOINCREMENT,
        id_habito INTEGER NOT NULL,
        data_conclusao TEXT NOT NULL,
        FOREIGN KEY (id_habito) REFERENCES tb_habits (id_habito) ON DELETE CASCADE
      )
    ''');

    // 6. Tabela de Metas Financeiras
    await db.execute('''
      CREATE TABLE tb_financial_goals (
        id_meta INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        valor_objetivo REAL NOT NULL,
        valor_atual REAL NOT NULL DEFAULT 0.0
      )
    ''');

    // 7. Tabela de Transações (Entradas e Saídas)
    await db.execute('''
      CREATE TABLE tb_transactions (
        id_transacao INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        valor REAL NOT NULL,
        tipo TEXT NOT NULL, -- Será 'receita' ou 'despesa'
        data_transacao TEXT NOT NULL
      )
    ''');
  }

  // Método para fechar a base de dados
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}