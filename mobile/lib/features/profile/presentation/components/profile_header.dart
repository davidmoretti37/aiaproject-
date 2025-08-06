import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/features/auth/domain/models/user_model.dart';
import 'package:calma_flutter/features/profile/domain/models/user_profile_model.dart';
import 'package:calma_flutter/features/profile/services/profile_photo_service.dart';
import 'package:calma_flutter/features/profile/presentation/viewmodels/user_profile_viewmodel.dart';

class ProfileHeader extends StatefulWidget {
  final UserProfileModel? profile;
  final UserModel? user;
  final VoidCallback onEditPressed;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.user,
    required this.onEditPressed,
  });
  
  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  late final ProfilePhotoService _photoService;
  late final UserProfileViewModel _profileViewModel;
  UserProfileModel? _localProfile; // Variável local para armazenar uma cópia do perfil
  
  @override
  void initState() {
    super.initState();
    _photoService = getIt<ProfilePhotoService>();
    _profileViewModel = getIt<UserProfileViewModel>();
    _localProfile = widget.profile; // Inicializa com o perfil do widget
  }
  
  @override
  void didUpdateWidget(ProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza a cópia local quando o widget é atualizado
    if (widget.profile != oldWidget.profile) {
      _localProfile = widget.profile;
    }
  }
  
  // Getter para obter o perfil atual (local ou do widget)
  UserProfileModel? get _currentProfile => _localProfile ?? widget.profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Foto de perfil
          Stack(
            children: [
              _currentProfile?.profilePhotoCache != null
              ? Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C89B8).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: MemoryImage(_currentProfile!.profilePhotoCache!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : _currentProfile?.profilePhotoPath != null
              ? FutureBuilder<Uint8List?>(
                  future: _loadImageFromStorage(_currentProfile!.profilePhotoPath!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && 
                        snapshot.hasData && 
                        snapshot.data != null) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9C89B8).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: DecorationImage(
                            image: MemoryImage(snapshot.data!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF9C89B8),
                              Color(0xFFB8A9D9),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9C89B8).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: snapshot.connectionState == ConnectionState.waiting
                              ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _getInitials(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    }
                  },
                )
              : Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF9C89B8),
                        Color(0xFFB8A9D9),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C89B8).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showPhotoOptions(context),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Nome do usuário
          Text(
            _getDisplayName(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Email do usuário
          if (widget.user?.email != null)
            Text(
              widget.user!.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Botão de editar perfil
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onEditPressed,
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
              ),
              label: const Text('Editar Perfil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF9C89B8),
                side: const BorderSide(
                  color: Color(0xFF9C89B8),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    if (_currentProfile?.preferredName != null && _currentProfile!.preferredName.isNotEmpty) {
      final names = _currentProfile!.preferredName.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else {
        return _currentProfile!.preferredName.substring(0, 1).toUpperCase();
      }
    } else if (widget.user?.email != null) {
      return widget.user!.email.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  String _getDisplayName() {
    // Prioridade 1: Nome preferido do perfil (do onboarding)
    if (_currentProfile?.preferredName != null && _currentProfile!.preferredName.isNotEmpty) {
      return _currentProfile!.preferredName;
    }
    
    // Prioridade 2: Nome do email (mais amigável que "Usuário")
    if (widget.user?.email != null) {
      final emailName = widget.user!.email.split('@')[0];
      // Capitalizar primeira letra e substituir pontos/underscores por espaços
      final cleanName = emailName.replaceAll('.', ' ').replaceAll('_', ' ');
      final formattedName = cleanName.split(' ').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : word
      ).join(' ');
      return formattedName;
    }
    
    // Prioridade 3: Fallback mais amigável
    return 'Bem-vindo!';
  }

  // Chave global para acessar o Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  void _showPhotoOptions(BuildContext parentContext) {
    if (widget.profile == null) return;
    
    final photoService = getIt<ProfilePhotoService>();
    final profileViewModel = getIt<UserProfileViewModel>();
    
    // Armazenar o contexto do Scaffold para uso posterior
    final scaffoldContext = parentContext;
    
    showModalBottomSheet(
      context: scaffoldContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Alterar Foto de Perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar Foto'),
              onTap: () async {
                // Usar o contexto do bottomSheet para fechar
                Navigator.of(bottomSheetContext).pop();
                // Passar o contexto do Scaffold para as operações
                await _pickImageFromCamera(scaffoldContext, photoService, profileViewModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da Galeria'),
              onTap: () async {
                // Usar o contexto do bottomSheet para fechar
                Navigator.of(bottomSheetContext).pop();
                // Passar o contexto do Scaffold para as operações
                await _pickImageFromGallery(scaffoldContext, photoService, profileViewModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remover Foto'),
              onTap: () async {
                // Usar o contexto do bottomSheet para fechar
                Navigator.of(bottomSheetContext).pop();
                // Passar o contexto do Scaffold para as operações
                await _removeProfilePhoto(scaffoldContext, photoService, profileViewModel);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickImageFromCamera(
    BuildContext context, 
    ProfilePhotoService photoService,
    UserProfileViewModel profileViewModel
  ) async {
    // Armazenar uma referência ao contexto
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Verificar se o widget ainda está montado antes de mostrar o diálogo
      if (!mounted) return;
      
      // Mostrar indicador de carregamento
      _showLoadingDialog(context, 'Abrindo câmera...');
      
      // Selecionar imagem da câmera
      final imageFile = await photoService.pickImageFromCamera();
      
      // Verificar se o widget ainda está montado antes de fechar o diálogo
      if (!mounted) return;
      
      // Fechar indicador de carregamento
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          // Ignora erro se o diálogo já foi fechado
        }
      }
      
      if (imageFile != null && mounted) {
        await _processSelectedImage(context, imageFile, photoService, profileViewModel);
      }
    } catch (e) {
      // Verificar se o widget ainda está montado antes de fechar o diálogo
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          // Ignora erro se o diálogo já foi fechado
        }
      }
      
      // Verificar se o widget ainda está montado antes de mostrar o snackbar
      if (mounted) {
        _showErrorSnackBar(context, 'Erro ao acessar a câmera');
      }
    }
  }
  
  Future<void> _pickImageFromGallery(
    BuildContext context, 
    ProfilePhotoService photoService,
    UserProfileViewModel profileViewModel
  ) async {
    // Armazenar uma referência ao contexto
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Verificar se o widget ainda está montado antes de mostrar o diálogo
      if (!mounted) return;
      
      // Mostrar indicador de carregamento
      _showLoadingDialog(context, 'Abrindo galeria...');
      
      // Selecionar imagem da galeria
      final imageFile = await photoService.pickImageFromGallery();
      
      // Verificar se o widget ainda está montado antes de fechar o diálogo
      if (!mounted) return;
      
      // Fechar indicador de carregamento
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          // Ignora erro se o diálogo já foi fechado
        }
      }
      
      if (imageFile != null && mounted) {
        await _processSelectedImage(context, imageFile, photoService, profileViewModel);
      }
    } catch (e) {
      // Verificar se o widget ainda está montado antes de fechar o diálogo
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          // Ignora erro se o diálogo já foi fechado
        }
      }
      
      // Verificar se o widget ainda está montado antes de mostrar o snackbar
      if (mounted) {
        _showErrorSnackBar(context, 'Erro ao acessar a galeria');
      }
    }
  }
  
  Future<void> _processSelectedImage(
    BuildContext context,
    File imageFile,
    ProfilePhotoService photoService,
    UserProfileViewModel profileViewModel
  ) async {
    // Armazenar uma referência ao contexto
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Verificar se o widget ainda está montado antes de mostrar o diálogo
      if (!mounted) return;
      
      // Mostrar indicador de carregamento
      _showLoadingDialog(context, 'Salvando foto...');
      
      // Atualizar a foto de perfil
      final success = await photoService.updateProfilePhoto(widget.profile!, imageFile);
      
      // Verificar se o widget ainda está montado antes de fechar o diálogo
      if (!mounted) return;
      
      // Fechar indicador de carregamento
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          // Ignora erro se o diálogo já foi fechado
        }
      }
      
      if (success && mounted) {
        // Recarregar o perfil para exibir a nova foto
        await profileViewModel.loadProfile(widget.profile!.userId);
        
        // Mostrar mensagem de sucesso
        _showSuccessSnackBar(context, 'Foto de perfil atualizada com sucesso');
      } else if (mounted) {
        _showErrorSnackBar(context, 'Erro ao salvar a foto de perfil');
      }
    } catch (e) {
      // Verificar se o widget ainda está montado antes de fechar o diálogo
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          // Ignora erro se o diálogo já foi fechado
        }
      }
      
      // Verificar se o widget ainda está montado antes de mostrar o snackbar
      if (mounted) {
        _showErrorSnackBar(context, 'Erro ao processar a imagem');
      }
    }
  }
  
  /// Nome do bucket para armazenar fotos de perfil
  static const String _bucketName = 'profiles';
  
  /// Carrega a imagem do Storage do Supabase
  Future<Uint8List?> _loadImageFromStorage(String path) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.storage.from(_bucketName).download(path);
      return response;
    } catch (e) {
      debugPrint('❌ Erro ao carregar imagem do Storage: $e');
      return null;
    }
  }
  
  Future<void> _removeProfilePhoto(
    BuildContext context, 
    ProfilePhotoService photoService,
    UserProfileViewModel profileViewModel
  ) async {
    if (widget.profile?.profilePhotoPath == null && widget.profile?.profilePhotoCache == null) {
      if (mounted) {
        _showInfoSnackBar(context, 'Você não tem uma foto de perfil para remover');
      }
      return;
    }
    
    // Armazenar uma referência ao contexto
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      // Verificar se o widget ainda está montado antes de mostrar o diálogo
      if (!mounted) return;
      
      // Mostrar indicador de carregamento
      _showLoadingDialog(context, 'Removendo foto...');
      
      // Remover a foto de perfil
      final success = await photoService.removeProfilePhoto(widget.profile!);
      
      // Verificar se o widget ainda está montado antes de fechar o diálogo
      if (!mounted) return;
      
      // Fechar indicador de carregamento
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          // Ignora erro se o diálogo já foi fechado
        }
      }
      
      // Atualizar o estado local imediatamente, antes mesmo da resposta do servidor
      if (mounted && widget.profile != null) {
        setState(() {
          // Criar uma cópia local do perfil sem a foto
          _localProfile = widget.profile!.copyWith(
            profilePhotoPath: null,
            profilePhotoCache: null,
          );
        });
      }
      
      if (success && mounted) {
        // Recarregar o perfil para atualizar a UI com os dados do servidor
        await profileViewModel.loadProfile(widget.profile!.userId);
        
        // Mostrar mensagem de sucesso
        _showSuccessSnackBar(context, 'Foto de perfil removida com sucesso');
      } else if (mounted) {
        _showErrorSnackBar(context, 'Erro ao remover a foto de perfil');
      }
    } catch (e) {
      // Verificar se o widget ainda está montado antes de fechar o diálogo
      if (mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          // Ignora erro se o diálogo já foi fechado
        }
      }
      
      // Verificar se o widget ainda está montado antes de mostrar o snackbar
      if (mounted) {
        _showErrorSnackBar(context, 'Erro ao remover a foto de perfil');
      }
    }
  }
  
  void _showLoadingDialog(BuildContext context, String message) {
    // Encontrar o contexto do Scaffold mais próximo
    final navigatorContext = Navigator.of(context, rootNavigator: true).context;
    
    showDialog(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C89B8)),
            ),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF9C89B8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
