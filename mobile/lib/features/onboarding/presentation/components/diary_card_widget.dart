import 'package:flutter/material.dart';

class DiaryCardWidget extends StatelessWidget {
  const DiaryCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji do dia
          const Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFFE6F9E6), // Verde claro
                radius: 18,
                child: Text('😊', style: TextStyle(fontSize: 20)),
              ),
              SizedBox(width: 8),
              Text(
                'Segunda-feira de folga',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Seção Atividades
          const Text(
            'ATIVIDADES',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Lista de atividades com ícones
          Row(
            children: [
              const Icon(Icons.favorite_border, size: 16, color: Colors.pink),
              const SizedBox(width: 8),
              const Text('saí pra jantar', style: TextStyle(fontSize: 14)),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.directions_walk, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              const Text('caminhada no parque', style: TextStyle(fontSize: 14)),
            ],
          ),

          const SizedBox(height: 16),

          // Seção Sentimentos
          const Text(
            'SEUS SENTIMENTOS',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Tags de sentimentos
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6), // Amarelo claro
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('😀', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text('energizado', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FF), // Azul claro
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('🤔', style: TextStyle(fontSize: 14)),
                    SizedBox(width: 4),
                    Text('ansioso', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
