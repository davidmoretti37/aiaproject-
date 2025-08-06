# C'Alma - Aplicativo de Bem-estar Mental

Aplicativo Flutter para bem-estar mental e emocional com IA conversacional.

## 🚀 Configuração do Projeto

### Pré-requisitos
- Flutter SDK (>=3.4.0)
- Node.js (para o backend)
- Android Studio / Xcode
- Conta no Supabase

### 📱 Configuração do Flutter

1. **Clone o repositório**
```bash
git clone <url-do-repositorio>
cd calmav1
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure as variáveis de ambiente**
```bash
# Copie o arquivo .env.example para .env e configure suas chaves
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais:
```env
OPENAI_API_KEY=sua_chave_openai_aqui
SUPABASE_URL=sua_url_supabase_aqui
SUPABASE_ANON_KEY=sua_chave_anonima_supabase_aqui
```

### 🤖 Configuração Android

1. **Configure as credenciais de assinatura**
```bash
# Copie o arquivo de exemplo
cp android/gradle.properties.example android/gradle.properties
```

2. **Edite `android/gradle.properties`** com suas credenciais reais:
```properties
CALMA_KEY_ALIAS=calma_alias
CALMA_KEY_PASSWORD=sua_senha_da_chave
CALMA_STORE_FILE=calma_key.jks
CALMA_STORE_PASSWORD=sua_senha_do_keystore
```

3. **Coloque seu arquivo keystore** em `android/app/calma_key.jks`

### 🍎 Configuração iOS

1. **Permissões configuradas**:
   - ✅ Microfone (para AIA)
   - ✅ Câmera (para fotos de perfil)
   - ✅ Galeria (para seleção de fotos)
   - ✅ Notificações locais

2. **Orientação**: Apenas portrait (alinhado com Android)

### 🖥️ Backend de Convites

1. **Navegue para o diretório do backend**
```bash
cd backend-convites
```

2. **Instale as dependências**
```bash
npm install
```

3. **Configure as variáveis de ambiente**
```bash
# O arquivo .env já foi criado, edite com suas credenciais
```

Edite `backend-convites/.env`:
```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_SERVICE_ROLE_KEY=sua_service_role_key_aqui
WEBAPP_URL=https://seu-app.vercel.app
PORT=3000
```

4. **Execute o servidor**
```bash
npm start
# ou para desenvolvimento
npm run dev
```

## 🔧 Comandos Úteis

### Flutter
```bash
# Executar no Android
flutter run -d android

# Executar no iOS
flutter run -d ios

# Build para release Android
flutter build apk --release

# Build para release iOS
flutter build ios --release

# Limpar cache
flutter clean && flutter pub get
```

### Backend
```bash
# Iniciar servidor
npm start

# Modo desenvolvimento (com nodemon)
npm run dev

# Testar endpoints
npm test
```

## 🚨 Problemas Conhecidos e Soluções

### iOS - Microfone não funciona
**Problema**: "Microfone não permitido" mas dialog não aparece
**Solução**: ✅ Corrigido - Adicionada `NSMicrophoneUsageDescription` no Info.plist

### Android - Credenciais expostas
**Problema**: Senhas hardcoded no build.gradle.kts
**Solução**: ✅ Corrigido - Movido para variáveis de ambiente

### Orientação inconsistente
**Problema**: iOS permitia landscape, Flutter forçava portrait
**Solução**: ✅ Corrigido - Alinhado para apenas portrait

## 📁 Estrutura do Projeto

```
calmav1/
├── lib/
│   ├── core/                 # Configurações centrais
│   ├── features/             # Features do app
│   │   ├── aia/             # IA conversacional
│   │   ├── auth/            # Autenticação
│   │   ├── profile/         # Perfil do usuário
│   │   └── ...
│   └── presentation/        # Widgets comuns
├── backend-convites/        # Backend Node.js
├── android/                 # Configurações Android
├── ios/                     # Configurações iOS
└── assets/                  # Recursos (imagens, ícones)
```

## 🔐 Segurança

- ✅ Credenciais removidas do código
- ✅ Variáveis de ambiente configuradas
- ✅ .gitignore atualizado
- ✅ Arquivos de exemplo criados

## 📝 Próximos Passos

1. **Configurar suas credenciais** nos arquivos .env
2. **Testar o microfone** no iOS após rebuild
3. **Configurar keystore** para Android release
4. **Implementar features faltantes**
5. **Remover logs de debug** para produção

## 🆘 Suporte

Se encontrar problemas:
1. Verifique se todas as variáveis de ambiente estão configuradas
2. Execute `flutter clean && flutter pub get`
3. Para iOS: delete a pasta build e rebuild
4. Para Android: verifique se o keystore está no local correto

---

**Desenvolvido pela equipe C'Alma** 🧘‍♀️
