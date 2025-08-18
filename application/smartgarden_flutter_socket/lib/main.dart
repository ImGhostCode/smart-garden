import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/api/api_service.dart';
import 'src/bloc/node_bloc.dart';
import 'src/pages/dashboard_page.dart';
import 'src/pages/commands_page.dart';
import 'src/services/socket_service.dart';

void main() {
  const baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://192.168.1.11:3000');
  final api = ApiService(baseUrl: baseUrl);
  final socket = SocketService(baseUrl: baseUrl);
  runApp(SmartGardenApp(api: api, socket: socket));
}

class SmartGardenApp extends StatelessWidget {
  final ApiService api;
  final SocketService socket;
  const SmartGardenApp({super.key, required this.api, required this.socket});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: api),
        RepositoryProvider.value(value: socket),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NodeBloc(api)..add(LoadNodes())),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SmartGarden',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          home: HomeRouter(),
        ),
      ),
    );
  }
}

class HomeRouter extends StatefulWidget {
  @override
  State<HomeRouter> createState() => _HomeRouterState();
}

class _HomeRouterState extends State<HomeRouter> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final api = RepositoryProvider.of<ApiService>(context);
    final socket = RepositoryProvider.of<SocketService>(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardPage(api: api, socket: socket),
          CommandsPage(api: api, socket: socket),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Commands'),
        ],
      ),
    );
  }
}
