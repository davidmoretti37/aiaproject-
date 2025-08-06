import 'package:dartz/dartz.dart';
import '../models/user_model.dart';

/// AuthRepository - Interface para o repositório de autenticação
///
/// Define os métodos necessários para gerenciar a autenticação de usuários.
abstract class AuthRepository {
  /// Métodos de autenticação
  
  /// Registra um novo usuário
  ///
  /// Retorna um [Either] com um erro [String] ou um [UserModel] em caso de sucesso
  /// 
  /// Se [rememberMe] for true, o usuário permanecerá logado mesmo após fechar o aplicativo
  Future<Either<String, UserModel>> signUp(String email, String password, String name, {bool rememberMe = false});
  
  /// Autentica um usuário existente
  ///
  /// Retorna um [Either] com um erro [String] ou um [UserModel] em caso de sucesso
  /// 
  /// Se [rememberMe] for true, o usuário permanecerá logado mesmo após fechar o aplicativo
  Future<Either<String, UserModel>> signIn(String email, String password, {bool rememberMe = false});
  
  /// Encerra a sessão do usuário atual
  Future<void> signOut();
  
  /// Solicita redefinição de senha para o email fornecido
  ///
  /// Retorna um [Either] com um erro [String] ou void em caso de sucesso
  Future<Either<String, void>> resetPassword(String email);
  
  /// Redefine a senha usando código de verificação
  ///
  /// Retorna um [Either] com um erro [String] ou void em caso de sucesso
  Future<Either<String, void>> resetPasswordWithCode(String email, String code, String newPassword);
  
  /// Métodos para gerenciar o usuário atual
  
  /// Obtém o usuário atual, se houver
  ///
  /// Retorna null se não houver usuário autenticado
  Future<UserModel?> getCurrentUser();
  
  /// Stream que emite o usuário atual sempre que há mudanças
  Stream<UserModel?> get userChanges;
  
  /// Métodos para gerenciar o perfil
  
  /// Atualiza o perfil do usuário
  ///
  /// Retorna um [Either] com um erro [String] ou um [UserModel] atualizado em caso de sucesso
  Future<Either<String, UserModel>> updateProfile(UserModel user);
  
  /// Atualiza a senha do usuário
  ///
  /// Retorna um [Either] com um erro [String] ou void em caso de sucesso
  Future<Either<String, void>> updatePassword(String currentPassword, String newPassword);
  
  /// Métodos para verificação de email
  
  /// Envia um email de verificação para o usuário atual
  ///
  /// Retorna um [Either] com um erro [String] ou void em caso de sucesso
  Future<Either<String, void>> sendEmailVerification();
  
  /// Verifica se o email do usuário atual está verificado
  ///
  /// Retorna true se o email estiver verificado, false caso contrário
  Future<bool> isEmailVerified();
}
