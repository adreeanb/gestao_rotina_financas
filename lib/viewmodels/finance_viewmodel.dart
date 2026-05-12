import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../database/database_helper.dart';

class FinanceViewModel extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  // Variável para guardar o saldo atualizado
  double _saldoTotal = 0.0;
  double get saldoTotal => _saldoTotal;

  final dbHelper = DatabaseHelper.instance;

  FinanceViewModel() {
    loadTransactions();
  }

  // Carrega as transações do SQLite
  Future<void> loadTransactions() async {
    final db = await dbHelper.database;
    // Trazemos as transações ordenadas pela data mais recente
    final maps = await db.query('tb_transactions', orderBy: 'id_transacao DESC');

    _transactions = maps.map((map) => TransactionModel.fromMap(map)).toList();

    _calcularSaldo(); // Recalcula o dinheiro na conta
    notifyListeners();
  }

  // Função interna para somar receitas e subtrair despesas
  void _calcularSaldo() {
    _saldoTotal = 0.0;
    for (var t in _transactions) {
      if (t.tipo == 'receita') {
        _saldoTotal += t.valor;
      } else {
        _saldoTotal -= t.valor;
      }
    }
  }

  // Adiciona uma nova transação
  Future<void> addTransaction(String titulo, double valor, String tipo) async {
    final db = await dbHelper.database;
    final hoje = DateTime.now();
    // Guarda a data no formato YYYY-MM-DD
    final dataFormatada = "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";

    final novaTransacao = TransactionModel(
      titulo: titulo,
      valor: valor,
      tipo: tipo, // 'receita' ou 'despesa'
      dataTransacao: dataFormatada,
    );

    await db.insert('tb_transactions', novaTransacao.toMap());
    await loadTransactions();
  }

  // Apaga uma transação
  Future<void> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    await db.delete('tb_transactions', where: 'id_transacao = ?', whereArgs: [id]);
    await loadTransactions();
  }
}