import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// O widget principal do app, que inicia o aplicativo.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Avaliação Flutter',
      home: TelaInicial(), // Define a TelaInicial como a tela inicial do app.
    );
  }
}

// Tela inicial que o usuário verá ao abrir o aplicativo.
class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escola Feliz (tela 1)'), // Título no AppBar.
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 250,
              child: Image.asset('assets/escola_logo.jpg'), // Exibe o logotipo da escola.
            ),
            const SizedBox(height: 20), // espaço entre logo e botão
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaLogin()), // Botão que navega para a tela de login.
                );
              },
              child: const Text('Login'), //texto do botão, aqui só login mesmo
            ),
          ],
        ), //column
      ), //center
    ); //scaffold
  }
}

// Tela de login onde o usuário insere seu nome e senha.
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _nomeController = TextEditingController(); // Controlador para capturar o texto do campo "Nome".
  final TextEditingController _senhaController = TextEditingController(); // Controlador para capturar o texto do campo "Senha".
  String _token = '';

  // Função responsável por realizar a requisição de login.
  Future<void> fazerLogin() async {
    try {
      final response = await http.post(
        Uri.parse('https://demo7209022.mockable.io/testesmalucos'), // URL do mockable para o token
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'nome': _nomeController.text,
          'senha': _senhaController.text,
        }),
      );

      if (response.statusCode == 200) { // checa se o status é 200
        final Map<String, dynamic> data = json.decode(response.body); //decodifica a string JSON para um objeto do tipo Map<String, dynamic>
        setState(() {
          _token = data['token']; // Salva o token.
        });

        // Exibe o token antes de redirecionar.
        ScaffoldMessenger.of(context).showSnackBar(SnackBar( //snackbar = mensagem temporaria
          content: Text('Token recebido: $_token'), //texto do token
        ));

        // Após um pequeno atraso, navega para a tela de notas.
        Future.delayed(const Duration(seconds: 2), () { //muda o atraso
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TelaNotas(token: _token)), // Passa o token para a próxima tela.
          );
        }); //future delayed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar( //snackbar = mensagem temporaria
          content: Text('Erro ao fazer login.'), // Exibe mensagem de erro se o login falhar.
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erro ao fazer login.'), // Exibe mensagem de erro em caso de exceção.
      ));
    }
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela de Login'), //texto topo
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'), // Campo para o nome do usuário.
            ),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha'), // Campo para a senha do usuário.
              obscureText: true, // O conteúdo da senha é oculto.
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fazerLogin, // Chama a função fazerLogin ao pressionar o botão.
              child: const Text('Login'),
            ),
            if (_token.isNotEmpty) Text('Token: $_token'), // Exibe o token se ele existir.
          ],
        ),
      ),
    );
  }
}

// Tela de notas dos alunos.
class TelaNotas extends StatefulWidget {
  final String token;

  const TelaNotas({super.key, required this.token}); // Recebe o token passado pela tela de login.

  @override
  _TelaNotasState createState() => _TelaNotasState();
}

class _TelaNotasState extends State<TelaNotas> {
  List<dynamic> _alunos = []; // Lista que armazena os alunos e suas notas.
  List<dynamic> _alunosFiltrados = []; // Lista que armazena os alunos após aplicação de filtros.

  @override
  void initState() {
    super.initState();
    recuperarNotas(); // Chama a função para buscar as notas assim que a tela é iniciada.
  }

  // Função para recuperar as notas dos alunos via API.
  Future<void> recuperarNotas() async {
    try {
      final response = await http.get(
        Uri.parse('https://run.mocky.io/v3/9edfdbce-15ec-4f34-93ef-c7b49e2ecb33'), // URL da API (preencher corretamente).
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Resposta da API: ${response.body}');
        }

        setState(() {
          _alunos = json.decode(response.body); // Armazena os alunos na lista.
          _alunosFiltrados = _alunos; // Inicialmente, a lista filtrada contém todos os alunos.
        });
      } else {
        if (kDebugMode) {
          print('Erro ao recuperar as notas: Status ${response.statusCode}');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao recuperar as notas dos alunos. Código: ${response.statusCode}'),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exceção ao recuperar notas: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao recuperar as notas dos alunos: $e'),
      ));
    }
  }

  // Função para filtrar alunos com nota menor que 60.
  void filtrarAlunosNotaMenor60() {
    setState(() {
      _alunosFiltrados = _alunos.where((aluno) => aluno['nota'] < 60).toList();
    });
  }

  // Função para filtrar alunos com nota entre 60 e 99.
  void filtrarAlunosNota60a99() {
    setState(() {
      _alunosFiltrados = _alunos
          .where((aluno) => aluno['nota'] >= 60 && aluno['nota'] < 100)
          .toList();
    });
  }

  // Função para filtrar alunos com nota igual a 100.
  void filtrarAlunosNota100() {
    setState(() {
      _alunosFiltrados =
          _alunos.where((aluno) => aluno['nota'] == 100).toList();
    });
  }

  // Função para remover todos os filtros e mostrar todos os alunos.
  void removerFiltros() {
    setState(() {
      _alunosFiltrados = _alunos; // Restaura a lista completa de alunos.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas dos Alunos'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: filtrarAlunosNotaMenor60, // Filtra alunos com nota < 60.
                child: const Text('Nota < 60'),
              ),
              ElevatedButton(
                onPressed: filtrarAlunosNota60a99, // Filtra alunos com nota >= 60 e < 100.
                child: const Text('Nota >= 60'),
              ),
              ElevatedButton(
                onPressed: filtrarAlunosNota100, // Filtra alunos com nota = 100.
                child: const Text('Nota = 100'),
              ),
              ElevatedButton(
                onPressed: removerFiltros, // Remove todos os filtros.
                child: const Text('Mostrar Todos'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _alunosFiltrados.length, // Quantidade de alunos filtrados.
              itemBuilder: (context, index) {
                final aluno = _alunosFiltrados[index];
                final backgroundColor = aluno['nota'] == 100
                    ? Colors.green
                    : aluno['nota'] >= 60
                        ? Colors.blue // ? verifica se é maior que 60
                        : Colors.yellow; // : é um else

                return Card(
                  color: backgroundColor, // Cor de fundo baseada na nota.
                  child: ListTile(
                    title: Text(aluno['nome']),
                    subtitle: Text('Nota: ${aluno['nota']}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
