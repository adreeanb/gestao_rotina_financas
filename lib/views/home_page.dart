import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart'; // Importação do calendário
import '../viewmodels/routine_viewmodel.dart';
import 'add_routine_page.dart';
import 'manage_categories_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks; // Começa com visão de 2 semanas para poupar espaço
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RoutineViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    // 1. Filtrar as rotinas para o dia selecionado
    final dataSelecionadaStr = "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";

    final rotinasFiltradas = viewModel.routines.where((r) => r.data == dataSelecionadaStr).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Agenda', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.category_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          // SEÇÃO DO CALENDÁRIO
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.inversePrimary.withOpacity(0.3),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              // Estilização das cores baseada no seu tema Ciano/Verde
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.4), shape: BoxShape.circle),
                markerDecoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(formatButtonVisible: true, titleCentered: true),
            ),
          ),

          // LISTA DE ROTINAS FILTRADAS
          Expanded(
            child: rotinasFiltradas.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: rotinasFiltradas.length,
              itemBuilder: (context, index) {
                final rotina = rotinasFiltradas[index];
                final categoria = viewModel.categories.firstWhere((c) => c.idCategoria == rotina.idCategoria);
                final corCategoria = _parseColor(categoria.corHexadecimal);

                final horaInicio = '${(rotina.inicioMinutos ~/ 60).toString().padLeft(2, '0')}:${(rotina.inicioMinutos % 60).toString().padLeft(2, '0')}';
                final horaFim = '${(rotina.fimMinutos ~/ 60).toString().padLeft(2, '0')}:${(rotina.fimMinutos % 60).toString().padLeft(2, '0')}';

                return _buildRoutineCard(rotina, categoria.nome, corCategoria, horaInicio, horaFim, viewModel);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRoutinePage())),
        child: const Icon(Icons.add)
      ),
    );
  }

  Widget _buildRoutineCard(rotina, catNome, cor, inicio, fim, viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 6, decoration: BoxDecoration(color: cor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(catNome.toUpperCase(), style: TextStyle(color: cor, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(rotina.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('$inicio - $fim', style: const TextStyle(color: Colors.grey)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => viewModel.deleteRoutine(rotina.idRotina!)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_available, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('Nenhuma rotina para este dia.', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}