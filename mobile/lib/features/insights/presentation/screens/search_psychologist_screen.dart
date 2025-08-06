import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calma_flutter/presentation/common_widgets/input_field.dart';
import 'package:calma_flutter/presentation/common_widgets/primary_button.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/features/insights/domain/models/psychologist_model.dart';
import 'package:calma_flutter/features/insights/domain/repositories/psychologist_repository.dart';
import 'package:calma_flutter/features/insights/services/psychologist_invitation_service.dart';

class SearchPsychologistScreen extends StatefulWidget {
  const SearchPsychologistScreen({super.key});

  @override
  State<SearchPsychologistScreen> createState() => _SearchPsychologistScreenState();
}

class _SearchPsychologistScreenState extends State<SearchPsychologistScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<PsychologistModel> _psychologists = [];
  
  late final PsychologistRepository _psychologistRepository;
  
  @override
  void initState() {
    super.initState();
    _psychologistRepository = getIt<PsychologistRepository>();
    _loadAllPsychologists();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAllPsychologists() async {
    setState(() {
      _isLoading = true;
    });
    
    final psychologists = await _psychologistRepository.getAllPsychologists();
    
    setState(() {
      _psychologists = psychologists;
      _isLoading = false;
    });
  }
  
  Future<void> _searchPsychologists(String query) async {
    if (query.isEmpty) {
      _loadAllPsychologists();
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final psychologists = await _psychologistRepository.searchPsychologists(query);
    
    setState(() {
      _psychologists = psychologists;
      _isLoading = false;
    });
  }
  
  void _showInviteByEmailDialog() {
    final emailController = TextEditingController();
    bool isEmailValid = false;
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Convidar por E-mail'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Insira o e-mail do psicólogo que você deseja convidar:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: emailController,
                  hint: 'exemplo@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF9D82FF),
                    size: 20,
                  ),
                  onChanged: (value) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    setState(() {
                      isEmailValid = emailRegex.hasMatch(value);
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: isEmailValid && !isLoading
                  ? () async {
                      setState(() {
                        isLoading = true;
                      });
                      
                      try {
                        final invitationService = getIt<PsychologistInvitationService>();
                        final success = await invitationService.sendInvitationByEmail(emailController.text);
                        
                        if (success) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Convite enviado com sucesso!'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao enviar convite: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  : null,
                child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF9D82FF),
                      ),
                    )
                  : const Text('Enviar'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header com botão de voltar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Buscar Psicólogo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Para balancear o layout
                ],
              ),
            ),
            
            // Campo de busca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InputField(
                controller: _searchController,
                hint: 'Buscar por nome, email ou CRP',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9D82FF),
                  size: 20,
                ),
                onChanged: (value) => _searchPsychologists(value),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lista de psicólogos
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF9D82FF)))
                : _psychologists.isEmpty
                  ? _buildEmptyState()
                  : _buildPsychologistsList(),
            ),
            
            // Botão para convidar por e-mail
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Não encontrou seu Psicólogo?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  PrimaryButton(
                    text: 'Convidar por E-mail',
                    onPressed: () => _showInviteByEmailDialog(),
                    backgroundColor: const Color(0xFF9D82FF),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum psicólogo encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar com outros termos ou convide por e-mail',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showInviteByEmailDialog(),
            icon: const Icon(Icons.email_outlined),
            label: const Text('Convidar por E-mail'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9D82FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPsychologistsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _psychologists.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final psychologist = _psychologists[index];
        return _buildPsychologistCard(psychologist);
      },
    );
  }
  
  Widget _buildPsychologistCard(PsychologistModel psychologist) {
    return GestureDetector(
      onTap: () => _navigateToPsychologistDetails(psychologist),
      child: Container(
        width: double.infinity, // Ocupa 100% da largura disponível
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF9D82FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  psychologist.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9D82FF),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    psychologist.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CRP: ${psychologist.crp}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    psychologist.specialization,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Ícone de seta
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToPsychologistDetails(PsychologistModel psychologist) {
    // Navegação para a tela de detalhes
    context.push('/psychologist-details', extra: psychologist);
  }
}
