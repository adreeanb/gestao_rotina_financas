import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/project_viewmodel.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  void _mostrarDialogNovoProjeto(BuildContext context) {
    final nomeController = TextEditingController();
    final horasController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Projeto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Projeto (Ex: TCC)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: horasController,
                keyboardType: TextInputType.number, // Abre o teclado numérico
                decoration: const InputDecoration(
                  labelText: 'Meta de horas por semana',
                  suffixText: 'horas',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty && horasController.text.isNotEmpty) {
                  final horas = int.tryParse(horasController.text) ?? 0;
                  if (horas > 0) {
                    context.read<ProjectViewModel>().addProject(nomeController.text, horas);
                    Navigator.pop(context);
                  }
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
    final viewModel = context.watch<ProjectViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Projetos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: viewModel.projects.isEmpty
          ? const Center(child: Text('Nenhum projeto em andamento.'))
          : ListView.builder(
        itemCount: viewModel.projects.length,
        itemBuilder: (context, index) {
          final projeto = viewModel.projects[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.folder, color: Colors.white),
              ),
              title: Text(projeto.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Meta: ${projeto.metaHorasSemana}h / semana'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => viewModel.deleteProject(projeto.idProjeto!),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogNovoProjeto(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}