import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';
class ValidarCadastro extends StatefulWidget {
  const ValidarCadastro({super.key});

  @override
  State<ValidarCadastro> createState() => _ValidarCadastroState();
}

class _CadastroPendente {
  final String nome;
  final String areaEnsino;
  final String email;
  String estado;

  _CadastroPendente({
    required this.nome,
    required this.areaEnsino,
    required this.email,
    this.estado = 'pendente',
  });
}

class _ValidarCadastroState extends State<ValidarCadastro> {

  final List<_CadastroPendente> _pendentes = [
    _CadastroPendente(nome: 'Prof. Carlos Menezes', areaEnsino: 'Redes de Computadores', email: 'carlos.menezes@senac.br'),
    _CadastroPendente(nome: 'Prof. Bruna Lima', areaEnsino: 'Desenvolvimento de Sistemas', email: 'bruna.lima@senac.br'),
    _CadastroPendente(nome: 'Prof. Rafael Souza', areaEnsino: 'Banco de Dados', email: 'rafael.souza@senac.br'),
  ];

  void _decidir(_CadastroPendente c, bool aprovar) {
    setState(() => c.estado = aprovar ? 'aprovado' : 'recusado');
  }

  @override
  Widget build(BuildContext context) {
    final pendentesCount = _pendentes.where((c) => c.estado == 'pendente').length;

    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(
        context,
        'Validar cadastros',
        subtitulo: pendentesCount == 0 ? 'Tudo em dia' : '$pendentesCount aguardando aprovação',
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pendentes.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _cartaoCadastro(_pendentes[index]),
          ),
        ),
      ),
    );
  }

  Widget _cartaoCadastro(_CadastroPendente c) {
    final decidido = c.estado != 'pendente';

    return Opacity(
      opacity: decidido ? .6 : 1,
      child: CartaoInsspiract(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                avatarIniciais(c.nome, tamanho: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.nome, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                      Text(c.email, style: const TextStyle(fontSize: 11.5, color: corTintaSuave)),
                    ],
                  ),
                ),
                _estadoChip(c),
              ],
            ),
            const SizedBox(height: 10),
            Text('Área de ensino: ${c.areaEnsino}', style: const TextStyle(fontSize: 12, color: corTintaSuave)),
            if (!decidido) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _decidir(c, true),
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
                      onPressed: () => _decidir(c, false),
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
          ],
        ),
      ),
    );
  }

  Widget _estadoChip(_CadastroPendente c) {
    switch (c.estado) {
      case 'aprovado':
        return chipInsspiract('Aprovado', cor: corVerde, fundo: const Color(0xFFE4F7EC));
      case 'recusado':
        return chipInsspiract('Recusado', cor: corVermelho, fundo: const Color(0xFFFCE9E9));
      default:
        return chipInsspiract('Pendente', cor: corAvisoTexto, fundo: corAvisoFundo);
    }
  }
}