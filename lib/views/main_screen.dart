import 'package:flutter/material.dart';

// Importar todos os nossos ecrãs
import 'home_page.dart';
import 'habits_page.dart';
import 'projects_page.dart';
import 'finances_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Variável que guarda qual o separador atualmente selecionado (começa no 0: Agenda)
  int _indiceAtual = 0;

  // Lista com os ecrãs que a aplicação tem
  final List<Widget> _ecras = [
    const HomePage(),
    const HabitsPage(),
    const ProjectsPage(),
    const FinancesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O corpo do Scaffold será o ecrã correspondente ao índice atual
      body: _ecras[_indiceAtual],

      // A nossa Barra de Navegação Inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceAtual,
        onDestinationSelected: (int index) {
          // Quando o utilizador clica num ícone, atualizamos o estado
          setState(() {
            _indiceAtual = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Hábitos',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            label: 'Projetos',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Finanças',
          ),
        ],
      ),
    );
  }
}