import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/routine.dart';
import '../viewmodels/routine_viewmodel.dart';

class AddRoutinePage extends StatefulWidget {
  const AddRoutinePage({super.key});

  @override
  State<AddRoutinePage> createState() => _AddRoutinePageState();
}

class _AddRoutinePageState extends State<AddRoutinePage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();

  int? _categoriaSelecionada; // Guarda o ID da categoria escolhida

  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaInicio = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _horaFim = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _escolherData(BuildContext context) async {
    final DateTime? colhida = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (colhida != null) {
      setState(() {
        _dataSelecionada = colhida;
      });
    }
  }

  Future<void> _escolherHora(BuildContext context, bool isInicio) async {
    final TimeOfDay? horaEscolhida = await showTimePicker(
      context: context,
      initialTime: isInicio ? _horaInicio : _horaFim,
    );

    if (horaEscolhida != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = horaEscolhida;
        } else {
          _horaFim = horaEscolhida;
        }
      });
    }
  }

  void _guardarRotina() {
    if (_formKey.currentState!.validate()) {
      final inicioMinutos = _horaInicio.hour * 60 + _horaInicio.minute;
      final fimMinutos = _horaFim.hour * 60 + _horaFim.minute;

      if (fimMinutos <= inicioMinutos) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O horário de fim deve ser depois do início!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final viewModel = Provider.of<RoutineViewModel>(context, listen: false);

      if (viewModel.hasTimeConflict(inicioMinutos, fimMinutos)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conflito de horário! Já tem uma rotina neste período.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final dataFormatada = "${_dataSelecionada.year}-${_dataSelecionada.month.toString().padLeft(2, '0')}-${_dataSelecionada.day.toString().padLeft(2, '0')}";

      final novaRotina = Routine(
        titulo: _tituloController.text,
        idCategoria: _categoriaSelecionada!, // Usa a categoria do Dropdown!
        inicioMinutos: inicioMinutos,
        fimMinutos: fimMinutos,
        diasSemana: '1,2,3,4,5',
        data: dataFormatada,
      );

      viewModel.addRoutine(novaRotina);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Carrega a lista de categorias que o ViewModel buscou do SQLite
    final categorias = context.watch<RoutineViewModel>().categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Rotina'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Trocado de Column para ListView
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da Rotina',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- NOVO: Campo de Categoria ---
              DropdownButtonFormField<int>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: categorias.map((categoria) {
                  return DropdownMenuItem<int>(
                    value: categoria.idCategoria,
                    child: Text(categoria.nome),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _categoriaSelecionada = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma categoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --------------------------------

              ListTile(
                title: const Text("Data da Rotina"),
                subtitle: Text("${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _escolherData(context),
              ),
              const Divider(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Início'),
                      ElevatedButton(
                        onPressed: () => _escolherHora(context, true),
                        child: Text(_horaInicio.format(context)),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Fim'),
                      ElevatedButton(
                        onPressed: () => _escolherHora(context, false),
                        child: Text(_horaFim.format(context)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: _guardarRotina,
                child: const Text('Guardar Rotina', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}