import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/routine_viewmodel.dart';

class ManageCategoriesPage extends StatelessWidget {
  const ManageCategoriesPage({super.key});

  // Função que abre um Pop-up para digitar a nova categoria
  void _mostrarDialogNovaCategoria(BuildContext context) {
    final nomeController = TextEditingController();
    // Vamos usar algumas cores pré-definidas para simplificar o MVP
    String corSelecionada = '#4CAF50';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome da Categoria'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: corSelecionada,
                decoration: const InputDecoration(labelText: 'Cor'),
                items: const [
                  DropdownMenuItem(value: '#4CAF50', child: Text('Verde')),
                  DropdownMenuItem(value: '#F44336', child: Text('Vermelho')),
                  DropdownMenuItem(value: '#2196F3', child: Text('Azul')),
                  DropdownMenuItem(value: '#FF9800', child: Text('Laranja')),
                  DropdownMenuItem(value: '#9C27B0', child: Text('Roxo')),
                ],
                onChanged: (valor) {
                  if (valor != null) corSelecionada = valor;
                },
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty) {
                  // Salva no banco de dados usando o Provider
                  Provider.of<RoutineViewModel>(context, listen: false)
                      .addCategory(nomeController.text, corSelecionada);
                  Navigator.pop(context); // Fecha o pop-up
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fica escutando a lista de categorias do ViewModel
    final categorias = context.watch<RoutineViewModel>().categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: categorias.isEmpty
          ? const Center(child: Text('Nenhuma categoria encontrada.'))
          : ListView.builder(
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final cat = categorias[index];

          // Converte a String Hexadecimal ('#4CAF50') para uma Cor (Color) do Flutter
          final corConvertida = Color(int.parse(cat.corHexadecimal.replaceFirst('#', '0xFF')));

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: corConvertida),
              title: Text(cat.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Deleta a categoria
                  context.read<RoutineViewModel>().deleteCategory(cat.idCategoria!);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogNovaCategoria(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}