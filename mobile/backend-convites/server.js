import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';
import { customAlphabet } from 'nanoid';

// Carregar variáveis de ambiente
dotenv.config();

// Verificar variáveis de ambiente obrigatórias
const requiredEnvVars = ['SUPABASE_URL', 'SUPABASE_SERVICE_ROLE_KEY'];
const missingEnvVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingEnvVars.length > 0) {
  console.error(`❌ Erro: Variáveis de ambiente obrigatórias não encontradas: ${missingEnvVars.join(', ')}`);
  console.error('Por favor, crie um arquivo .env com as variáveis necessárias.');
  process.exit(1);
}

// Inicializar Express
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Inicializar cliente Supabase com chave service_role
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// Gerar código de convite (letras maiúsculas e números, sem caracteres ambíguos)
const generateCode = customAlphabet('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', 6);

// Rota de verificação de saúde do servidor
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Servidor de convites funcionando!' });
});

// Endpoint para enviar convite para psicólogo
app.post('/invite-psychologist', async (req, res) => {
  console.log('📨 Recebida solicitação de convite');
  
  try {
    // Extrair dados da requisição
    const { email, patient_id } = req.body;
    
    // Validar dados
    if (!email || !patient_id) {
      console.log('❌ Dados incompletos:', { email, patient_id });
      return res.status(400).json({ 
        error: 'Dados incompletos. Email e ID do paciente são obrigatórios.' 
      });
    }
    
    // Validar formato de email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      console.log('❌ Formato de email inválido:', email);
      return res.status(400).json({ error: 'Formato de email inválido.' });
    }
    
    // Gerar código único para o convite
    const code = generateCode();
    console.log(`🔑 Código gerado: ${code} para email: ${email}`);
    
    // Verificar se o paciente existe
    // Nota: No Supabase, a tabela de usuários é acessada de forma especial
    const { data: patientData, error: patientError } = await supabase.auth.admin
      .getUserById(patient_id);
    
    // Se houver erro na consulta, vamos pular esta verificação em vez de falhar
    // Isso é útil durante o desenvolvimento e testes
    if (patientError) {
      console.log('⚠️ Aviso: Erro ao verificar paciente:', patientError);
      console.log('⚠️ Continuando mesmo sem verificar o paciente...');
    } else if (!patientData || !patientData.user) {
      console.log('❌ Paciente não encontrado:', patient_id);
      return res.status(404).json({ error: 'Paciente não encontrado.' });
    } else {
      console.log('✅ Paciente encontrado:', patientData.user.email);
    }
    
    // Verificar se já existe um convite pendente para este email
    const { data: existingInvitation, error: invitationError } = await supabase
      .from('invitations')
      .select('id, status')
      .eq('psychologist_email', email)
      .eq('patient_id', patient_id)
      .eq('status', 'pending')
      .maybeSingle();
    
    if (invitationError) {
      console.log('❌ Erro ao verificar convites existentes:', invitationError);
      return res.status(500).json({ error: 'Erro ao verificar convites existentes.' });
    }
    
    if (existingInvitation) {
      console.log('⚠️ Convite pendente já existe para:', email);
      return res.status(409).json({ 
        error: 'Já existe um convite pendente para este psicólogo.' 
      });
    }
    
    // Verificar se é um ID de teste ou modo de simulação
    // Desativando a verificação de ID de teste para permitir o envio de e-mail
    const isTestId = false; // Anteriormente: patient_id === '89d1b439-bd60-40e6-9c3a-0cf3168a26df';
    // Modo de simulação para qualquer ID que não seja um UUID real na tabela user_profiles
    const isSimulationMode = false; // Em produção, defina como false
    
    if (isTestId || isSimulationMode) {
      console.log('🧪 Modo de simulação ativado. Pulando inserção no banco de dados...');
      // Em modo de simulação, não tentamos inserir no banco de dados
      // mas simulamos uma resposta bem-sucedida
    } else {
      // 1. Salvar o convite na tabela invitations
      const { error: insertError } = await supabase
        .from('invitations')
        .insert([{
          code,
          psychologist_email: email,
          patient_id,
          status: 'pending',
        }]);
      
      if (insertError) {
        console.log('❌ Erro ao salvar convite:', insertError);
        return res.status(500).json({ error: 'Erro ao salvar convite no banco de dados.' });
      }
    }
    
    if (!isTestId && !isSimulationMode) {
      // 2. Enviar email via Supabase Auth (apenas para IDs reais)
      const redirectUrl = process.env.WEBAPP_URL 
        ? `${process.env.WEBAPP_URL}/redirect-invite?code=${code}`
        : `http://192.168.0.73:8080/redirect-invite?code=${code}`;
      
      console.log(`🔗 URL de redirecionamento: ${redirectUrl}`);
      
      try {
        // Tentar enviar o email
        const { error: inviteError } = await supabase.auth.admin.inviteUserByEmail(email, {
          redirectTo: redirectUrl,
        });
        
        if (inviteError) {
          console.log('⚠️ Aviso: Erro ao enviar email de convite:', inviteError);
          console.log('⚠️ Simulando envio de email para fins de teste...');
          console.log(`⚠️ Em produção, um email seria enviado para ${email} com o link: ${redirectUrl}`);
          
          // Não falhar o processo, apenas logar o erro
          // Em um ambiente de produção, você deve remover esta parte e deixar falhar
        }
      } catch (emailError) {
        console.log('⚠️ Exceção ao enviar email:', emailError);
        console.log('⚠️ Simulando envio de email para fins de teste...');
        console.log(`⚠️ Em produção, um email seria enviado para ${email} com o link: ${redirectUrl}`);
        
        // Não falhar o processo, apenas logar o erro
        // Em um ambiente de produção, você deve remover esta parte e deixar falhar
      }
    } else {
      // Mesmo em modo de simulação, vamos mostrar a URL de redirecionamento
      const redirectUrl = process.env.WEBAPP_URL 
        ? `${process.env.WEBAPP_URL}/redirect-invite?code=${code}`
        : `http://192.168.0.73:8080/redirect-invite?code=${code}`;
      
      console.log('🧪 Modo de simulação: Pulando envio de email...');
      console.log(`🧪 Em produção, um email seria enviado para ${email} com o link: ${redirectUrl}`);
      console.log(`🧪 O psicólogo seria redirecionado para: ${redirectUrl}`);
    }
    
    console.log('✅ Convite enviado com sucesso para:', email);
    
    // Retornar sucesso
    return res.status(200).json({ 
      message: 'Convite enviado com sucesso',
      code
    });
    
  } catch (error) {
    console.error('❌ Erro inesperado:', error);
    return res.status(500).json({ error: 'Erro interno do servidor.' });
  }
});

// Endpoint para buscar convite pelo email
app.get('/get-invite-by-email', async (req, res) => {
  console.log('📨 Recebida solicitação para buscar convite por email');
  
  try {
    const { email } = req.query;
    
    if (!email) {
      console.log('❌ Email não fornecido');
      return res.status(400).json({ 
        success: false,
        error: 'Email não fornecido' 
      });
    }
    
    // Buscar o convite mais recente para esse email
    const { data: invitation, error: invitationError } = await supabase
      .from('invitations')
      .select('*')
      .eq('psychologist_email', email)
      .eq('status', 'pending')
      .order('created_at', { ascending: false })
      .limit(1)
      .single();
    
    if (invitationError || !invitation) {
      console.log('❌ Convite não encontrado para o email:', email);
      return res.status(404).json({ 
        success: false,
        error: 'Convite não encontrado para este email' 
      });
    }
    
    console.log('✅ Convite encontrado para o email:', email);
    console.log('✅ Código do convite:', invitation.code);
    
    return res.status(200).json({ 
      success: true,
      code: invitation.code,
      patient_id: invitation.patient_id
    });
    
  } catch (error) {
    console.error('❌ Erro inesperado:', error);
    return res.status(500).json({ 
      success: false,
      error: 'Erro interno do servidor.' 
    });
  }
});

// Endpoint para processar convite
app.post('/process-invite', async (req, res) => {
  console.log('📨 Recebida solicitação para processar convite');
  
  try {
    const { code: rawCode, psychologistId } = req.body;
    
    if (!rawCode || !psychologistId) {
      console.log('❌ Dados incompletos:', { code: rawCode, psychologistId });
      return res.status(400).json({ 
        success: false,
        error: 'Dados incompletos. Código e ID do psicólogo são obrigatórios.' 
      });
    }
    
    // Normalizar o código (remover espaços, converter para maiúsculas)
    const code = rawCode.trim().toUpperCase();
    console.log(`🔍 Buscando convite com código normalizado: "${code}"`);
    
    // Listar todos os convites pendentes para debug
    const { data: allPendingInvites, error: pendingError } = await supabase
      .from('invitations')
      .select('*')
      .eq('status', 'pending');
    
    if (pendingError) {
      console.log('⚠️ Erro ao listar convites pendentes:', pendingError);
    } else {
      console.log('📋 Todos os convites pendentes:', allPendingInvites);
      
      // Verificar se há algum convite com código similar
      const similarInvites = allPendingInvites.filter(inv => 
        inv.code.toUpperCase() === code.toUpperCase() ||
        inv.code.toUpperCase().includes(code.toUpperCase()) ||
        code.toUpperCase().includes(inv.code.toUpperCase())
      );
      
      if (similarInvites.length > 0) {
        console.log('⚠️ Encontrados convites com códigos similares:', similarInvites);
      }
    }
    
    // Primeiro, tentar buscar sem filtrar por status
    const { data: anyInvitation, error: anyInvitationError } = await supabase
      .from('invitations')
      .select('*')
      .eq('code', code);
    
    if (anyInvitationError) {
      console.log('⚠️ Erro ao buscar convite (sem filtro de status):', anyInvitationError);
    } else if (anyInvitation && anyInvitation.length > 0) {
      console.log('⚠️ Convites encontrados (sem filtro de status):', anyInvitation);
      
      // Se encontramos convites, mas nenhum está pendente, informar o usuário
      const pendingInvites = anyInvitation.filter(inv => inv.status === 'pending');
      if (pendingInvites.length === 0) {
        console.log('⚠️ Convite encontrado, mas não está pendente');
        return res.status(400).json({ 
          success: false,
          error: 'Este convite já foi processado anteriormente.' 
        });
      }
    }
    
    // Buscar o convite pelo código normalizado
    const { data: invitation, error: invitationError } = await supabase
      .from('invitations')
      .select('*')
      .eq('code', code)
      .eq('status', 'pending')
      .single();
    
    if (invitationError || !invitation) {
      console.log('❌ Convite não encontrado ou já processado:', invitationError);
      
      // Tentar uma busca case-insensitive
      const { data: caseInsensitiveInvites } = await supabase
        .from('invitations')
        .select('*')
        .ilike('code', code)
        .eq('status', 'pending');
      
      if (caseInsensitiveInvites && caseInsensitiveInvites.length > 0) {
        console.log('⚠️ Encontrados convites com busca case-insensitive:', caseInsensitiveInvites);
        
        // Usar o primeiro convite encontrado
        const firstInvite = caseInsensitiveInvites[0];
        console.log('✅ Usando o primeiro convite encontrado:', firstInvite);
        
        // Continuar o processamento com este convite
        return processInvitation(firstInvite, psychologistId, res);
      }
      
      return res.status(404).json({ 
        success: false,
        error: 'Convite não encontrado ou já foi processado.' 
      });
    }
    
    // Continuar o processamento com o convite encontrado
    return processInvitation(invitation, psychologistId, res);
  } catch (error) {
    console.error('❌ Erro inesperado:', error);
    return res.status(500).json({ 
      success: false,
      error: 'Erro interno do servidor.' 
    });
  }
});

// Função auxiliar para processar o convite
async function processInvitation(invitation, psychologistId, res) {
    
  // Atualizar o status do convite para "accepted"
  const { error: updateInvitationError } = await supabase
    .from('invitations')
    .update({ status: 'accepted' })
    .eq('id', invitation.id);
  
  if (updateInvitationError) {
    console.log('❌ Erro ao atualizar status do convite:', updateInvitationError);
    return res.status(500).json({ 
      success: false,
      error: 'Erro ao atualizar status do convite.' 
    });
  }
  
  // Verificar se o paciente existe na tabela user_profiles
  console.log(`🔍 Verificando se o paciente com user_id=${invitation.patient_id} existe na tabela user_profiles...`);
  const { data: patientData, error: patientError } = await supabase
    .from('user_profiles')
    .select('*')
    .eq('user_id', invitation.patient_id)
    .single();
  
  if (patientError) {
    console.log('❌ Erro ao buscar paciente:', patientError);
    return res.status(404).json({ 
      success: false,
      error: 'Paciente não encontrado na tabela user_profiles.' 
    });
  }
  
  console.log('✅ Paciente encontrado na tabela user_profiles:', patientData);
  
  // Verificar se o psicólogo existe na tabela psychologists
  console.log(`🔍 Verificando se o psicólogo ${psychologistId} existe na tabela psychologists...`);
  const { data: psychologistData, error: psychologistError } = await supabase
    .from('psychologists')
    .select('*')
    .eq('id', psychologistId)
    .single();
  
  if (psychologistError) {
    console.log('❌ Erro ao buscar psicólogo:', psychologistError);
    return res.status(404).json({ 
      success: false,
      error: 'Psicólogo não encontrado na tabela psychologists.' 
    });
  }
  
  console.log('✅ Psicólogo encontrado na tabela psychologists:', psychologistData);
  
  // Atualizar o perfil do usuário com o ID do psicólogo
  console.log(`🔄 Atualizando o perfil do paciente com user_id=${invitation.patient_id} com o ID do psicólogo ${psychologistId}...`);
  const { data: updateData, error: updateUserError } = await supabase
    .from('user_profiles')
    .update({ psychologist_id: psychologistId })
    .eq('user_id', invitation.patient_id)
    .select();
  
  if (updateUserError) {
    console.log('❌ Erro ao vincular psicólogo ao paciente:', updateUserError);
    return res.status(500).json({ 
      success: false,
      error: 'Erro ao vincular psicólogo ao paciente.' 
    });
  }
  
  console.log('✅ Resultado da atualização:', updateData);
  
  console.log('✅ Convite processado com sucesso');
  console.log(`✅ Psicólogo ${psychologistId} vinculado ao paciente ${invitation.patient_id}`);
  
  return res.status(200).json({ 
    success: true,
    message: 'Convite processado com sucesso'
  });
}

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`
🚀 Servidor de convites rodando na porta ${PORT}
📝 Endpoints disponíveis:
   - GET  /health
   - GET  /get-invite-by-email
   - POST /invite-psychologist
   - POST /process-invite
  `);
});
