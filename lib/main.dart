import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ControleExtrasApp());
}

// =========================================================
// APLICAÇÃO
// =========================================================

class ControleExtrasApp extends StatelessWidget {
  const ControleExtrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Extras',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
        ),
      ),
      home: const RoteadorInicial(),
    );
  }
}

// =========================================================
// ROTEADOR INICIAL
// =========================================================
// Se existir ?id=1 na URL, abre diretamente aquele extra.
// Caso contrário, abre a tela inicial normal.
// =========================================================

class RoteadorInicial extends StatelessWidget {
  const RoteadorInicial({super.key});

  @override
  Widget build(BuildContext context) {
    final idExtra = Uri.base.queryParameters['id'];

    if (idExtra != null && idExtra.trim().isNotEmpty) {
      return TelaExtraPublico(
        url: urlGoogle,
        idExtra: idExtra,
      );
    }

    return const TelaInicial();
  }
}

// =========================================================
// URL DO GOOGLE APPS SCRIPT
// =========================================================

const String urlGoogle =
    'https://script.google.com/macros/s/AKfycbyJnz-LCmEVCw1fp10WjwfhrYm43huhF1Sm8z3cDmnUETjTL0sYITMIuqIQ-V0nT9LkBQ/exec';

// =========================================================
// TELA INICIAL
// =========================================================

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  String status = 'Testando conexão...';

  @override
  void initState() {
    super.initState();
    testarConexao();
  }

  // =======================================================
  // TESTAR CONEXÃO
  // =======================================================

  Future<void> testarConexao() async {
    try {
      final resposta = await http.get(
        Uri.parse(urlGoogle),
      );

      if (!mounted) return;

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        if (dados is Map && dados.containsKey('extras')) {
          setState(() {
            status = 'CONECTADO AO GOOGLE SHEETS';
          });
        } else {
          setState(() {
            status = 'GOOGLE SHEETS RESPONDEU';
          });
        }
      } else {
        setState(() {
          status = 'ERRO HTTP: ${resposta.statusCode}';
        });
      }
    } catch (erro) {
      if (!mounted) return;

      setState(() {
        status = 'ERRO DE CONEXÃO';
      });

      debugPrint('ERRO DE CONEXÃO: $erro');
    }
  }

  // =======================================================
  // TELA
  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield,
                color: Colors.white,
                size: 100,
              ),

              const SizedBox(height: 30),

              const Text(
                'CONTROLE DE EXTRAS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 25),

              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // =================================================
              // INSCRIÇÕES
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaInscricoes(
                          url: urlGoogle,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'INSCRIÇÕES',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // PLANTÕES
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'PLANTÕES',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // RELATÓRIOS
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'RELATÓRIOS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================
// TELA DE INSCRIÇÕES
// =========================================================

class TelaInscricoes extends StatefulWidget {
  final String url;

  const TelaInscricoes({
    super.key,
    required this.url,
  });

  @override
  State<TelaInscricoes> createState() => _TelaInscricoesState();
}

class _TelaInscricoesState extends State<TelaInscricoes> {
  bool carregando = true;

  String? erro;

  List<Map<String, dynamic>> extras = [];

  @override
  void initState() {
    super.initState();
    carregarExtras();
  }

  // =======================================================
  // BUSCAR EXTRAS
  // =======================================================

  Future<void> carregarExtras() async {
    try {
      setState(() {
        carregando = true;
        erro = null;
      });

      final resposta = await http.get(
        Uri.parse(widget.url),
      );

      if (resposta.statusCode != 200) {
        throw Exception(
          'Erro HTTP: ${resposta.statusCode}',
        );
      }

      final dados = jsonDecode(resposta.body);

      if (dados is! Map) {
        throw Exception(
          'Resposta inválida do Google Sheets.',
        );
      }

      final List<dynamic> linhas =
          dados['extras'] ?? [];

      if (linhas.isEmpty) {
        if (!mounted) return;

        setState(() {
          extras = [];
          carregando = false;
        });

        return;
      }

      final List<String> cabecalho =
          List<String>.from(linhas[0]);

      final List<Map<String, dynamic>> lista = [];

      for (int i = 1; i < linhas.length; i++) {
        final List<dynamic> linha =
            List<dynamic>.from(linhas[i]);

        final Map<String, dynamic> item = {};

        for (
          int coluna = 0;
          coluna < cabecalho.length &&
              coluna < linha.length;
          coluna++
        ) {
          item[cabecalho[coluna]] = linha[coluna];
        }

        final aberto = item['ABERTO']
            ?.toString()
            .toUpperCase()
            .trim();

        if (aberto == 'SIM') {
          lista.add(item);
        }
      }

      if (!mounted) return;

      setState(() {
        extras = lista;
        carregando = false;
        erro = null;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR EXTRAS: $e',
      );

      if (!mounted) return;

      setState(() {
        carregando = false;
        erro =
            'Não foi possível carregar os extras.';
      });
    }
  }

  // =======================================================
  // TELA
  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'INSCRIÇÕES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _construirConteudo(),
    );
  }

  // =======================================================
  // CONTEÚDO
  // =======================================================

  Widget _construirConteudo() {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 50,
            ),

            const SizedBox(height: 15),

            Text(
              erro!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: carregarExtras,
              child: const Text(
                'TENTAR NOVAMENTE',
              ),
            ),
          ],
        ),
      );
    }

    if (extras.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum extra aberto no momento.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: carregarExtras,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: extras.length,
        itemBuilder: (context, index) {
          final extra = extras[index];

          return _cartaoExtra(extra);
        },
      ),
    );
  }

  // =======================================================
  // CARTÃO DO EXTRA
  // =======================================================

  Widget _cartaoExtra(
    Map<String, dynamic> extra,
  ) {
    final evento =
        extra['EVENTO']?.toString() ?? '';

    final data =
        extra['DATA']?.toString() ?? '';

    final inicio =
        extra['INICIO']?.toString() ?? '';

    final fim =
        extra['FIM']?.toString() ?? '';

    final local =
        extra['LOCAL']?.toString() ?? '';

    final vagas =
        extra['VAGAS']?.toString() ?? '';

    final idExtra =
        extra['ID']?.toString() ?? '';

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // EVENTO
            Text(
              evento,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 15),

            // DATA
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Colors.black,
                ),
                const SizedBox(width: 10),
                Text(
                  data,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // HORÁRIO
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.black,
                ),
                const SizedBox(width: 10),
                Text(
                  '$inicio às $fim',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // LOCAL
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.black,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    local,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // VAGAS
            Row(
              children: [
                const Icon(
                  Icons.people,
                  color: Colors.black,
                ),
                const SizedBox(width: 10),
                Text(
                  '$vagas vagas',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // INSCREVER-SE
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TelaFormularioInscricao(
                        url: widget.url,
                        idExtra: idExtra,
                        evento: evento,
                        data: data,
                        inicio: inicio,
                        fim: fim,
                        local: local,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'INSCREVER-SE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // VER INSCRITOS
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TelaInscritos(
                        url: widget.url,
                        idExtra: idExtra,
                        evento: evento,
                        data: data,
                        inicio: inicio,
                        fim: fim,
                        local: local,
                        vagas: vagas,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.people_alt,
                ),
                label: const Text(
                  'VER INSCRITOS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // COPIAR LINK
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  _copiarLinkExtra(idExtra);
                },
                icon: const Icon(
                  Icons.link,
                ),
                label: const Text(
                  'COPIAR LINK DO EXTRA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================
  // GERAR LINK DO EXTRA
  // =======================================================

  Future<void> _copiarLinkExtra(String idExtra) async {
    if (idExtra.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este extra não possui ID.',
          ),
        ),
      );

      return;
    }

    final uri = Uri.base.replace(
      queryParameters: {
        'id': idExtra,
      },
    );

    final link = uri.toString();

    await Clipboard.setData(
      ClipboardData(text: link),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'LINK COPIADO!',
        ),
      ),
    );
  }
}

// =========================================================
// TELA PÚBLICA DO EXTRA
// =========================================================
// Esta tela é aberta quando alguém acessa:
// SEU_SITE?id=1
//
// Ela mostra SOMENTE aquele extra.
// =========================================================

class TelaExtraPublico extends StatefulWidget {
  final String url;
  final String idExtra;

  const TelaExtraPublico({
    super.key,
    required this.url,
    required this.idExtra,
  });

  @override
  State<TelaExtraPublico> createState() =>
      _TelaExtraPublicoState();
}

class _TelaExtraPublicoState
    extends State<TelaExtraPublico> {
  bool carregando = true;

  String? erro;

  Map<String, dynamic>? extra;

  @override
  void initState() {
    super.initState();
    carregarExtra();
  }

  // =======================================================
  // CARREGAR EXTRA
  // =======================================================

  Future<void> carregarExtra() async {
    try {
      setState(() {
        carregando = true;
        erro = null;
      });

      final resposta = await http.get(
        Uri.parse(widget.url),
      );

      if (resposta.statusCode != 200) {
        throw Exception(
          'Erro HTTP: ${resposta.statusCode}',
        );
      }

      final dados = jsonDecode(resposta.body);

      if (dados is! Map) {
        throw Exception(
          'Resposta inválida.',
        );
      }

      final List<dynamic> linhas =
          dados['extras'] ?? [];

      if (linhas.isEmpty) {
        throw Exception(
          'Nenhum extra encontrado.',
        );
      }

      final List<String> cabecalho =
          List<String>.from(linhas[0]);

      Map<String, dynamic>? encontrado;

      for (int i = 1; i < linhas.length; i++) {
        final List<dynamic> linha =
            List<dynamic>.from(linhas[i]);

        final Map<String, dynamic> item = {};

        for (
          int coluna = 0;
          coluna < cabecalho.length &&
              coluna < linha.length;
          coluna++
        ) {
          item[cabecalho[coluna]] = linha[coluna];
        }

        final id =
            item['ID']?.toString().trim() ?? '';

        if (id == widget.idExtra.trim()) {
          encontrado = item;
          break;
        }
      }

      if (encontrado == null) {
        throw Exception(
          'Extra não encontrado.',
        );
      }

      if (!mounted) return;

      setState(() {
        extra = encontrado;
        carregando = false;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR EXTRA PÚBLICO: $e',
      );

      if (!mounted) return;

      setState(() {
        carregando = false;
        erro = 'Extra não encontrado.';
      });
    }
  }

  // =======================================================
  // TELA
  // =======================================================

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (erro != null || extra == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 70,
                ),

                const SizedBox(height: 20),

                Text(
                  erro ?? 'Extra não encontrado.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final item = extra!;

    final evento =
        item['EVENTO']?.toString() ?? '';

    final data =
        item['DATA']?.toString() ?? '';

    final inicio =
        item['INICIO']?.toString() ?? '';

    final fim =
        item['FIM']?.toString() ?? '';

    final local =
        item['LOCAL']?.toString() ?? '';

    final vagas =
        item['VAGAS']?.toString() ?? '';

    final idExtra =
        item['ID']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'INSCRIÇÃO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXTRA DISPONÍVEL',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  evento,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      data,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$inicio às $fim',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        local,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$vagas vagas',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // =================================================
                // INSCREVER-SE
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TelaFormularioInscricao(
                            url: widget.url,
                            idExtra: idExtra,
                            evento: evento,
                            data: data,
                            inicio: inicio,
                            fim: fim,
                            local: local,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person_add,
                    ),
                    label: const Text(
                      'INSCREVER-SE',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // =================================================
                // VER INSCRITOS
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TelaInscritos(
                            url: widget.url,
                            idExtra: idExtra,
                            evento: evento,
                            data: data,
                            inicio: inicio,
                            fim: fim,
                            local: local,
                            vagas: vagas,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.people_alt,
                    ),
                    label: const Text(
                      'VER INSCRITOS',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// TELA DE INSCRITOS
// =========================================================

class TelaInscritos extends StatefulWidget {
  final String url;
  final String idExtra;
  final String evento;
  final String data;
  final String inicio;
  final String fim;
  final String local;
  final String vagas;

  const TelaInscritos({
    super.key,
    required this.url,
    required this.idExtra,
    required this.evento,
    required this.data,
    required this.inicio,
    required this.fim,
    required this.local,
    required this.vagas,
  });

  @override
  State<TelaInscritos> createState() =>
      _TelaInscritosState();
}

class _TelaInscritosState
    extends State<TelaInscritos> {
  bool carregando = true;

  String? erro;

  List<String> inscritos = [];

  @override
  void initState() {
    super.initState();
    carregarInscritos();
  }

  // =======================================================
  // CARREGAR INSCRITOS
  // =======================================================

  Future<void> carregarInscritos() async {
    try {
      setState(() {
        carregando = true;
        erro = null;
      });

      final resposta = await http.get(
        Uri.parse(widget.url),
      );

      if (resposta.statusCode != 200) {
        throw Exception(
          'Erro HTTP: ${resposta.statusCode}',
        );
      }

      final dados = jsonDecode(resposta.body);

      if (dados is! Map) {
        throw Exception(
          'Resposta inválida do Google Sheets.',
        );
      }

      final List<dynamic> linhas =
          dados['inscricoes'] ?? [];

      final List<String> lista = [];

      if (linhas.isNotEmpty) {
        final List<String> cabecalho =
            List<String>.from(linhas[0]);

        final int colunaIdExtra =
            cabecalho.indexOf('ID_EXTRA');

        final int colunaNome =
            cabecalho.indexOf('NOME');

        if (colunaIdExtra == -1 ||
            colunaNome == -1) {
          throw Exception(
            'Colunas ID_EXTRA ou NOME não encontradas.',
          );
        }

        for (int i = 1; i < linhas.length; i++) {
          final List<dynamic> linha =
              List<dynamic>.from(linhas[i]);

          if (colunaIdExtra >= linha.length ||
              colunaNome >= linha.length) {
            continue;
          }

          final id =
              linha[colunaIdExtra]
                  .toString()
                  .trim();

          final nome =
              linha[colunaNome]
                  .toString()
                  .trim();

          if (id == widget.idExtra &&
              nome.isNotEmpty) {
            lista.add(nome);
          }
        }
      }

      // ORDEM ALFABÉTICA
      lista.sort(
        (a, b) => a.toUpperCase().compareTo(
          b.toUpperCase(),
        ),
      );

      if (!mounted) return;

      setState(() {
        inscritos = lista;
        carregando = false;
      });
    } catch (e) {
      debugPrint(
        'ERRO AO CARREGAR INSCRITOS: $e',
      );

      if (!mounted) return;

      setState(() {
        carregando = false;
        erro =
            'Não foi possível carregar os inscritos.';
      });
    }
  }

  // =======================================================
  // TELA
  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'INSCRITOS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _construirTela(),
    );
  }

  // =======================================================
  // CONSTRUIR TELA
  // =======================================================

  Widget _construirTela() {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 50,
            ),

            const SizedBox(height: 15),

            Text(
              erro!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: carregarInscritos,
              child: const Text(
                'TENTAR NOVAMENTE',
              ),
            ),
          ],
        ),
      );
    }

    final int total = inscritos.length;

    return RefreshIndicator(
      onRefresh: carregarInscritos,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // =================================================
          // INFORMAÇÕES DO EVENTO
          // =================================================

          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.evento,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.data,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.inicio} às ${widget.fim}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.local,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // TOTAL

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'TOTAL DE INSCRITOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          '$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'de ${widget.vagas} vagas',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          // =================================================
          // LISTA
          // =================================================

          if (inscritos.isEmpty)
            Card(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 60,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'NENHUM AGENTE INSCRITO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AGENTES INSCRITOS',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...List.generate(
                      inscritos.length,
                      (index) {
                        final nome =
                            inscritos[index];

                        return Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 12,
                          ),
                          decoration:
                              BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors
                                    .grey
                                    .shade300,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.black,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    50,
                                  ),
                                ),
                                alignment:
                                    Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child: Text(
                                  nome,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.black,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =========================================================
// FORMULÁRIO DE INSCRIÇÃO
// =========================================================

class TelaFormularioInscricao extends StatefulWidget {
  final String url;
  final String idExtra;
  final String evento;
  final String data;
  final String inicio;
  final String fim;
  final String local;

  const TelaFormularioInscricao({
    super.key,
    required this.url,
    required this.idExtra,
    required this.evento,
    required this.data,
    required this.inicio,
    required this.fim,
    required this.local,
  });

  @override
  State<TelaFormularioInscricao> createState() =>
      _TelaFormularioInscricaoState();
}

class _TelaFormularioInscricaoState
    extends State<TelaFormularioInscricao> {
  final TextEditingController nomeController =
      TextEditingController();

  bool gravando = false;

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  // =======================================================
  // TELA
  // =======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'INSCRIÇÃO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 550,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONFIRMAR INSCRIÇÃO',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'EVENTO',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  widget.evento,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.data,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${widget.inicio} às ${widget.fim}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.local,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'NOME DO AGENTE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: nomeController,
                  textCapitalization:
                      TextCapitalization.words,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Digite seu nome completo',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    filled: true,
                    fillColor:
                        Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: gravando
                        ? null
                        : _mostrarConfirmacao,
                    child: gravando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CONFIRMAR INSCRIÇÃO',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // CONFIRMAÇÃO
  // =======================================================

  void _mostrarConfirmacao() {
    final nome =
        nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Digite o nome do agente.',
          ),
        ),
      );

      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'CONFIRMAR',
          ),
          content: Text(
            'Deseja realizar a inscrição de:\n\n'
            '$nome\n\n'
            'no evento:\n'
            '${widget.evento}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCELAR',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _gravarInscricao();
              },
              child: const Text(
                'CONFIRMAR',
              ),
            ),
          ],
        );
      },
    );
  }

  // =======================================================
  // GRAVAR INSCRIÇÃO
  // =======================================================

  Future<void> _gravarInscricao() async {
    final nome =
        nomeController.text.trim();

    if (nome.isEmpty) {
      return;
    }

    setState(() {
      gravando = true;
    });

    try {
      final uri = Uri.parse(widget.url).replace(
        queryParameters: {
          'acao': 'inscrever',
          'id_extra': widget.idExtra,
          'evento': widget.evento,
          'nome': nome,
        },
      );

      debugPrint(
        'ENVIANDO INSCRIÇÃO PARA: $uri',
      );

      final resposta =
          await http.get(uri);

      debugPrint(
        'STATUS HTTP: ${resposta.statusCode}',
      );

      debugPrint(
        'RESPOSTA: ${resposta.body}',
      );

      if (resposta.statusCode != 200) {
        throw Exception(
          'Erro HTTP ${resposta.statusCode}',
        );
      }

      final dados =
          jsonDecode(resposta.body);

      if (dados is Map &&
          dados['sucesso'] == true) {
        if (!mounted) return;

        setState(() {
          gravando = false;
        });

        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              icon: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),

              title: const Text(
                'INSCRIÇÃO REALIZADA',
                textAlign: TextAlign.center,
              ),

              content: Text(
                'O agente:\n\n'
                '$nome\n\n'
                'foi inscrito com sucesso no evento:\n'
                '${widget.evento}.',
                textAlign: TextAlign.center,
              ),

              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'OK',
                    ),
                  ),
                ),
              ],
            );
          },
        );

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        final mensagem =
            dados['mensagem']?.toString() ??
            'Não foi possível realizar a inscrição.';

        if (!mounted) return;

        setState(() {
          gravando = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(mensagem),
          ),
        );
      }
    } catch (erro) {
      debugPrint(
        'ERRO AO GRAVAR INSCRIÇÃO: $erro',
      );

      if (!mounted) return;

      setState(() {
        gravando = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Erro ao gravar a inscrição no Google Sheets.',
          ),
        ),
      );
    }
  }
}