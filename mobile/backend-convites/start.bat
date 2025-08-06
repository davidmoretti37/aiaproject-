@echo off
setlocal enabledelayedexpansion

echo =======================================
echo   Servidor de Convites para Psicologos
echo =======================================

REM Verificar se o Node.js está instalado
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [31mErro: Node.js nao esta instalado.[0m
    echo [33mPor favor, instale o Node.js (versao 16.x ou superior) e tente novamente.[0m
    pause
    exit /b 1
)

REM Verificar a versão do Node.js
for /f "tokens=1,2,3 delims=." %%a in ('node -v') do (
    set NODE_VERSION=%%a.%%b.%%c
    set NODE_MAJOR_VERSION=%%a
)

set NODE_MAJOR_VERSION=!NODE_MAJOR_VERSION:~1!

if !NODE_MAJOR_VERSION! LSS 16 (
    echo [31mErro: Versao do Node.js muito antiga.[0m
    echo [33mVersao atual: !NODE_VERSION![0m
    echo [33mPor favor, atualize para a versao 16.x ou superior.[0m
    pause
    exit /b 1
)

echo [32m✓ Node.js versao !NODE_VERSION! encontrado[0m

REM Verificar se as dependências estão instaladas
if not exist "node_modules" (
    echo [33mDependencias nao encontradas. Instalando...[0m
    call npm install
    
    if %ERRORLEVEL% neq 0 (
        echo [31mErro ao instalar dependencias.[0m
        pause
        exit /b 1
    )
    
    echo [32m✓ Dependencias instaladas com sucesso[0m
) else (
    echo [32m✓ Dependencias ja instaladas[0m
)

REM Verificar se o arquivo .env existe
if not exist ".env" (
    echo [33mArquivo .env nao encontrado. Criando a partir do exemplo...[0m
    
    if exist ".env.example" (
        copy .env.example .env
        echo [32m✓ Arquivo .env criado[0m
        echo [33m⚠️  IMPORTANTE: Edite o arquivo .env com suas credenciais do Supabase antes de continuar.[0m
        echo [33m   Pressione CTRL+C para cancelar e editar o arquivo, ou ENTER para continuar.[0m
        pause
    ) else (
        echo [31mErro: Arquivo .env.example nao encontrado.[0m
        pause
        exit /b 1
    )
) else (
    echo [32m✓ Arquivo .env encontrado[0m
)

REM Iniciar o servidor
echo [34mIniciando o servidor...[0m
echo [33mPressione CTRL+C para encerrar o servidor[0m
echo =======================================

REM Verificar se o nodemon está instalado para desenvolvimento
where nodemon >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [32mIniciando em modo de desenvolvimento com nodemon...[0m
    npx nodemon server.js
) else (
    echo [32mIniciando em modo normal...[0m
    node server.js
)

pause
