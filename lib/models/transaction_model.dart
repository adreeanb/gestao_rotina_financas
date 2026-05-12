class TransactionModel {
  final int? idTransacao;
  final String titulo;
  final double valor;
  final String tipo; // 'receita' ou 'despesa'
  final String dataTransacao; // Formato YYYY-MM-DD

  TransactionModel({
    this.idTransacao,
    required this.titulo,
    required this.valor,
    required this.tipo,
    required this.dataTransacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_transacao': idTransacao,
      'titulo': titulo,
      'valor': valor,
      'tipo': tipo,
      'data_transacao': dataTransacao,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      idTransacao: map['id_transacao'],
      titulo: map['titulo'],
      valor: map['valor'],
      tipo: map['tipo'],
      dataTransacao: map['data_transacao'],
    );
  }
}