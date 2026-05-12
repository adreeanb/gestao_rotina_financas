import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/finance_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancesPage extends StatelessWidget {
  const FinancesPage({super.key});

  // Widget do Gráfico de Pizza
  Widget _buildGrafico(FinanceViewModel viewModel) {
    if (viewModel.transactions.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 45,
          sections: [
            PieChartSectionData(
              value: viewModel.totalReceitas,
              title: 'Ganhos',
              color: Colors.green.shade400,
              radius: 55,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: viewModel.totalDespesas,
              title: 'Gastos',
              color: Colors.red.shade400,
              radius: 55,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogNovaTransacao(BuildContext context) {
    final tituloController = TextEditingController();
    final valorController = TextEditingController();
    String tipoSelecionado = 'despesa';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Nova Transação', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Seletor Moderno (Material 3)
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'despesa', label: Text('Despesa'), icon: Icon(Icons.remove_circle_outline)),
                      ButtonSegment(value: 'receita', label: Text('Receita'), icon: Icon(Icons.add_circle_outline)),
                    ],
                    selected: {tipoSelecionado},
                    onSelectionChanged: (Set<String> novaSelecao) {
                      setState(() => tipoSelecionado = novaSelecao.first);
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valorController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      prefixText: 'R\$ ',
                      border: OutlineInputBorder(),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinanceViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('As Minhas Finanças', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // CARTÃO DE SALDO COM GRADIENTE
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6)
                  )
                ]
            ),
            child: Column(
              children: [
                const Text('Saldo Atual', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${viewModel.saldoTotal.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // GRÁFICO DE PIZZA
          _buildGrafico(viewModel),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Movimentações Recentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          // LISTA DE TRANSAÇÕES
          Expanded(
            child: viewModel.transactions.isEmpty
                ? const Center(child: Text('Nenhuma transação registada.'))
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: viewModel.transactions.length,
              itemBuilder: (context, index) {
                final transacao = viewModel.transactions[index];
                final isReceita = transacao.tipo == 'receita';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isReceita ? Colors.green.shade50 : Colors.red.shade50,
                      child: Icon(
                        isReceita ? Icons.trending_up : Icons.trending_down,
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
                              color: isReceita ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}