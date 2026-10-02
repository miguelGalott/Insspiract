import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';

Future<void> mostrarDialogoEsqueciSenha(BuildContext context, String email) async {
  final emailValido = email.trim().isNotEmpty;

  if (!emailValido) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Digite seu e-mail no campo acima primeiro.')),
    );
    return;
  }

  final confirmou = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FA),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.lock_reset_rounded, color: corAzul, size: 24),
            ),
            const SizedBox(height: 14),
            const Text(
              'Redefinir sua senha?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corTinta),
            ),
            const SizedBox(height: 8),
            Text(
              'Vamos enviar um e-mail de confirmação para $email. Deseja continuar?',
              style: const TextStyle(fontSize: 13, color: corTintaSuave, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: corLinha, width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar', style: TextStyle(color: corTintaSuave, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corLaranja,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  // showDialog
  if (confirmou == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enviamos a confirmação de mudar a senha, para o $email.')),
    );
  }
}