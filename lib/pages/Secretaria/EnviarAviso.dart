import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/AuthService.dart';

class EnviarAviso extends StatefulWidget {
  final String meuId;

  const EnviarAviso({super.key, required this.meuId});

  @override
  State<EnviarAviso> createState() => _EnviarAvisoState();
}

class _EnviarAvisoState extends State<EnviarAviso> {
  final TextEditingController controllerTitulo = TextEditingController();
  final TextEditingController controllerMensagem = TextEditingController();

  bool _carregando = false;
  bool _enviado = false;

  @override
  void dispose() {
    controllerTitulo.dispose();
    controllerMensagem.dispose();
    super.dispose();
  }

  void _publicarAviso() async {
    if (controllerTitulo.text.trim().isEmpty || controllerMensagem.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o título e a mensagem.')),
      );
      return;
    }

    setState(() => _carregando = true);

    final sucesso = await AuthService.enviarAviso(
      secreariaId: int.parse(widget.meuId),
      titulo: controllerTitulo.text.trim(),
      mensagem: controllerMensagem.text.trim(),
    );

    if (!mounted) return;
    setState(() => _carregando = false);

    if (sucesso) {
      setState(() => _enviado = true);
      controllerTitulo.clear();
      controllerMensagem.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível publicar agora. Tente de novo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Enviar aviso'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Comunique os professores',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: corTintaSuave, letterSpacing: .2),
              ),
              const SizedBox(height: 16),

              CampoInsspiract(
                rotulo: 'Título',
                controller: controllerTitulo,
                dica: 'Ex.: Sistema em manutenção',
              ),
              CampoInsspiract(
                rotulo: 'Mensagem',
                controller: controllerMensagem,
                dica: 'Contextualize o aviso...',
                linhas: 5,
              ),

              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: corAzul, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Este aviso será enviado para todos os professores cadastrados.',
                        style: TextStyle(color: corAzul, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _publicarAviso,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corLaranja,
                    disabledBackgroundColor: corLaranjaClaro,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _carregando
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                      : const Text(
                    'Publicar aviso',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              if (_enviado) ...[
                const SizedBox(height: 14),
                avisoPendente(
                  'Aviso publicado para todos os professores.',
                  icone: Icons.campaign_outlined,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}