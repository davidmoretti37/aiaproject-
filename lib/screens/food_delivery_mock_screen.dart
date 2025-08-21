import 'package:flutter/material.dart';

class FoodDeliveryMockScreen extends StatelessWidget {
  final List<Map<String, dynamic>> restaurants = [
    {
      "id": "47883b65-fb7e-4f4a-bbb5-fb16fc5de7cb",
      "name": "Bullguer - República",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/47883b65-fb7e-4f4a-bbb5-fb16fc5de7cb/202506021953_Bkue_l.jpg",
      "rating": 4.8,
      "distance": "1.3 km",
      "delivery_fee": "RS6,99",
      "category": "Lanches",
    },
    {
      "id": "db514a0c-6c7f-45fc-b29e-1d7dba1a28d9",
      "name": "Mcdonald's Ipiranga (ipi)",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/db514a0c-6c7f-45fc-b29e-1d7dba1a28d9/202408251246_AS80.png",
      "rating": 4.1,
      "distance": "1.1 km",
      "delivery_fee": "RS0,99",
      "category": "Lanches",
    },
    {
      "id": "8cbaeb9f-23d8-432c-bbf9-1be4fe41a54d",
      "name": "Jv Burger- Hamburgueria",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/8cbaeb9f-23d8-432c-bbf9-1be4fe41a54d/202405050039_rVcr_i.jpg",
      "rating": 4.6,
      "distance": "1.4 km",
      "delivery_fee": "Gratis",
      "category": "Lanches",
    },
    {
      "id": "663fe2ae-4c8a-4e8d-904f-897ad5c539af",
      "name": "Hamburgão da Republica",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/663fe2ae-4c8a-4e8d-904f-897ad5c539af/202007231958_1lgh_.jpeg",
      "rating": 4.4,
      "distance": "1.4 km",
      "delivery_fee": "Gratis",
      "category": "Lanches",
    },
    {
      "id": "3c28c7d6-db8c-44fc-b83a-4af45920ae85",
      "name": "Buarque Pizza&burger",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/3c28c7d6-db8c-44fc-b83a-4af45920ae85/202304192202_IlWY_i.jpg",
      "rating": 4.6,
      "distance": "1.4 km",
      "delivery_fee": "Gratis",
      "category": "Pizza",
    },
    {
      "id": "0445d4ea-8c2f-4f41-8b54-e461d4baba37",
      "name": "Mr Mike Hambúrguer & Hot Dogs",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/0445d4ea-8c2f-4f41-8b54-e461d4baba37/202303152142_cQDz_i.jpg",
      "rating": 4.4,
      "distance": "6.0 km",
      "delivery_fee": "RS16,98",
      "category": "Lanches",
    },
    {
      "id": "248f6367-d575-4543-be04-58314f191d62",
      "name": "Fanis Burguer - Hamburgueria Artesanal",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/248f6367-d575-4543-be04-58314f191d62/202402171853_7KvD_i.jpg",
      "rating": 4.8,
      "distance": "4.0 km",
      "delivery_fee": "RS6,99",
      "category": "Lanches",
    },
    {
      "id": "2041c75b-46ce-456e-bd00-6f7b3b4a2c57",
      "name": "Hambúrguer e hot dog  delivery",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/2041c75b-46ce-456e-bd00-6f7b3b4a2c57/202411201949_nQzv_i.jpg",
      "rating": 4.4,
      "distance": "6.1 km",
      "delivery_fee": "RS14,99",
      "category": "Lanches",
    },
    {
      "id": "da38cbc7-2baa-4680-a472-3f232e87fd18",
      "name": "Insanos Hamburguer & Hot Dog",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/da38cbc7-2baa-4680-a472-3f232e87fd18/202307031934_PaZ2_i.jpg",
      "rating": 4.4,
      "distance": "6.1 km",
      "delivery_fee": "RS15,99",
      "category": "Lanches",
    },
    {
      "id": "5433739e-4a83-44cd-80f7-d04269c96dd3",
      "name": "Quebrada Burguer - Centro",
      "image":
          "https://static-images.ifood.com.br/image/upload/t_medium/logosgde/5433739e-4a83-44cd-80f7-d04269c96dd3/202406181957_jY6l_i.jpg",
      "rating": 4.7,
      "distance": "2.7 km",
      "delivery_fee": "RS9,99",
      "category": "Lanches",
    },
  ];

  FoodDeliveryMockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color background = const Color(0xFFF5F6FA);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top custom bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Seta padrão do projeto
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  // Avatar do usuário
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                ],
              ),
            ),
            // Título
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12, top: 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Melhores Escolhas",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
            // Lista de restaurantes
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                itemCount: restaurants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final r = restaurants[index];
                  final bool isFree = (r['delivery_fee']?.toString().toLowerCase() == 'gratis');
                  return Material(
                    elevation: 0.7,
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: r['image'] != null
                                  ? Image.network(
                                      r['image'],
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 32,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nome do restaurante
                                  Text(
                                    r['name'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF222B45),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Linha: estrela, nota, categoria, distância
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Color(0xFFFBC02D), size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        r['rating'] != null
                                            ? r['rating'].toStringAsFixed(1)
                                            : '--',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Categoria em cinza claro, sem fundo
                                      if (r['category'] != null)
                                        Text(
                                          r['category'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      const SizedBox(width: 10),
                                      // Distância
                                      Text(
                                        r['distance'] ?? '--',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Linha: taxa de entrega
                                  Row(
                                    children: [
                                      Text(
                                        isFree
                                            ? "Grátis"
                                            : r['delivery_fee'] ?? '--',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: isFree
                                              ? const Color(0xFF2ECC71)
                                              : Colors.grey[700],
                                          fontWeight: isFree ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
