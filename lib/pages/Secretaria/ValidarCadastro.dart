import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/AuthService.dart';

class ValidarCadastro extends StatefulWidget {
  const ValidarCadastro({super.key});

  @override
  State<ValidarCadastro> createState() => _ValidarCadastroState();
}

class _ValidarCadastroState extends State<ValidarCadastro> {
  late Future<List<Map<String, dynamic>>> _futurePendentes;
  final Set<int> _processando = {};
  @override
  void initState() {
    super.initState();
    _carregarPendentes();
  }

  void _carregarPendentes()      {
    setState(() {
      _futurePendentes = AuthService.listarCadastrosPendentes();
    });
  }

  Future<void> _decidir(int id, bool aprovar) async {
    setState(() => _processando.add(id));

    final sucesso = aprovar
        ? await AuthService.validarCad(idUsuario: id)
        : await AuthService.recusoCad(idUsuario: id);

    if (!mounted) return;
    setState(() => _processando.remove(id));

    if (sucesso) {
      _carregarPendentes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível registrar essa decisão agora.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Validar cadastros'),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futurePendentes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: corAzul));
            }

            final pendentes = snapshot.data ?? [];

            if (pendentes.isEmpty) {
              return const Center(child: Text('Tudo em dia — nenhum cadastro pendente.', style: TextStyle(color: corTintaSuave)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendentes.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _cartaoCadastro(pendentes[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _cartaoCadastro(Map<String, dynamic> c) {
    final int id = c['ID'] as int;
    final String nome = c['NOME'] as String;
    final String email = c['EMAIL'] as String;
    final String tipo = c['TIPO'] as String;
    final int aprovacoes = (c['APROVACOES'] as int?) ?? 0;
    final String? areaEnsino = c['AREA_ENSINO'] as String?;
    final String? matricula = c['MATRICULA_FUNCIONAL'] as String?;
    final bool processando = _processando.contains(id);

    return CartaoInsspiract(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              avatarIniciais(nome, tamanho: 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nome, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                    Text(email, style: const TextStyle(fontSize: 11.5, color: corTintaSuave)),
                  ],
                ),
              ),
              chipInsspiract(
                aprovacoes >= 0 ? '$aprovacoes/3 aprovações' : '${aprovacoes.abs()}/2 recusas',
                cor: corAvisoTexto,
                fundo: corAvisoFundo,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tipo == 'PROFESSOR' ? 'Área de ensino: ${areaEnsino ?? "-"}' : 'Matrícula funcional: ${matricula ?? "-"}',
            style: const TextStyle(fontSize: 12, color: corTintaSuave),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: processando ? null : () => _decidir(id, true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: corVerde,
                    side: const BorderSide(color: corVerde),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Aprovar', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: processando ? null : () => _decidir(id, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: corVermelho,
                    side: const BorderSide(color: corVermelho),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Recusar', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}