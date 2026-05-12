class Routine {
  final int? idRotina;
  final String titulo;
  final int idCategoria;
  final int? idProjeto;
  final int inicioMinutos;
  final int fimMinutos;
  final String diasSemana;
  final String? data; // <--- NOVO CAMPO (opcional para rotinas recorrentes)
  final int ativo;

  Routine({
    this.idRotina,
    required this.titulo,
    required this.idCategoria,
    this.idProjeto,
    required this.inicioMinutos,
    required this.fimMinutos,
    required this.diasSemana,
    this.data, // <--- ADICIONAR AQUI
    this.ativo = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_rotina': idRotina,
      'titulo': titulo,
      'id_categoria': idCategoria,
      'id_projeto': idProjeto,
      'inicio_minutos': inicioMinutos,
      'fim_minutos': fimMinutos,
      'dias_semana': diasSemana,
      'data': data, // <--- ADICIONAR AQUI
      'ativo': ativo,
    };
  }

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      idRotina: map['id_rotina'],
      titulo: map['titulo'],
      idCategoria: map['id_categoria'],
      idProjeto: map['id_projeto'],
      inicioMinutos: map['inicio_minutos'],
      fimMinutos: map['fim_minutos'],
      diasSemana: map['dias_semana'],
      data: map['data'], // <--- ADICIONAR AQUI
      ativo: map['ativo'],
    );
  }
}