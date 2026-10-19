import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/sessao.dart';
import 'package:primeiro_app/pages/Professor/ReservarHorario.dart';
import 'package:primeiro_app/pages/Professor/MeusAgendamentos.dart';
import 'package:primeiro_app/pages/Professor/Reclamacoes.dart';
import 'package:primeiro_app/pages/Secretaria/ProfessoresChat.dart';
import 'package:primeiro_app/pages/login.dart';

const Color corAzul = Color(0xFF004C94);
const Color corAzulClaro = Color(0xFF2C7BC7);
const Color corLaranja = Color(0xFFF7941D);
const Color corLaranjaClaro = Color(0xFFFDC180);
const Color corVerde = Color(0xFF1C9A55);
const Color corVermelho = Color(0xFFD8484A);
const Color corPapel = Color(0xFFF5F9FC);
const Color corTinta = Color(0xFF0E2338);
const Color corTintaSuave = Color(0xFF5B7188);
const Color corLinha = Color(0xFFE3EAF1);
const Color corAvisoFundo = Color(0xFFFFF1DE);
const Color corAvisoTexto = Color(0xFF8A5306);

class PaginaProfessor extends StatefulWidget {
  final String meuId;

  const PaginaProfessor({super.key, required this.meuId});

  @override
  State<PaginaProfessor> createState() => _PaginaProfessorState();
}

class _PaginaProfessorState extends State<PaginaProfessor> {
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
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Área do Professor',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.normal),
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
              icon: Icons.calendar_today_rounded,
              title: 'Reservar horário',
              subtitle: 'Escolha um horário livre na Sala Inspira',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReservarHorario(meuId: widget.meuId)));
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.assignment_outlined,
              title: 'Meus agendamentos',
              subtitle: 'Revise ou cancele suas reservas',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MeusAgendamentos(meuId: widget.meuId)));
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.forum_outlined,
              title: 'Negociar horário',
              subtitle: 'Troque um horário com outro professor',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfessoresChat(perfil: 'professor')));
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.people_outline_rounded,
              title: 'Fila de espera',
              subtitle: 'Veja sua posição após um cancelamento',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Essa tela ainda está em construção.')),
                );
              },
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.warning_amber_rounded,
              title: 'Reclamação / pedido de item',
              subtitle: 'Relate um problema ou peça um recurso',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Reclamacoes(professorId: widget.meuId)));
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
          const Text('Olá,', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 2),
          const Text(
            'Professor(a)',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                  decoration: const BoxDecoration(color: corVerde, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                const Text(
                  'Sala Inspira livre agora',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
                      Text(
                        title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0E2338)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF5B7188)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFB7C4D1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}