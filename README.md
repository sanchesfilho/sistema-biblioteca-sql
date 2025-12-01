# Sistema de Gerenciamento de Biblioteca Pública

**Desenvolvido por:** Jayme Sanches Filho  
**Instituição:** Universidade Cruzeiro do Sul  
**Disciplina:** Modelagem de Banco de Dados  
*Experiência prática*  
**Data:** 30/11/2025  

## Descrição do Projeto
Sistema completo de banco de dados para gestão de biblioteca pública desenvolvido em PostgreSQL. Implementa cadastro de acervo, controle de empréstimos, gestão de usuários, cálculo automático de multas e relatórios analíticos.

## Estrutura do Banco de Dados
- **11 Tabelas** normalizadas seguindo as formas normais 1FN, 2FN e 3FN
- **Relacionamentos** complexos (1:1; 1:0,1; 1:N; N:N) com integridade referencial
- **Chaves** primárias naturais e surrogates conforme melhor prática
- **Constraints** de validação e unicidade

## Arquivos do Projeto

### `schema.sql`
- Criação do database `biblioteca_publica` e conexão automática via meta-comando _psql_
- Definição completa do schema com tabelas, constraints e comentários
- Configuração de encoding UTF8 para suporte a caracteres especiais

### `inserts.sql` 
- Povoamento massivo com dados realistas
- 10 editoras, 10 livros, 10 autores, 10 endereços, 10 usuários
- 25 exemplares físicos, 12 empréstimos, 7 multas, 3 cargos, 4 funcionários
- Técnica avançada de resolução dinâmica de FKs via Common Table Expressions

### `selects.sql`
- 5 consultas analíticas para operação da biblioteca
- _Consulta 1_: Empréstimos ativos com detalhes de usuário e exemplar
- _Consulta 2_: Top 5 livros mais emprestados do acervo  
- _Consulta 3_: Multas pendentes com cálculo de dias em atraso
- _Consulta 4_: Análise de usuários por faixa etária e métricas de uso
- _Consulta 5_: Busca avançada por autores britânicos (2015-2020, +200 páginas)

### `updates_deletes.sql`
- Rotinas de manutenção e conformidade LGPD
- _UPDATE 1_: Acréscimo de 50% em multas pendentes com mais de 10 dias
- _UPDATE 2_: Suspensão de usuários com empréstimos ativos em atraso crítico (+20 dias)
- _UPDATE 3_: Suspensão por inadimplência prolongada (+3 meses)
- _DELETE 1_: Remoção de multas quitadas há mais de 1 ano (valor < R$50)
- _DELETE 2_: Limpeza de empréstimos finalizados há mais de 3 anos
- _DELETE 3_: Remoção de usuários inativos sem vínculos pendentes

## Pré-requisitos
- PostgreSQL 18.0 ou superior
- PgAdmin 4
- Variáveis de ambiente (PATH) configuradas para acesso via _command prompt_

## Instalação e Execução

### Configuração do Ambiente
```bash
# Verificar instalação do PostgreSQL
psql --version

# Verificar se PostgreSQL\bin está no PATH
echo %PATH% | findstr "PostgreSQL"
```
### Clonagem do Repositório
```bash
# Clonar o repositório
git clone https://github.com/sanchesfilho/sistema-biblioteca-sql.git

# Navegar até a pasta do repositório
cd sistema-biblioteca-sql

# Verificar a estrutura de arquivos do projeto
dir /B
```

### Criação do Database
```bash
# Cria database com schema completo e se conecta a ela automaticamente
psql -U postgres -d postgres -f schema.sql
```

### População das Tabelas
```bash
# Insere nas tabelas os dados de inserts.sql. 
# O terminal retornará os dados inseridos. 
# Pressione "enter" para continuar após cada conjunto de resultados.
psql -U postgres -d biblioteca_publica -f inserts.sql
```

### Execução via PgAdmin
1. Abra PgAdmin 4
2. Navegue: Servers → PostgreSQL 18 → Databases → biblioteca_publica
3. Botão direito → Query Tool
4. Cole o bloco de código desejado existentes nos arquivos `selects.sql` e `updates_deletes.sql` (e.g., `CONSULTA 1`, `UPDATE 3`)
5. Tecle F5 ou clique no botão Run para executar

## Funcionalidades Principais

### Gestão de Acervo
- Cadastro completo de livros, autores e editoras
- Controle de exemplares físicos com localização
- ISBN como chave natural padronizada

### Controle de Empréstimos
- Sistema de empréstimos e devoluções
- Cálculo automático de prazos e multas
- Status em tempo real de disponibilidade

### Gestão de Usuários
- Cadastro com validação de dados
- Sistema de categorização
- Controle de suspensões automáticas

### Conformidade e Segurança
- Implementação de princípios da LGPD com limpeza automática de dados históricos
- Criptografia avançada de senhas usando salt + hash (SHA-256)
- Proteção contra rainbow tables e ataques de pré-computação

## Características Técnicas

### Performance
- Indexação estratégica em chaves de busca frequente
- CTEs para otimização de queries complexas
- Agregações eficientes para relatórios

### Segurança
- Implementação de hash SHA-256 com salt único de 32 caracteres para credenciais de funcionários
- Validação de constraints em nível de database
- Transações ACID para operações críticas

### Manutenibilidade
- Comentários detalhados em todo o código
- Documentação inline para cada tabela e coluna

## Notas de Desenvolvimento
- Foco em boas práticas de segurança da informação, engenharia de dados e normalização
- Scripts auto-contidos com meta-comandos para automação completa do fluxo de implantação
- Compatível com PostgreSQL 18.0 e superiores