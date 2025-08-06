import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/features/profile/domain/models/user_profile_model.dart';
import 'package:calma_flutter/features/profile/domain/repositories/user_profile_repository.dart';

/// Serviço para gerenciar fotos de perfil
class ProfilePhotoService {
  final UserProfileRepository _profileRepository;
  final ImagePicker _imagePicker = ImagePicker();
  
  ProfilePhotoService(this._profileRepository);
  
  /// Seleciona uma imagem da câmera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [ProfilePhotoService] Erro ao capturar imagem: $e');
      return null;
    }
  }
  
  /// Seleciona uma imagem da galeria
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [ProfilePhotoService] Erro ao selecionar imagem: $e');
      return null;
    }
  }
  
  /// Nome do bucket para armazenar fotos de perfil
  static const String _bucketName = 'profiles';

  /// Atualiza a foto de perfil do usuário
  Future<bool> updateProfilePhoto(UserProfileModel profile, File imageFile) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Ler a imagem como bytes para cache temporário
      final Uint8List bytes = await imageFile.readAsBytes();
      
      // Gerar um nome de arquivo único mais curto
      final String fileExt = path.extension(imageFile.path).replaceAll('.', '');
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7); // Usar apenas os últimos dígitos
      final String fileName = 'user_${profile.id.substring(0, 8)}_$timestamp.$fileExt';
      
      // Fazer upload da imagem para o Storage
      await supabase.storage.from(_bucketName).uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
      
      // Se o usuário já tinha uma foto, remover a antiga do Storage
      if (profile.profilePhotoPath != null) {
        try {
          final oldFileName = profile.profilePhotoPath!;
          await supabase.storage.from(_bucketName).remove([oldFileName]);
        } catch (e) {
          // Ignora erro se a foto antiga não existir
          debugPrint('⚠️ [ProfilePhotoService] Aviso ao remover foto antiga: $e');
        }
      }
      
      // Criar uma cópia do perfil com o novo caminho da foto e cache temporário
      final updatedProfile = profile.copyWith(
        profilePhotoPath: fileName,
        profilePhotoCache: bytes,
      );
      
      // Atualizar o perfil no banco de dados
      final result = await _profileRepository.updateProfile(updatedProfile);
      
      return result != null;
    } catch (e) {
      debugPrint('❌ [ProfilePhotoService] Erro ao atualizar foto de perfil: $e');
      return false;
    }
  }
  
  /// Remove a foto de perfil do usuário
  Future<bool> removeProfilePhoto(UserProfileModel profile) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Se o usuário tinha uma foto, remover do Storage
      if (profile.profilePhotoPath != null) {
        try {
          final fileName = profile.profilePhotoPath!;
          await supabase.storage.from(_bucketName).remove([fileName]);
        } catch (e) {
          // Ignora erro se a foto não existir
          debugPrint('⚠️ [ProfilePhotoService] Aviso ao remover foto: $e');
        }
      }
      
      // Criar uma cópia do perfil sem a foto
      final updatedProfile = profile.copyWith(
        profilePhotoPath: null,
        profilePhotoCache: null,
      );
      
      // Atualizar o perfil no banco de dados
      final result = await _profileRepository.updateProfile(updatedProfile);
      
      return result != null;
    } catch (e) {
      debugPrint('❌ [ProfilePhotoService] Erro ao remover foto de perfil: $e');
      return false;
    }
  }
}
