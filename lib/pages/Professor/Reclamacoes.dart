import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';

class Reclamacoes extends StatefulWidget {
  const Reclamacoes({super.key});

  @override
  State<Reclamacoes> createState() => _ReclamacoesState();
}

class _ReclamacoesState extends State<Reclamacoes> {
  final TextEditingController controllerNome = TextEditingController();
  final List<String> opcoes = ['Reclamação sobre a sala', 'Pedido de item', 'Sugestão'];
  String? opcaoSelecionada;

  bool _enviado = false;

  @override
  void dispose() {
    controllerNome.dispose();
    super.dispose();
  }

  void _enviarCadastro() {
    setState(() => _enviado = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: corAzul,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Reclamação / pedido de item',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          centerTitle: false,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cabecalho(),
              const SizedBox(height: 20),
              _rotulo('Tipo'),
              const SizedBox(height: 8),
              _dropdownModerno(),
              const SizedBox(height: 18),
              _rotulo('Descrição'),
              const SizedBox(height: 8),
              _campoTexto(
                controller: controllerNome,
                dica: 'Descreva o ocorrido com o máximo de detalhes possível',
              ),
              const SizedBox(height: 24),
              _botaoEnviar(),
              if (_enviado) ...[
                const SizedBox(height: 16),
                _bannerConfirmacao(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reclamações e pedidos',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: corTinta,
          ),
        ),
        SizedBox(height: 2),
      ],
    );
  }

  Widget _rotulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: corTintaSuave,
        letterSpacing: .2,
      ),
    );
  }

  Widget _dropdownModerno() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: corPapel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: corLinha, width: 1.4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: opcaoSelecionada,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: corTintaSuave),
          hint: const Text(
            'Selecione uma opção',
            style: TextStyle(color: Color(0xFFAFC0D0), fontSize: 13.5),
          ),
          style: const TextStyle(color: corTinta, fontSize: 14, fontWeight: FontWeight.w600),
          borderRadius: BorderRadius.circular(14),
          items: opcoes.map((valor) {
            return DropdownMenuItem<String>(
              value: valor,
              child: Text(valor),
            );
          }).toList(),
          onChanged: (novoValor) {
            setState(() => opcaoSelecionada = novoValor);
          },
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String dica,
  }) {
    return TextField(
      keyboardType: TextInputType.multiline,
      minLines: 4,
      maxLines: 6,
      controller: controller,
      style: const TextStyle(color: corTinta, fontSize: 13.5, height: 1.4),
      decoration: InputDecoration(
        filled: true,
        fillColor: corPapel,
        hintText: dica,
        hintStyle: const TextStyle(color: Color(0xFFAFC0D0)),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: corLinha, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: corLinha, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: corAzulClaro, width: 1.8),
        ),
      ),
    );
  }

  Widget _botaoEnviar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _enviarCadastro,
        style: ElevatedButton.styleFrom(
          backgroundColor: corLaranja,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: corLaranja.withOpacity(.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.pressed) ? 0 : 6),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Enviar',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bannerConfirmacao() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: corLaranjaClaro),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: Color(0xFF8A5306), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enviado! Ele fica pendente até a secretaria responder.',
              style: TextStyle(color: Color(0xFF8A5306), fontSize: 12.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}