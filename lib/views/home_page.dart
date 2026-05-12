import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/routine_viewmodel.dart';
import 'add_routine_page.dart';
import 'manage_categories_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o "watch" do Provider. Sempre que o notifyListeners()
    // for chamado no ViewModel, este ecrã vai redesenhar-se sozinho!
    final viewModel = context.watch<RoutineViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('A Minha Agenda'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
        IconButton(
        icon: const Icon(Icons.category),
        tooltip: 'Categorias',
        onPressed: () {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ManageCategoriesPage()),
        );
        },
        ),
        ],
      // Se a lista estiver vazia, mostra uma mensagem. Senão, mostra a lista.
      ),
      body: viewModel.routines.isEmpty
          ? const Center(
        child: Text(
          'Nenhuma rotina agendada.\nToque no botão + para testar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: viewModel.routines.length,
        itemBuilder: (context, index) {
          final rotina = viewModel.routines[index];

          // Converte os minutos de volta para horas e minutos legíveis (Ex: 540 -> 09:00)
          final horaInicio = '${(rotina.inicioMinutos ~/ 60).toString().padLeft(2, '0')}:${(rotina.inicioMinutos % 60).toString().padLeft(2, '0')}';
          final horaFim = '${(rotina.fimMinutos ~/ 60).toString().padLeft(2, '0')}:${(rotina.fimMinutos % 60).toString().padLeft(2, '0')}';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.access_time)),
              title: Text(rotina.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Das $horaInicio às $horaFim'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Apaga a rotina da base de dados
                  viewModel.deleteRoutine(rotina.idRotina!);
                },
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRoutinePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}