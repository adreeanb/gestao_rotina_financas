import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/habit_viewmodel.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  void _mostrarDialogNovoHabito(BuildContext context) {
    final nomeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Hábito'),
          content: TextField(
            controller: nomeController,
            decoration: const InputDecoration(labelText: 'Qual hábito quer criar? (Ex: Beber Água)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty) {
                  context.read<HabitViewModel>().addHabit(nomeController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HabitViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreador de Hábitos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: viewModel.habits.isEmpty
          ? const Center(child: Text('Nenhum hábito rastreado ainda.'))
          : ListView.builder(
        itemCount: viewModel.habits.length,
        itemBuilder: (context, index) {
          final habito = viewModel.habits[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(habito.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Row(
                children: [
                  const Text('🔥 ', style: TextStyle(fontSize: 16)),
                  Text('${habito.ofensivaAtual} dias seguidos', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão de Check-in (Marcar como Feito)
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                    tooltip: 'Marcar como feito hoje',
                    onPressed: () {
                      viewModel.checkInHabit(habito);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hábito registado! Bom trabalho!'), duration: Duration(seconds: 2)),
                      );
                    },
                  ),
                  // Botão de Eliminar
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => viewModel.deleteHabit(habito.idHabito!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogNovoHabito(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}