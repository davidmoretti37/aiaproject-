import fetch from 'node-fetch';
import dotenv from 'dotenv';

// Carregar variáveis de ambiente
dotenv.config();

// Configurações
const SERVER_URL = 'http://192.168.0.73:3000'; // Endereço do servidor backend
const TEST_EMAIL = 'teste@exemplo.com'; // Altere para um email de teste
const TEST_PATIENT_ID = '89d1b439-bd60-40e6-9c3a-0cf3168a26df'; // Altere para um ID de paciente válido

// NOTA: Este script é apenas para testar a conectividade com o servidor.
// Para um teste completo, você precisará configurar as credenciais reais do Supabase no arquivo .env

// Função para testar o endpoint de saúde
async function testHealthEndpoint() {
  try {
    console.log('🔍 Testando endpoint de saúde...');
    
    const response = await fetch(`${SERVER_URL}/health`);
    const data = await response.json();
    
    console.log('✅ Resposta do servidor:', data);
    console.log('✅ Status:', response.status);
    
    return true;
  } catch (error) {
    console.error('❌ Erro ao testar endpoint de saúde:', error.message);
    return false;
  }
}

// Função para testar o endpoint de convite
async function testInviteEndpoint() {
  try {
    console.log('\n🔍 Testando endpoint de convite...');
    console.log(`📧 Email de teste: ${TEST_EMAIL}`);
    console.log(`👤 ID do paciente: ${TEST_PATIENT_ID}`);
    
    const response = await fetch(`${SERVER_URL}/invite-psychologist`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: TEST_EMAIL,
        patient_id: TEST_PATIENT_ID,
      }),
    });
    
    const data = await response.json();
    
    console.log('✅ Resposta do servidor:', data);
    console.log('✅ Status:', response.status);
    
    if (response.ok) {
      console.log('🎉 Teste de convite bem-sucedido!');
    } else {
      console.log('⚠️ Teste de convite falhou, mas o servidor respondeu.');
    }
    
    return response.ok;
  } catch (error) {
    console.error('❌ Erro ao testar endpoint de convite:', error.message);
    return false;
  }
}

// Função principal
async function runTests() {
  console.log('🚀 Iniciando testes do servidor de convites...');
  
  // Testar endpoint de saúde
  const healthOk = await testHealthEndpoint();
  
  if (!healthOk) {
    console.error('❌ Teste de saúde falhou. Verifique se o servidor está rodando.');
    return;
  }
  
  // Testar endpoint de convite
  const inviteOk = await testInviteEndpoint();
  
  // Resumo dos testes
  console.log('\n📊 Resumo dos testes:');
  console.log(`- Endpoint de saúde: ${healthOk ? '✅ OK' : '❌ Falhou'}`);
  console.log(`- Endpoint de convite: ${inviteOk ? '✅ OK' : '❌ Falhou'}`);
  
  if (healthOk && inviteOk) {
    console.log('\n🎉 Todos os testes passaram! O servidor está funcionando corretamente.');
  } else {
    console.log('\n⚠️ Alguns testes falharam. Verifique os logs acima para mais detalhes.');
  }
}

// Executar testes
runTests().catch(error => {
  console.error('❌ Erro inesperado durante os testes:', error);
});
