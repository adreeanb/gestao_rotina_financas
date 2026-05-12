class Category {
  final int? idCategoria;
  final String nome;
  final String corHexadecimal;

  Category({
    this.idCategoria,
    required this.nome,
    required this.corHexadecimal,
  });

  // Converte o objeto Dart para um formato que o SQLite entende
  Map<String, dynamic> toMap() {
    return {
      'id_categoria': idCategoria,
      'nome': nome,
      'cor_hexadecimal': corHexadecimal,
    };
  }

  // Cria um objeto Dart a partir de dados vindos do SQLite
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      idCategoria: map['id_categoria'],
      nome: map['nome'],
      corHexadecimal: map['cor_hexadecimal'],
    );
  }
}