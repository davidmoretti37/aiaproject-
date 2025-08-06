# C'Alma - Página Web de Fallback

Esta página é exibida quando usuários clicam em links de verificação de email mas não têm o app instalado.

## 🎯 Funcionalidades

- **Confirmação de Email**: Mostra que o email foi verificado com sucesso
- **Deep Link Automático**: Tenta abrir o app automaticamente
- **Fallback Inteligente**: Se o app não estiver instalado, mostra opções de download
- **Responsivo**: Funciona em desktop e mobile
- **Detecção de Plataforma**: Identifica Android/iOS para links corretos

## 🚀 Deploy Rápido

### Opção 1: Vercel (Recomendado)

1. **Instalar Vercel CLI:**
   ```bash
   npm i -g vercel
   ```

2. **Deploy:**
   ```bash
   cd web_fallback
   vercel --prod
   ```

3. **Configurar domínio personalizado (opcional):**
   - No dashboard do Vercel, adicionar domínio `calma-app.vercel.app`

### Opção 2: Netlify

1. **Instalar Netlify CLI:**
   ```bash
   npm i -g netlify-cli
   ```

2. **Deploy:**
   ```bash
   cd web_fallback
   netlify deploy --prod --dir .
   ```

### Opção 3: GitHub Pages

1. **Criar repositório** `calma-web-fallback`
2. **Upload dos arquivos** para o repositório
3. **Ativar GitHub Pages** nas configurações
4. **URL será:** `https://username.github.io/calma-web-fallback`

## ⚙️ Configuração no Supabase

Após o deploy, configurar no **Supabase Dashboard**:

### Authentication → URL Configuration:

```
Site URL: https://calma-app.vercel.app
Redirect URLs:
- https://calma-app.vercel.app/
- https://calma-app.vercel.app/email-confirmed
- calma://email-confirmed
```

## 🔧 Personalização

### Alterar URLs de Download:

No arquivo `index.html`, linha ~200:

```javascript
if (platform === 'android') {
    // Substituir pela URL da Play Store
    window.open('https://play.google.com/store/apps/details?id=com.calma.wellness', '_blank');
} else if (platform === 'ios') {
    // Substituir pela URL da App Store
    window.open('https://apps.apple.com/app/calma/id123456789', '_blank');
}
```

### Alterar Cores/Design:

No arquivo `index.html`, seção `<style>`:

```css
/* Gradiente principal */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

/* Cores dos botões */
.download-btn.primary {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
```

## 📱 Teste Local

Para testar localmente:

```bash
cd web_fallback
python -m http.server 8080
# ou
npx serve .
```

Acesse: `http://localhost:8080`

## 🔗 URLs de Teste

### Para desenvolvimento:
```
http://localhost:8080/?token=test&type=email
```

### Para produção:
```
https://calma-app.vercel.app/?token=abc123&type=email
```

## 📊 Analytics (Opcional)

Para adicionar Google Analytics, inserir antes do `</head>`:

```html
<!-- Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## 🛠️ Troubleshooting

### Deep Links não funcionam:
1. Verificar se o app está instalado
2. Verificar configuração no AndroidManifest.xml e Info.plist
3. Testar com `adb shell am start -W -a android.intent.action.VIEW -d "calma://email-confirmed"`

### Página não carrega:
1. Verificar se o deploy foi bem-sucedido
2. Verificar configurações de DNS (se usando domínio personalizado)
3. Verificar logs do serviço de hospedagem

### Supabase não redireciona:
1. Verificar se as URLs estão corretas no dashboard
2. Verificar se o `emailRedirectTo` está configurado no código
3. Testar com diferentes navegadores
