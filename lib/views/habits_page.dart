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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Novo Hábito', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: nomeController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ex: Beber 2L de Água',
              border: OutlineInputBorder(),
            ),
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
              child: const Text('Criar Hábito'),
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
        title: const Text('Hábitos Diários', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: viewModel.habits.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 80),
        itemCount: viewModel.habits.length,
        itemBuilder: (context, index) {
          final habito = viewModel.habits[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Círculo de Status/Check-in
                GestureDetector(
                  onTap: () {
                    viewModel.checkInHabit(habito);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🔥 Hábito concluído! Continue assim.')),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade200, width: 2),
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.green, size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                // Texto do Hábito
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habito.nome,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Indicador de Streak (Ofensiva)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '${habito.ofensivaAtual} dias',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Botão de Opções (Delete)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () => viewModel.deleteHabit(habito.idHabito!),
                ),
              ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 80, color: Colors.blue.shade100),
          const SizedBox(height: 16),
          const Text(
            'Crie o seu primeiro hábito!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Text('A constância é a chave do sucesso.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}