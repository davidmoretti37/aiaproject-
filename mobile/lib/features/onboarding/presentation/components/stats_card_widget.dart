import 'package:flutter/material.dart';

class StatsCardWidget extends StatelessWidget {
  const StatsCardWidget({super.key});

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
        children: [
          // Troféu e número de conversas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Estrelas decorativas ao redor do troféu
              Stack(
                children: [
                  // Estrela pequena superior esquerda
                  Positioned(
                    top: -5,
                    left: -15,
                    child: Icon(Icons.star, size: 12, color: Colors.amber[300]),
                  ),
                  // Estrela pequena superior direita
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Icon(Icons.star, size: 8, color: Colors.amber[300]),
                  ),
                  // Troféu central
                  Icon(Icons.emoji_events, size: 40, color: Colors.amber[600]),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Contagem de conversas
          const Text(
            '10,5k',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),

          const Text(
            'Conversas com a AIA',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.blue.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF92CAFF),
              ),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 16),

          // Dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDayCircle('MO', true),
              _buildDayCircle('TU', true),
              _buildDayCircle('WE', true),
              _buildDayCircle('TH', true),
              _buildDayCircle('FR', true),
              _buildDayCircle('SA', true),
              _buildDayCircle('SU', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCircle(String day, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? Colors.green.withOpacity(0.01)
                    : Colors.grey.withOpacity(0.01),
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                isCompleted
                    ? const Icon(Icons.check, size: 12, color: Colors.green)
                    : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
