import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/finance_viewmodel.dart';

class FinancesPage extends StatelessWidget {
  const FinancesPage({super.key});

  void _mostrarDialogNovaTransacao(BuildContext context) {
    final tituloController = TextEditingController();
    final valorController = TextEditingController();
    String tipoSelecionado = 'despesa'; // Começa como despesa por defeito

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // StatefulBuilder permite mudar o estado (Radio buttons) dentro do pop-up
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Nova Transação'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botões de escolha: Receita ou Despesa
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Despesa', style: TextStyle(color: Colors.red, fontSize: 14)),
                            value: 'despesa',
                            groupValue: tipoSelecionado,
                            onChanged: (valor) => setState(() => tipoSelecionado = valor!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Receita', style: TextStyle(color: Colors.green, fontSize: 14)),
                            value: 'receita',
                            groupValue: tipoSelecionado,
                            onChanged: (valor) => setState(() => tipoSelecionado = valor!),
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(labelText: 'Descrição (Ex: Almoço)'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: valorController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Valor',
                        prefixText: 'R\$ ', // Pode mudar para € se preferir
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
                      if (tituloController.text.isNotEmpty && valorController.text.isNotEmpty) {
                        // Troca a vírgula por ponto (caso o utilizador digite 10,50)
                        final valorFormatado = valorController.text.replaceAll(',', '.');
                        final valorDouble = double.tryParse(valorFormatado) ?? 0.0;

                        if (valorDouble > 0) {
                          context.read<FinanceViewModel>().addTransaction(
                              tituloController.text,
                              valorDouble,
                              tipoSelecionado
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('As Minhas Finanças'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // CARTÃO DE SALDO
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
                color: viewModel.saldoTotal >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))
                ]
            ),
            child: Column(
              children: [
                const Text('Saldo Atual', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${viewModel.saldoTotal.toStringAsFixed(2)}', // Formata para 2 casas decimais
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Histórico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          // LISTA DE TRANSAÇÕES
          Expanded(
            child: viewModel.transactions.isEmpty
                ? const Center(child: Text('Nenhuma transação registada.'))
                : ListView.builder(
              itemCount: viewModel.transactions.length,
              itemBuilder: (context, index) {
                final transacao = viewModel.transactions[index];
                final isReceita = transacao.tipo == 'receita';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isReceita ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(
                        isReceita ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isReceita ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(transacao.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(transacao.dataTransacao),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${isReceita ? '+' : '-'} R\$ ${transacao.valor.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: isReceita ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
                          onPressed: () => viewModel.deleteTransaction(transacao.idTransacao!),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogNovaTransacao(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}