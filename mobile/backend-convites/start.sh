#!/bin/bash

# Script para iniciar o servidor de convites

# Cores para saída no terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}  Servidor de Convites para Psicólogos ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Verificar se o Node.js está instalado
if ! command -v node &> /dev/null; then
    echo -e "${RED}Erro: Node.js não está instalado.${NC}"
    echo -e "${YELLOW}Por favor, instale o Node.js (versão 16.x ou superior) e tente novamente.${NC}"
    exit 1
fi

# Verificar a versão do Node.js
NODE_VERSION=$(node -v | cut -d 'v' -f 2)
NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d '.' -f 1)

if [ $NODE_MAJOR_VERSION -lt 16 ]; then
    echo -e "${RED}Erro: Versão do Node.js muito antiga.${NC}"
    echo -e "${YELLOW}Versão atual: ${NODE_VERSION}${NC}"
    echo -e "${YELLOW}Por favor, atualize para a versão 16.x ou superior.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node.js versão ${NODE_VERSION} encontrado${NC}"

# Verificar se as dependências estão instaladas
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Dependências não encontradas. Instalando...${NC}"
    npm install
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Erro ao instalar dependências.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Dependências instaladas com sucesso${NC}"
else
    echo -e "${GREEN}✓ Dependências já instaladas${NC}"
fi

# Verificar se o arquivo .env existe
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Arquivo .env não encontrado. Criando a partir do exemplo...${NC}"
    
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✓ Arquivo .env criado${NC}"
        echo -e "${YELLOW}⚠️  IMPORTANTE: Edite o arquivo .env com suas credenciais do Supabase antes de continuar.${NC}"
        echo -e "${YELLOW}   Pressione CTRL+C para cancelar e editar o arquivo, ou ENTER para continuar.${NC}"
        read -p ""
    else
        echo -e "${RED}Erro: Arquivo .env.example não encontrado.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Arquivo .env encontrado${NC}"
fi

# Iniciar o servidor
echo -e "${BLUE}Iniciando o servidor...${NC}"
echo -e "${YELLOW}Pressione CTRL+C para encerrar o servidor${NC}"
echo -e "${BLUE}=======================================${NC}"

# Verificar se o nodemon está instalado para desenvolvimento
if command -v nodemon &> /dev/null; then
    echo -e "${GREEN}Iniciando em modo de desenvolvimento com nodemon...${NC}"
    npx nodemon server.js
else
    echo -e "${GREEN}Iniciando em modo normal...${NC}"
    node server.js
fi
