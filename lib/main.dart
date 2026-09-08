import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

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
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
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
// IDENTIDADE VISUAL INSTITUCIONAL
// =========================================================

const String assetEscudo = 'assets/escudo_iguaba.png';

class CabecalhoInstitucional extends StatelessWidget {
  final double tamanhoEscudo;
  final bool compacto;
  final Color corTexto;

  const CabecalhoInstitucional({
    super.key,
    this.tamanhoEscudo = 120,
    this.compacto = false,
    this.corTexto = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          assetEscudo,
          width: tamanhoEscudo,
          height: tamanhoEscudo,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.shield,
            color: corTexto,
            size: tamanhoEscudo * .65,
          ),
        ),
        SizedBox(height: compacto ? 4 : 8),
        Text(
          'PREFEITURA MUNICIPAL DE IGUABA GRANDE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: corTexto,
            fontSize: compacto ? 13 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'SECRETARIA MUNICIPAL DE SEGURANÇA E ORDEM PÚBLICA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: corTexto,
            fontSize: compacto ? 10 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}


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
              const CabecalhoInstitucional(
                tamanhoEscudo: 125,
              ),

              const SizedBox(height: 20),

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

              const SizedBox(height: 15),

              // =================================================
              // ADMINISTRADOR
              // =================================================

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaAdmin(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text(
                    'ADMINISTRADOR',
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
// PAINEL ADMINISTRATIVO
// =========================================================

class TelaAdmin extends StatelessWidget {
  const TelaAdmin({super.key});

  void _abrir(BuildContext context, Widget tela) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => tela),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PAINEL ADMINISTRATIVO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: .4,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.15,
            colors: [
              Color(0xFF191919),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final largura = constraints.maxWidth;
                final isDesktop = largura >= 900;
                final maxWidth = isDesktop ? 1050.0 : 720.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: largura < 500 ? 18 : 28,
                    vertical: 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      children: [
                        const CabecalhoInstitucional(
                          tamanhoEscudo: 125,
                          compacto: false,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'CONTROLE ADMINISTRATIVO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 72,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 34),
                        GridView.count(
                          crossAxisCount: isDesktop ? 4 : 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: isDesktop ? 1.02 : .98,
                          children: [
                            _botaoPainel(
                              context,
                              titulo: 'NOVO EXTRA',
                              icone: Icons.add_circle_outline,
                              tela: const TelaNovoExtra(),
                            ),
                            _botaoPainel(
                              context,
                              titulo: 'EXTRAS CADASTRADOS',
                              icone: Icons.calendar_month_outlined,
                              tela: const TelaAdminExtras(),
                            ),
                            _botaoPainel(
                              context,
                              titulo: 'INSCRITOS',
                              icone: Icons.groups_outlined,
                              tela: const TelaAdminInscritos(),
                            ),
                            _botaoPainel(
                              context,
                              titulo: 'RELATÓRIOS',
                              icone: Icons.picture_as_pdf_outlined,
                              tela: const TelaAdminRelatorios(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'SEGURANÇA • ORDEM • RESPEITO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoPainel(
    BuildContext context, {
    required String titulo,
    required IconData icone,
    required Widget tela,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _abrir(context, tela),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white38,
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 14,
                offset: Offset(0, 7),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white70,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icone,
                  color: Colors.white,
                  size: 47,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                titulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
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
// NOVO EXTRA
// =========================================================
// Cadastro de novo extra diretamente no Google Apps Script.
// =========================================================

class TelaNovoExtra extends StatefulWidget {
  const TelaNovoExtra({super.key});

  @override
  State<TelaNovoExtra> createState() => _TelaNovoExtraState();
}

class _TelaNovoExtraState extends State<TelaNovoExtra> {
  final evento = TextEditingController();
  final data = TextEditingController();
  final inicio = TextEditingController();
  final fim = TextEditingController();
  final local = TextEditingController();
  final vagas = TextEditingController();
  bool salvando = false;

  @override
  void dispose() {
    evento.dispose();
    data.dispose();
    inicio.dispose();
    fim.dispose();
    local.dispose();
    vagas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('NOVO EXTRA'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 650,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CADASTRAR NOVO EXTRA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                _campo(evento, 'EVENTO', 'Nome do evento'),
                _campoData(),
                Row(
                  children: [
                    Expanded(child: _campoHora(inicio, 'INÍCIO')),
                    const SizedBox(width: 12),
                    Expanded(child: _campoHora(fim, 'FIM')),
                  ],
                ),
                _campo(local, 'LOCAL', 'Local do evento'),
                _campo(vagas, 'VAGAS', 'Quantidade de vagas', teclado: TextInputType.number),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: salvando ? null : _salvarExtra,
                    icon: salvando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      salvando ? 'SALVANDO...' : 'SALVAR EXTRA',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  Future<void> _salvarExtra() async {
    final nomeEvento = evento.text.trim();
    final valorData = data.text.trim();
    final valorInicio = inicio.text.trim();
    final valorFim = fim.text.trim();
    final nomeLocal = local.text.trim();
    final valorVagas = vagas.text.trim();

    if (nomeEvento.isEmpty ||
        valorData.isEmpty ||
        valorInicio.isEmpty ||
        valorFim.isEmpty ||
        nomeLocal.isEmpty ||
        valorVagas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos antes de salvar.'),
        ),
      );
      return;
    }

    final quantidadeVagas = int.tryParse(valorVagas);

    if (quantidadeVagas == null || quantidadeVagas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma quantidade de vagas válida.'),
        ),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      final uri = Uri.parse(urlGoogle).replace(
        queryParameters: {
          'acao': 'criar_extra',
          'evento': nomeEvento,
          'data': valorData,
          'inicio': valorInicio,
          'fim': valorFim,
          'local': nomeLocal,
          'vagas': quantidadeVagas.toString(),
        },
      );

      final respostaHttp = await http.get(uri);

      if (respostaHttp.statusCode != 200) {
        throw Exception('HTTP ${respostaHttp.statusCode}');
      }

      final dados = jsonDecode(respostaHttp.body);

      if (dados is! Map || dados['sucesso'] != true) {
        throw Exception(
          dados is Map
              ? (dados['mensagem']?.toString() ?? 'Não foi possível salvar o extra.')
              : 'Resposta inválida do servidor.',
        );
      }

      if (!mounted) return;

      final link = dados['link']?.toString() ?? '';

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('EXTRA CADASTRADO'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LINK PÚBLICO:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                SelectableText(link),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: link.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: link));
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(content: Text('LINK COPIADO!')),
                          );
                        }
                      },
                icon: const Icon(Icons.copy),
                label: const Text('COPIAR LINK'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      evento.clear();
      data.clear();
      inicio.clear();
      fim.clear();
      local.clear();
      vagas.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Extra salvo com sucesso no Google Sheets.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar extra: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  Widget _campoData() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: data,
        readOnly: true,
        onTap: _selecionarData,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          labelText: 'DATA',
          hintText: 'Selecione a data',
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_month),
        ),
      ),
    );
  }

  Widget _campoHora(TextEditingController controller, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selecionarHora(controller),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: titulo,
          hintText: 'Selecione o horário',
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    DateTime inicial = DateTime.now();

    if (data.text.trim().isNotEmpty) {
      final partes = data.text.trim().split('/');
      if (partes.length == 3) {
        final dia = int.tryParse(partes[0]);
        final mes = int.tryParse(partes[1]);
        final ano = int.tryParse(partes[2]);
        if (dia != null && mes != null && ano != null) {
          final dataConvertida = DateTime(ano, mes, dia);
          if (dataConvertida.year == ano &&
              dataConvertida.month == mes &&
              dataConvertida.day == dia) {
            inicial = dataConvertida;
          }
        }
      }
    }

    final selecionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'SELECIONE A DATA DO EVENTO',
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada == null || !mounted) return;

    final dia = selecionada.day.toString().padLeft(2, '0');
    final mes = selecionada.month.toString().padLeft(2, '0');
    data.text = '$dia/$mes/${selecionada.year}';
  }

  Future<void> _selecionarHora(TextEditingController controller) async {
    TimeOfDay inicial = const TimeOfDay(hour: 18, minute: 0);

    if (controller.text.trim().isNotEmpty) {
      final partes = controller.text.trim().split(':');
      if (partes.length == 2) {
        final hora = int.tryParse(partes[0]);
        final minuto = int.tryParse(partes[1]);
        if (hora != null && minuto != null &&
            hora >= 0 && hora <= 23 && minuto >= 0 && minuto <= 59) {
          inicial = TimeOfDay(hour: hora, minute: minuto);
        }
      }
    }

    final selecionada = await showTimePicker(
      context: context,
      initialTime: inicial,
      helpText: 'SELECIONE O HORÁRIO',
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (selecionada == null || !mounted) return;

    final hora = selecionada.hour.toString().padLeft(2, '0');
    final minuto = selecionada.minute.toString().padLeft(2, '0');
    controller.text = '$hora:$minuto';
  }

  Widget _campo(
    TextEditingController controller,
    String titulo,
    String dica, {
    TextInputType? teclado,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: titulo,
          hintText: dica,
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// =========================================================
// COMPARTILHAMENTO DO EXTRA
// =========================================================

String linkPublicoExtra(Map<String, dynamic> extra) {
  final link = extra['LINK']?.toString().trim() ?? '';
  if (link.isNotEmpty) return link;
  final id = extra['ID']?.toString().trim() ?? '';
  return 'https://kosmeramos01.github.io/controle-extras/?id=$id';
}

Future<void> enviarWhatsAppExtra(
  BuildContext context,
  Map<String, dynamic> extra,
) async {
  final numeroController = TextEditingController();

  final numero = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('NÚMERO DO WHATSAPP'),
      content: TextField(
        controller: numeroController,
        keyboardType: TextInputType.phone,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Número com DDD',
          hintText: '22999999999',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('CANCELAR'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, numeroController.text.trim()),
          child: const Text('ABRIR WHATSAPP'),
        ),
      ],
    ),
  );

  numeroController.dispose();
  if (numero == null || numero.trim().isEmpty || !context.mounted) return;

  final numeroLimpo = numero.replaceAll(RegExp(r'[^0-9]'), '');
  if (numeroLimpo.length < 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informe um número válido com DDD.')),
    );
    return;
  }

  final evento = extra['EVENTO']?.toString() ?? 'EXTRA';
  final data = extra['DATA']?.toString() ?? '';
  final inicio = extra['INICIO']?.toString() ?? '';
  final fim = extra['FIM']?.toString() ?? '';
  final local = extra['LOCAL']?.toString() ?? '';
  final link = linkPublicoExtra(extra);

  final mensagem = '''CONTROLE DE EXTRAS

📢 Novo extra disponível!

Evento: $evento
Data: $data
Horário: $inicio às $fim
Local: $local

Faça sua inscrição pelo link:
$link''';

  final uri = Uri.parse(
    'https://wa.me/$numeroLimpo?text=${Uri.encodeComponent(mensagem)}',
  );

  try {
    final abriu = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abriu && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir WhatsApp: $e')),
      );
    }
  }
}

Future<void> copiarLinkExtra(BuildContext context, Map<String, dynamic> extra) async {
  final link = linkPublicoExtra(extra);
  await Clipboard.setData(ClipboardData(text: link));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Link copiado para a área de transferência.')),
  );
}

// =========================================================
// EXTRAS CADASTRADOS
// =========================================================

class TelaAdminExtras extends StatefulWidget {
  const TelaAdminExtras({super.key});

  @override
  State<TelaAdminExtras> createState() => _TelaAdminExtrasState();
}

class _TelaAdminExtrasState extends State<TelaAdminExtras> {
  bool carregando = true;
  String? erro;
  List<Map<String, dynamic>> extras = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      if (mounted) {
        setState(() {
          carregando = true;
          erro = null;
        });
      }

      final resposta = await http.get(Uri.parse(urlGoogle));
      if (resposta.statusCode != 200) {
        throw Exception('HTTP ${resposta.statusCode}');
      }

      final dados = jsonDecode(resposta.body);
      final linhas = List<dynamic>.from(dados['extras'] ?? []);
      final lista = <Map<String, dynamic>>[];

      if (linhas.isNotEmpty) {
        final cabecalho = List<String>.from(linhas.first);
        for (final bruto in linhas.skip(1)) {
          final linha = List<dynamic>.from(bruto);
          final item = <String, dynamic>{};
          for (var i = 0; i < cabecalho.length && i < linha.length; i++) {
            item[cabecalho[i]] = linha[i];
          }
          lista.add(item);
        }
      }

      lista.sort((a, b) {
        final dataA = a['DATA']?.toString() ?? '';
        final dataB = b['DATA']?.toString() ?? '';
        return dataA.compareTo(dataB);
      });

      if (!mounted) return;
      setState(() {
        extras = lista;
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        carregando = false;
        erro = 'Não foi possível carregar os extras.';
      });
    }
  }

  String _status(Map<String, dynamic> e) {
    return e['ABERTO']?.toString().trim().toUpperCase() ?? '';
  }

  String _textoStatus(String status) {
    if (status == 'SIM') return 'ABERTO';
    if (status == 'NAO' || status == 'NÃO') return 'ENCERRADO';
    if (status == 'CANCELADO') return 'CANCELADO';
    return status.isEmpty ? 'SEM STATUS' : status;
  }

  Future<void> _alterarStatus(
    Map<String, dynamic> extra,
    String status,
  ) async {
    final id = extra['ID']?.toString() ?? '';
    if (id.isEmpty) return;

    String titulo;
    String mensagem;

    if (status == 'NAO') {
      titulo = 'ENCERRAR EVENTO?';
      mensagem = 'As inscrições serão fechadas e o evento não aparecerá mais para novas inscrições.';
    } else if (status == 'CANCELADO') {
      titulo = 'CANCELAR EVENTO?';
      mensagem = 'O evento ficará cancelado e não poderá receber novas inscrições.';
    } else {
      titulo = 'REABRIR EVENTO?';
      mensagem = 'O evento voltará a aparecer para inscrições.';
    }

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('NÃO'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('SIM'),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;

    try {
      final uri = Uri.parse(urlGoogle).replace(
        queryParameters: {
          'acao': 'alterar_status',
          'id_extra': id,
          'status': status,
        },
      );

      final resposta = await http.get(uri);
      if (resposta.statusCode != 200) {
        throw Exception('HTTP ${resposta.statusCode}');
      }

      final dados = jsonDecode(resposta.body);
      if (dados is! Map || dados['sucesso'] != true) {
        throw Exception(
          dados is Map
              ? (dados['mensagem']?.toString() ?? 'Não foi possível alterar o evento.')
              : 'Resposta inválida do servidor.',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dados['mensagem']?.toString() ?? 'Status alterado.')),
      );
      await carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _excluir(Map<String, dynamic> extra) async {
    final id = extra['ID']?.toString() ?? '';
    final evento = extra['EVENTO']?.toString() ?? '';
    if (id.isEmpty) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('APAGAR EVENTO?'),
        content: Text(
          'O evento "$evento" será apagado definitivamente.\n\n'
          'As inscrições desse evento também serão removidas.\n\n'
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('APAGAR'),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;

    try {
      final uri = Uri.parse(urlGoogle).replace(
        queryParameters: {
          'acao': 'apagar_extra',
          'id_extra': id,
        },
      );

      final resposta = await http.get(uri);
      if (resposta.statusCode != 200) {
        throw Exception('HTTP ${resposta.statusCode}');
      }

      final dados = jsonDecode(resposta.body);
      if (dados is! Map || dados['sucesso'] != true) {
        throw Exception(
          dados is Map
              ? (dados['mensagem']?.toString() ?? 'Não foi possível apagar o evento.')
              : 'Resposta inválida do servidor.',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dados['mensagem']?.toString() ?? 'Evento apagado.')),
      );
      await carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao apagar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('EXTRAS CADASTRADOS'),
        actions: [
          IconButton(onPressed: carregar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : erro != null
              ? Center(child: Text(erro!, style: const TextStyle(color: Colors.white)))
              : extras.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum extra cadastrado.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: extras.length,
                      itemBuilder: (_, index) {
                        final e = extras[index];
                        final status = _status(e);
                        final aberto = status == 'SIM';
                        final cancelado = status == 'CANCELADO';

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 14),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e['EVENTO']?.toString() ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(_textoStatus(status)),
                                      backgroundColor: cancelado
                                          ? Colors.red.shade100
                                          : aberto
                                              ? Colors.green.shade100
                                              : Colors.orange.shade100,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Data: ${e['DATA'] ?? ''}\n'
                                  'Horário: ${e['INICIO'] ?? ''} às ${e['FIM'] ?? ''}\n'
                                  'Local: ${e['LOCAL'] ?? ''}\n'
                                  'Vagas: ${e['VAGAS'] ?? ''}',
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final alterou = await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TelaEditarExtra(extra: e),
                                          ),
                                        );
                                        if (alterou == true) carregar();
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: const Text('EDITAR'),
                                    ),
                                    if (aberto)
                                      OutlinedButton.icon(
                                        onPressed: () => _alterarStatus(e, 'NAO'),
                                        icon: const Icon(Icons.lock_outline),
                                        label: const Text('ENCERRAR'),
                                      )
                                    else if (!cancelado)
                                      OutlinedButton.icon(
                                        onPressed: () => _alterarStatus(e, 'SIM'),
                                        icon: const Icon(Icons.lock_open),
                                        label: const Text('REABRIR'),
                                      ),
                                    if (!cancelado)
                                      OutlinedButton.icon(
                                        onPressed: () => _alterarStatus(e, 'CANCELADO'),
                                        icon: const Icon(Icons.event_busy),
                                        label: const Text('CANCELAR'),
                                      ),
                                    OutlinedButton.icon(
                                      onPressed: () => copiarLinkExtra(context, e),
                                      icon: const Icon(Icons.link),
                                      label: const Text('COPIAR LINK'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => enviarWhatsAppExtra(context, e),
                                      icon: const Icon(Icons.chat),
                                      label: const Text('WHATSAPP'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _excluir(e),
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('APAGAR'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

// =========================================================
// EDITAR EXTRA
// =========================================================

class TelaEditarExtra extends StatefulWidget {
  final Map<String, dynamic> extra;

  const TelaEditarExtra({super.key, required this.extra});

  @override
  State<TelaEditarExtra> createState() => _TelaEditarExtraState();
}

class _TelaEditarExtraState extends State<TelaEditarExtra> {
  late final TextEditingController evento;
  late final TextEditingController data;
  late final TextEditingController inicio;
  late final TextEditingController fim;
  late final TextEditingController local;
  late final TextEditingController vagas;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    evento = TextEditingController(text: widget.extra['EVENTO']?.toString() ?? '');
    data = TextEditingController(text: widget.extra['DATA']?.toString() ?? '');
    inicio = TextEditingController(text: widget.extra['INICIO']?.toString() ?? '');
    fim = TextEditingController(text: widget.extra['FIM']?.toString() ?? '');
    local = TextEditingController(text: widget.extra['LOCAL']?.toString() ?? '');
    vagas = TextEditingController(text: widget.extra['VAGAS']?.toString() ?? '');
  }

  @override
  void dispose() {
    evento.dispose();
    data.dispose();
    inicio.dispose();
    fim.dispose();
    local.dispose();
    vagas.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    final id = widget.extra['ID']?.toString() ?? '';
    final valorEvento = evento.text.trim();
    final valorData = data.text.trim();
    final valorInicio = inicio.text.trim();
    final valorFim = fim.text.trim();
    final valorLocal = local.text.trim();
    final valorVagas = int.tryParse(vagas.text.trim());

    if (id.isEmpty || valorEvento.isEmpty || valorData.isEmpty ||
        valorInicio.isEmpty || valorFim.isEmpty || valorLocal.isEmpty ||
        valorVagas == null || valorVagas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos corretamente.')),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      final uri = Uri.parse(urlGoogle).replace(
        queryParameters: {
          'acao': 'editar_extra',
          'id_extra': id,
          'evento': valorEvento,
          'data': valorData,
          'inicio': valorInicio,
          'fim': valorFim,
          'local': valorLocal,
          'vagas': valorVagas.toString(),
        },
      );

      final resposta = await http.get(uri);
      if (resposta.statusCode != 200) {
        throw Exception('HTTP ${resposta.statusCode}');
      }

      final dados = jsonDecode(resposta.body);
      if (dados is! Map || dados['sucesso'] != true) {
        throw Exception(
          dados is Map
              ? (dados['mensagem']?.toString() ?? 'Não foi possível editar o evento.')
              : 'Resposta inválida do servidor.',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dados['mensagem']?.toString() ?? 'Evento atualizado.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao editar: $e')),
      );
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<void> _selecionarData() async {
    DateTime inicial = DateTime.now();
    final partes = data.text.trim().split('/');
    if (partes.length == 3) {
      final dia = int.tryParse(partes[0]);
      final mes = int.tryParse(partes[1]);
      final ano = int.tryParse(partes[2]);
      if (dia != null && mes != null && ano != null) {
        final d = DateTime(ano, mes, dia);
        if (d.year == ano && d.month == mes && d.day == dia) inicial = d;
      }
    }

    final selecionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      helpText: 'SELECIONE A DATA DO EVENTO',
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada == null || !mounted) return;
    final dia = selecionada.day.toString().padLeft(2, '0');
    final mes = selecionada.month.toString().padLeft(2, '0');
    data.text = '$dia/$mes/${selecionada.year}';
  }

  Future<void> _selecionarHora(TextEditingController controller) async {
    TimeOfDay inicial = const TimeOfDay(hour: 18, minute: 0);
    final partes = controller.text.trim().split(':');
    if (partes.length == 2) {
      final h = int.tryParse(partes[0]);
      final m = int.tryParse(partes[1]);
      if (h != null && m != null && h >= 0 && h <= 23 && m >= 0 && m <= 59) {
        inicial = TimeOfDay(hour: h, minute: m);
      }
    }

    final selecionada = await showTimePicker(
      context: context,
      initialTime: inicial,
      helpText: 'SELECIONE O HORÁRIO',
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (selecionada == null || !mounted) return;
    controller.text =
        '${selecionada.hour.toString().padLeft(2, '0')}:${selecionada.minute.toString().padLeft(2, '0')}';
  }

  Widget _campo(TextEditingController controller, String titulo, String dica,
      {TextInputType? teclado}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: titulo,
          hintText: dica,
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _campoData() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: data,
        readOnly: true,
        onTap: _selecionarData,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          labelText: 'DATA',
          hintText: 'Selecione a data',
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_month),
        ),
      ),
    );
  }

  Widget _campoHora(TextEditingController controller, String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () => _selecionarHora(controller),
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: titulo,
          hintText: 'Selecione o horário',
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('EDITAR EXTRA'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 650,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EDITAR EXTRA',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                _campo(evento, 'EVENTO', 'Nome do evento'),
                _campoData(),
                Row(
                  children: [
                    Expanded(child: _campoHora(inicio, 'INÍCIO')),
                    const SizedBox(width: 12),
                    Expanded(child: _campoHora(fim, 'FIM')),
                  ],
                ),
                _campo(local, 'LOCAL', 'Local do evento'),
                _campo(vagas, 'VAGAS', 'Quantidade de vagas', teclado: TextInputType.number),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: salvando ? null : _salvar,
                    icon: salvando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(salvando ? 'SALVANDO...' : 'SALVAR ALTERAÇÕES'),
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
// INSCRITOS - ADMINISTRADOR
// =========================================================

class TelaAdminInscritos extends StatefulWidget {
  const TelaAdminInscritos({super.key});

  @override
  State<TelaAdminInscritos> createState() => _TelaAdminInscritosState();
}

class _TelaAdminInscritosState extends State<TelaAdminInscritos> {
  bool carregando = true;
  String? erro;
  List<Map<String, dynamic>> inscricoes = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      if (mounted) {
        setState(() {
          carregando = true;
          erro = null;
        });
      }

      final resposta = await http.get(Uri.parse(urlGoogle).replace(queryParameters: {'acao': 'dados_admin'}));
      if (resposta.statusCode != 200) throw Exception();

      final dados = jsonDecode(resposta.body);
      final linhas = List<dynamic>.from(dados['inscricoes'] ?? []);
      final lista = <Map<String, dynamic>>[];

      if (linhas.isNotEmpty) {
        final cabecalho = List<String>.from(linhas.first);
        for (final bruto in linhas.skip(1)) {
          final linha = List<dynamic>.from(bruto);
          final item = <String, dynamic>{};
          for (var i = 0; i < cabecalho.length && i < linha.length; i++) {
            item[cabecalho[i]] = linha[i];
          }
          lista.add(item);
        }
      }

      lista.sort((a, b) {
        final eventoA = (a['EVENTO']?.toString() ?? '').toUpperCase();
        final eventoB = (b['EVENTO']?.toString() ?? '').toUpperCase();
        final cmpEvento = eventoA.compareTo(eventoB);
        if (cmpEvento != 0) return cmpEvento;
        return (a['NOME']?.toString() ?? '').toUpperCase().compareTo(
              (b['NOME']?.toString() ?? '').toUpperCase(),
            );
      });

      if (!mounted) return;
      setState(() {
        inscricoes = lista;
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        carregando = false;
        erro = 'Não foi possível carregar os inscritos.';
      });
    }
  }

  Future<void> _excluirInscricao(Map<String, dynamic> inscricao) async {
    final idInscricao = inscricao['ID_INSCRICAO']?.toString().trim() ?? '';
    final idExtra = inscricao['ID_EXTRA']?.toString().trim() ?? '';
    final evento = inscricao['EVENTO']?.toString().trim() ?? 'EVENTO';
    final nome = inscricao['NOME']?.toString().trim() ?? '';

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('EXCLUIR INSCRIÇÃO?'),
        content: Text(
          'O inscrito "$nome" será removido do evento:\n\n'
          '$evento\n\n'
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;

    try {
      final uri = Uri.parse(urlGoogle).replace(
        queryParameters: {
          'acao': 'apagar_inscricao',
          'id_inscricao': idInscricao,
          'id_extra': idExtra,
          'nome': nome,
        },
      );

      final resposta = await http.get(uri);
      if (resposta.statusCode != 200) {
        throw Exception('HTTP ${resposta.statusCode}');
      }

      final dados = jsonDecode(resposta.body);
      if (dados is! Map || dados['sucesso'] != true) {
        throw Exception(
          dados is Map
              ? (dados['mensagem']?.toString() ??
                  'Não foi possível excluir a inscrição.')
              : 'Resposta inválida do servidor.',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dados['mensagem']?.toString() ??
                'Inscrição excluída com sucesso.',
          ),
        ),
      );
      await carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir inscrição: $e')),
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> _agruparPorEvento() {
    final grupos = <String, List<Map<String, dynamic>>>{};

    for (final inscricao in inscricoes) {
      final id = inscricao['ID_EXTRA']?.toString().trim() ?? '';
      final evento = inscricao['EVENTO']?.toString().trim() ?? '';
      final chave = id.isNotEmpty ? id : evento;
      grupos.putIfAbsent(chave, () => []).add(inscricao);
    }

    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    final grupos = _agruparPorEvento();
    final chaves = grupos.keys.toList()
      ..sort((a, b) {
        final eventoA = grupos[a]!.first['EVENTO']?.toString() ?? '';
        final eventoB = grupos[b]!.first['EVENTO']?.toString() ?? '';
        return eventoA.toUpperCase().compareTo(eventoB.toUpperCase());
      });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('INSCRITOS POR EVENTO'),
        actions: [
          IconButton(onPressed: carregar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : erro != null
              ? Center(child: Text(erro!, style: const TextStyle(color: Colors.white)))
              : grupos.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma inscrição encontrada.',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: chaves.length,
                      itemBuilder: (_, index) {
                        final grupo = grupos[chaves[index]]!;
                        final primeiro = grupo.first;
                        final evento = primeiro['EVENTO']?.toString() ?? 'EVENTO';

                        grupo.sort((a, b) =>
                            (a['NOME']?.toString() ?? '').toUpperCase().compareTo(
                                  (b['NOME']?.toString() ?? '').toUpperCase(),
                                ));

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 15),
                          child: ExpansionTile(
                            initiallyExpanded: chaves.length == 1,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            title: Text(
                              evento,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              '${grupo.length} inscrito(s)',
                            ),
                            leading: const Icon(Icons.event, color: Colors.black),
                            children: [
                              const Divider(height: 1),
                              ...grupo.asMap().entries.map((entry) {
                                final posicao = entry.key + 1;
                                final inscricao = entry.value;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.black,
                                    child: Text(
                                      '$posicao',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text(
                                    inscricao['NOME']?.toString() ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Excluir inscrição',
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _excluirInscricao(inscricao),
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}

// =========================================================
// RELATÓRIOS - ADMINISTRADOR
// =========================================================

class TelaAdminRelatorios extends StatefulWidget {
  const TelaAdminRelatorios({super.key});
  @override
  State<TelaAdminRelatorios> createState() => _TelaAdminRelatoriosState();
}

class _TelaAdminRelatoriosState extends State<TelaAdminRelatorios> {
  bool carregando = true;
  bool gerando = false;
  String? erro;
  List<Map<String, dynamic>> extras = [];
  List<Map<String, dynamic>> inscricoes = [];
  final Set<String> selecionados = {};
  late int mesSelecionado;
  late int anoSelecionado;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    mesSelecionado = agora.month;
    anoSelecionado = agora.year;
    carregar();
  }

  Future<void> carregar() async {
    try {
      setState(() { carregando = true; erro = null; });
      final resposta = await http.get(Uri.parse(urlGoogle).replace(queryParameters: {'acao': 'dados_admin'}));
      if (resposta.statusCode != 200) throw Exception('HTTP ${resposta.statusCode}');
      final dados = jsonDecode(resposta.body);
      extras = _converterTabela(dados['extras']);
      inscricoes = _converterTabela(dados['inscricoes']);
      selecionados.removeWhere((id) => !extras.any((e) => e['ID']?.toString() == id));
      if (!mounted) return;
      setState(() => carregando = false);
    } catch (_) {
      if (!mounted) return;
      setState(() { carregando = false; erro = 'Não foi possível carregar os dados dos relatórios.'; });
    }
  }

  List<Map<String, dynamic>> _converterTabela(dynamic bruto) {
    final linhas = List<dynamic>.from(bruto ?? []);
    final lista = <Map<String, dynamic>>[];
    if (linhas.isEmpty) return lista;
    final cabecalho = List<String>.from(linhas.first);
    for (final brutoLinha in linhas.skip(1)) {
      final linha = List<dynamic>.from(brutoLinha);
      final item = <String, dynamic>{};
      for (var i = 0; i < cabecalho.length && i < linha.length; i++) {
        item[cabecalho[i]] = linha[i];
      }
      lista.add(item);
    }
    return lista;
  }

  DateTime? _parseData(String valor) {
    final p = valor.trim().split('/');
    if (p.length != 3) return null;
    final dia = int.tryParse(p[0]);
    final mes = int.tryParse(p[1]);
    var ano = int.tryParse(p[2]);
    if (dia == null || mes == null || ano == null) return null;
    if (ano < 100) ano += 2000;
    try { return DateTime(ano, mes, dia); } catch (_) { return null; }
  }

  List<Map<String, dynamic>> get extrasDoPeriodo {
    final lista = extras.where((e) {
      final data = _parseData(e['DATA']?.toString() ?? '');
      return data != null && data.month == mesSelecionado && data.year == anoSelecionado;
    }).toList();
    lista.sort((a,b) {
      final da = _parseData(a['DATA']?.toString() ?? '') ?? DateTime(1900);
      final db = _parseData(b['DATA']?.toString() ?? '') ?? DateTime(1900);
      final c = da.compareTo(db);
      if (c != 0) return c;
      return (a['EVENTO']?.toString() ?? '').toUpperCase().compareTo((b['EVENTO']?.toString() ?? '').toUpperCase());
    });
    return lista;
  }

  List<Map<String, dynamic>> _inscritosDoExtra(String id) {
    final lista = inscricoes.where((i) => i['ID_EXTRA']?.toString().trim() == id).toList();
    lista.sort((a,b) => (a['NOME']?.toString() ?? '').toUpperCase().compareTo((b['NOME']?.toString() ?? '').toUpperCase()));
    return lista;
  }

  String _nomeMes(int mes) {
    const meses = ['JANEIRO','FEVEREIRO','MARÇO','ABRIL','MAIO','JUNHO','JULHO','AGOSTO','SETEMBRO','OUTUBRO','NOVEMBRO','DEZEMBRO'];
    return meses[mes - 1];
  }

  String _formatarData(String valor) {
    final d = _parseData(valor);
    if (d == null) return valor;
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  }

  Future<void> _gerarPdf({required bool listaPresenca}) async {
    final listaExtras = extrasDoPeriodo
        .where((e) => selecionados.contains(e['ID']?.toString()))
        .toList();

    if (listaExtras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um evento.')),
      );
      return;
    }

    setState(() => gerando = true);

    try {
      final documento = pw.Document();
      final escudoBytes =
          (await rootBundle.load(assetEscudo)).buffer.asUint8List();
      final escudoPdf = pw.MemoryImage(escudoBytes);

      if (listaPresenca) {
        // A lista de presença é organizada por evento, com espaço
        // suficiente para assinatura manual de cada agente.
        for (final extra in listaExtras) {
          final id = extra['ID']?.toString() ?? '';
          final lista = _inscritosDoExtra(id);

          documento.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              margin: const pw.EdgeInsets.fromLTRB(42, 30, 42, 36),
              footer: (ctx) => pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ),
              build: (ctx) => [
                _cabecalhoPdfCentralizado(escudoPdf),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Text(
                    'LISTA DE PRESENÇA',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    '${_nomeMes(mesSelecionado)} / $anoSelecionado',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 14),
                _caixaEventoPdf(extra, lista.length),
                pw.SizedBox(height: 12),
                _tabelaPresencaPdf(lista),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Declaro, para os devidos fins, que os agentes relacionados acima compareceram ao evento e confirmaram sua presença mediante assinatura.',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.SizedBox(height: 24),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Divider(),
                          pw.Text(
                            'RESPONSÁVEL PELO EVENTO',
                            style: const pw.TextStyle(fontSize: 7),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 50),
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Divider(),
                          pw.Text(
                            'CONFERÊNCIA',
                            style: const pw.TextStyle(fontSize: 7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      } else {
        documento.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.fromLTRB(42, 30, 42, 36),
            footer: (ctx) => pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 7),
              ),
            ),
            build: (ctx) {
              final widgets = <pw.Widget>[
                _cabecalhoPdfCentralizado(escudoPdf),
                pw.SizedBox(height: 12),
                pw.Center(
                  child: pw.Text(
                    'CONTROLE DE EXTRAS',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    '${_nomeMes(mesSelecionado)} / $anoSelecionado',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 14),
              ];

              for (var indice = 0; indice < listaExtras.length; indice++) {
                final extra = listaExtras[indice];
                final id = extra['ID']?.toString() ?? '';
                final lista = _inscritosDoExtra(id);

                widgets.addAll([
                  _caixaEventoPdf(extra, lista.length),
                  pw.SizedBox(height: 10),
                  if (lista.isEmpty)
                    pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Nenhum inscrito.'),
                    )
                  else
                    _tabelaInscritosPdf(lista),
                  if (indice < listaExtras.length - 1) ...[
                    pw.SizedBox(height: 16),
                    pw.Divider(),
                    pw.SizedBox(height: 12),
                  ],
                ]);
              }

              return widgets;
            },
          ),
        );
      }

      final bytes = await documento.save();
      final nomeArquivo = listaPresenca
          ? 'lista_presenca_${mesSelecionado}_$anoSelecionado.pdf'
          : 'relatorio_extras_${mesSelecionado}_$anoSelecionado.pdf';

      await Printing.layoutPdf(
        name: nomeArquivo,
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => gerando = false);
    }
  }

  pw.Widget _cabecalhoPdfCentralizado(pw.MemoryImage escudo) {
    return pw.Center(
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Image(escudo, width: 70, height: 70),
          pw.SizedBox(height: 5),
          pw.Text(
            'PREFEITURA MUNICIPAL DE IGUABA GRANDE',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'SECRETARIA MUNICIPAL DE SEGURANÇA E ORDEM PÚBLICA',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _caixaEventoPdf(Map<String, dynamic> extra, int total) {
    return pw.Container(
      width: 235,
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: .8),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            extra['EVENTO']?.toString() ?? 'EVENTO',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text('Data: ${_formatarData(extra['DATA']?.toString() ?? '')}', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Text('Horário: ${extra['INICIO'] ?? ''} às ${extra['FIM'] ?? ''}', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Text('Local: ${extra['LOCAL'] ?? ''}', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Text('Vagas: ${extra['VAGAS'] ?? ''}', style: const pw.TextStyle(fontSize: 8.5)),
          pw.Text('Total de inscritos: $total', style: const pw.TextStyle(fontSize: 8.5)),
        ],
      ),
    );
  }

  pw.Widget _tabelaInscritosPdf(List<Map<String, dynamic>> lista) {
    final linhas = <List<String>>[];

    for (var i = 0; i < lista.length; i++) {
      linhas.add([
        '${i + 1}',
        lista[i]['NOME']?.toString() ?? '',
      ]);
    }

    return pw.TableHelper.fromTextArray(
      headers: const ['Nº', 'NOME DO INSCRITO'],
      data: linhas,
      border: pw.TableBorder.all(width: .5),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      columnWidths: const {
        0: pw.FixedColumnWidth(42),
        1: pw.FlexColumnWidth(),
      },
    );
  }

  pw.Widget _tabelaPresencaPdf(List<Map<String, dynamic>> lista) {
    final linhas = <List<String>>[];
    for (var i = 0; i < lista.length; i++) {
      linhas.add([
        '${i + 1}',
        lista[i]['NOME']?.toString() ?? '',
        '☐',
        '________________________________',
      ]);
    }

    return pw.TableHelper.fromTextArray(
      headers: const ['Nº', 'NOME DO AGENTE', 'PRESENTE', 'ASSINATURA'],
      data: linhas,
      border: pw.TableBorder.all(width: .5),
      headerStyle: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 7.5),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      columnWidths: const {
        0: pw.FixedColumnWidth(32),
        1: pw.FlexColumnWidth(2.8),
        2: pw.FixedColumnWidth(52),
        3: pw.FlexColumnWidth(2.2),
      },
      cellAlignments: const {
        0: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerLeft,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = extrasDoPeriodo;
    final todos = lista.isNotEmpty && lista.every((e) => selecionados.contains(e['ID']?.toString()));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white, title: const Text('RELATÓRIOS'), actions: [IconButton(onPressed: carregar, icon: const Icon(Icons.refresh))]),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : erro != null
              ? Center(child: Text(erro!, style: const TextStyle(color: Colors.white)))
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PERÍODO DO RELATÓRIO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<int>(
                                    initialValue: mesSelecionado,
                                    dropdownColor: Colors.white,
                                    decoration: InputDecoration(
                                      labelText: 'MÊS',
                                      labelStyle: const TextStyle(color: Colors.black),
                                      floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    items: [
                                      for (var i = 1; i <= 12; i++)
                                        DropdownMenuItem(
                                          value: i,
                                          child: Text(_nomeMes(i)),
                                        ),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() {
                                        mesSelecionado = v;
                                        selecionados.clear();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<int>(
                                    initialValue: anoSelecionado,
                                    dropdownColor: Colors.white,
                                    decoration: InputDecoration(
                                      labelText: 'ANO',
                                      labelStyle: const TextStyle(color: Colors.black),
                                      floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    items: [
                                      for (var ano = DateTime.now().year - 2;
                                          ano <= DateTime.now().year + 3;
                                          ano++)
                                        DropdownMenuItem(
                                          value: ano,
                                          child: Text('$ano'),
                                        ),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      setState(() {
                                        anoSelecionado = v;
                                        selecionados.clear();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal:20,vertical:4), child: Row(children:[
                    Expanded(child:Text('${lista.length} evento(s) encontrado(s)',style:const TextStyle(color:Colors.white,fontSize:16))),
                    TextButton.icon(
                      onPressed:lista.isEmpty?null:(){setState((){if(todos){selecionados.removeAll(lista.map((e)=>e['ID']?.toString()??''));}else{selecionados.addAll(lista.map((e)=>e['ID']?.toString()??''));}});},
                      icon:Icon(todos?Icons.deselect:Icons.select_all,color:Colors.white),
                      label:Text(todos?'DESMARCAR TODOS':'SELECIONAR TODOS',style:const TextStyle(color:Colors.white)),
                    ),
                  ])),
                  Expanded(child:lista.isEmpty
                    ? const Center(child:Text('Nenhum evento encontrado para este mês.',style:TextStyle(color:Colors.white70,fontSize:17),textAlign:TextAlign.center))
                    : ListView.builder(
                        padding:const EdgeInsets.fromLTRB(20,8,20,20), itemCount:lista.length,
                        itemBuilder:(_,index){
                          final e=lista[index]; final id=e['ID']?.toString()??''; final qtd=_inscritosDoExtra(id).length;
                          return Card(color:Colors.white,margin:const EdgeInsets.only(bottom:10),child:CheckboxListTile(
                            value:selecionados.contains(id),
                            onChanged:(v){setState((){if(v==true){selecionados.add(id);}else{selecionados.remove(id);}});},
                            title:Text(e['EVENTO']?.toString()??'',style:const TextStyle(fontWeight:FontWeight.bold)),
                            subtitle:Text('${_formatarData(e['DATA']?.toString()??'')}  •  ${e['INICIO']??''} às ${e['FIM']??''}\nInscritos: $qtd  •  Local: ${e['LOCAL']??''}'),
                            secondary:CircleAvatar(backgroundColor:Colors.black,child:Text('$qtd',style:const TextStyle(color:Colors.white))),
                          ));
                        },
                      )),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: gerando ? null : () => _gerarPdf(listaPresenca: false),
                                icon: const Icon(Icons.picture_as_pdf),
                                label: Text(gerando ? 'GERANDO...' : 'RELATÓRIO PDF'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: gerando ? null : () => _gerarPdf(listaPresenca: true),
                                icon: const Icon(Icons.edit_note),
                                label: Text(gerando ? 'GERANDO...' : 'LISTA DE PRESENÇA'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
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

          ],
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
        Uri.parse(widget.url).replace(
          queryParameters: {
            'acao': 'extra_publico',
            'id_extra': widget.idExtra,
          },
        ),
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

final idExtra =
    item['ID']?.toString() ?? '';

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
                const Center(
                  child: CabecalhoInstitucional(
                    tamanhoEscudo: 105,
                    compacto: true,
                    corTexto: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
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

                  ],
            ),
          ),
        ),
      ),
    );
  }
}

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