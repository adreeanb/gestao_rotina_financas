import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importações dos nossos ficheiros
import 'package:gestao_rotina_financas/viewmodels/routine_viewmodel.dart';
import 'package:gestao_rotina_financas/views/home_page.dart';
import 'package:gestao_rotina_financas/views/main_screen.dart';
import 'package:gestao_rotina_financas/viewmodels/habit_viewmodel.dart';
import 'package:gestao_rotina_financas/viewmodels/project_viewmodel.dart';
import 'package:gestao_rotina_financas/viewmodels/finance_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // Registamos o RoutineViewModel aqui.
        // A partir de agora, qualquer ecrã da app pode aceder às rotinas!
        ChangeNotifierProvider(create: (_) => RoutineViewModel()),
        ChangeNotifierProvider(create: (_) => HabitViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => FinanceViewModel()),
      ],
      child: const MeuAppRotina(),
    ),
  );
}

class MeuAppRotina extends StatelessWidget {
  const MeuAppRotina({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Rotina e Finanças',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // MudAmos a página inicial para a nossa HomePage
      home: const MainScreen(),
    );
  }
}