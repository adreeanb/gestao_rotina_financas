class Project {
  final int? idProjeto;
  final String nome;
  final int metaHorasSemana;

  Project({
    this.idProjeto,
    required this.nome,
    required this.metaHorasSemana,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_projeto': idProjeto,
      'nome': nome,
      'meta_horas_semana': metaHorasSemana,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      idProjeto: map['id_projeto'],
      nome: map['nome'],
      metaHorasSemana: map['meta_horas_semana'],
    );
  }
}