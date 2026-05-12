class Habit {
  final int? idHabito;
  final String nome;
  final int ofensivaAtual;

  Habit({
    this.idHabito,
    required this.nome,
    this.ofensivaAtual = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_habito': idHabito,
      'nome': nome,
      'ofensiva_atual': ofensivaAtual,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      idHabito: map['id_habito'],
      nome: map['nome'],
      ofensivaAtual: map['ofensiva_atual'],
    );
  }
}