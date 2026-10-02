import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/gerenciador.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/sessao.dart';
import 'package:primeiro_app/pages/Secretaria/ValidarCadastro.dart';
import 'package:primeiro_app/pages/Secretaria/EnviarAviso.dart';
import 'package:primeiro_app/pages/Secretaria/GerenciarReserva.dart';
import 'package:primeiro_app/pages/Secretaria/RelatorioUso.dart';
import 'package:primeiro_app/pages/login.dart';

class PrincipalSecretaria extends StatefulWidget {
  final String meuId;

  const PrincipalSecretaria({super.key, required this.meuId});

  @override
  State<PrincipalSecretaria> createState() => _PrincipalSecretariaState();
}

class _PrincipalSecretariaState extends State<PrincipalSecretaria> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(103),
        child: AppBar(
          toolbarHeight: 100,
          backgroundColor: corAzul,
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Insspiract",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Área da Secretaria',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Sair',
              onPressed: () async {
                await Sessao.sair();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false,
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Container(height: 3, color: corLaranja),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHero(),
            const SizedBox(height: 16),
            _buildMenuCard(
              context: context,
              icon: Icons.how_to_reg_outlined,
              title: 'Validar cadastro',
              subtitle: 'Aprove solicitações de conta',
              rf: 'RF01 · RF04',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ValidarCadastro()));
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.campaign_outlined,
              title: 'Enviar aviso',
              subtitle: 'Comunique os professores',
              rf: 'RF03',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EnviarAviso()));
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.event_available_outlined,
              title: 'Gerenciar reservas',
              subtitle: 'Confirmar e desmarcar agendamentos',
              rf: 'RF05 · RF14',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GerenciarReservas()));
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.forum_outlined,
              title: 'Responder solicitações',
              subtitle: 'Veja pedidos e reclamações recebidos',
              rf: 'RF06',
              onTap: () {

              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.bar_chart_rounded,
              title: 'Relatório de uso',
              subtitle: 'Reservas, cancelamentos e reclamações',
              rf: 'RF13',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RelatorioUso()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [corAzul, corAzulClaro],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Olá,',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 2),
          const Text(
            'Secretário(a)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: corVerde,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'Pedidos pendentes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String rf,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EAF1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: corAzul, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0E2338),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FA),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              rf,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: corAzul,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5B7188),
                        ),
                      ),
                    ],
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