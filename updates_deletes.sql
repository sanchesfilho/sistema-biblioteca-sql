-- SISTEMA DE GERENCIAMENTO DE BIBLIOTECA PÚBLICA
-- DESENVOLVIDO POR: JAYME SANCHES FILHO
-- INSTITUIÇÃO: UNIVERSIDADE CRUZEIRO DO SUL
-- DISCIPLINA: MODELAGEM DE BANCO DE DADOS
-- EXPERIÊNCIA PRÁTICA — ENTREGA 4 (IMPLEMENTAÇÃO E MANIPULAÇÃO DE DADOS)
-- DATA: 26/11/2025

-- =============================================
-- COMANDOS "UPDATE"
-- =============================================

-- UPDATE 1: REAJUSTE DE VALOR DE MULTA PARA ATRASOS CRÍTICOS
UPDATE multa                                                         -- ATUALIZA TABELA DE MULTAS
SET valor = valor * 1.50                                             -- APLICA ACRÉSCIMO DE 50% NO VALOR
WHERE status = false                                                 -- FILTRA MULTAS PENDENTES
AND data_venc < CURRENT_DATE - INTERVAL '10 days'                    -- ATRASOS SUPERIORES A 10 DIAS
AND valor > 0;                                                       -- MULTAS COM VALOR POSITIVO

-- UPDATE 2: SUSPENSÃO DE USUÁRIOS COM ATRASO CRÍTICO DE DEVOLUÇÃO
UPDATE usuario u                                                     -- ATUALIZA TABELA DE USUÁRIOS
SET status = false                                                   -- DEFINE STATUS COMO INATIVO
WHERE EXISTS (                                                       -- VERIFICA EXISTÊNCIA DE EMPRÉSTIMOS EM CONDIÇÕES CRÍTICAS
    SELECT 1                                                         -- PROJEÇÃO OTIMIZADA PARA VERIFICAÇÃO
    FROM emprestimo e                                                -- TABELA DE EMPRÉSTIMOS
    JOIN multa m ON e.id = m.id_emprestimo                           -- RELACIONAMENTO COM MULTAS
    WHERE e.cart_num_usuario = u.cart_num                            -- CORRELAÇÃO COM USUÁRIO ATUAL
    AND e.status = true                                              -- EMPRÉSTIMOS ATIVOS
    AND e.dev_prev < CURRENT_DATE - INTERVAL '20 days'               -- ATRASO SUPERIOR A 20 DIAS
    AND m.status = false                                             -- MULTAS NÃO QUITADAS
    AND m.data_venc < CURRENT_DATE                                   -- MULTAS VENCIDAS
    AND u.status = true                                              -- USUÁRIOS ATIVOS
);

-- UPDATE 3: SUSPENSÃO POR INADIMPLÊNCIA PROLONGADA
UPDATE usuario u                                                     -- ATUALIZA TABELA DE USUÁRIOS
SET status = false                                                   -- DEFINE STATUS COMO INATIVO
WHERE EXISTS (                                                       -- VERIFICA EXISTÊNCIA DE MULTAS EM ATRASO PROLONGADO
    SELECT 1                                                         -- PROJEÇÃO OTIMIZADA PARA VERIFICAÇÃO
    FROM emprestimo e                                                -- TABELA DE EMPRÉSTIMOS
    JOIN multa m ON e.id = m.id_emprestimo                           -- RELACIONAMENTO COM MULTAS
    WHERE e.cart_num_usuario = u.cart_num                            -- CORRELAÇÃO COM USUÁRIO ATUAL
    AND m.status = false                                             -- MULTAS PENDENTES
    AND m.data_venc < CURRENT_DATE - INTERVAL '3 months'             -- VENCIMENTO SUPERIOR A 3 MESES
    AND u.status = true                                              -- USUÁRIOS ATIVOS
    AND m.valor > 0                                                  -- MULTAS COM VALOR SIGNIFICATIVO
);

-- =============================================
-- COMANDOS "DELETE"
-- =============================================

-- DELETE 1: PURGA DE REGISTROS DE MULTAS ANTIGAS (PRINCÍPIO DA MINIMIZAÇÃO - LGPD)
DELETE FROM multa                                                    -- REMOVE DA TABELA DE MULTAS
WHERE status = true                                                  -- MULTAS QUITADAS
AND data_pag < CURRENT_DATE - INTERVAL '1 year'                      -- PAGAMENTO ANTERIOR A 1 ANO
AND valor < 50;                                                      -- VALOR INFERIOR A R$50

-- DELETE 2: LIMPEZA DE HISTÓRICO DE EMPRÉSTIMOS (PRINCÍPIO DA MINIMIZAÇÃO - LGPD)
DELETE FROM emprestimo e                                             -- REMOVE DA TABELA DE EMPRÉSTIMOS
WHERE e.status = false                                               -- EMPRÉSTIMOS FINALIZADOS
AND e.dev_real IS NOT NULL                                           -- DEVOLUÇÃO REGISTRADA
AND e.dev_real < CURRENT_DATE - INTERVAL '1 year'                    -- DEVOLUÇÃO ANTERIOR A 1 ANO
AND NOT EXISTS (                                                     -- VERIFICA AUSÊNCIA DE MULTAS PENDENTES
    SELECT 1                                                         -- PROJEÇÃO OTIMIZADA PARA VERIFICAÇÃO
    FROM multa m                                                     -- TABELA DE MULTAS
    WHERE m.id_emprestimo = e.id                                     -- CORRELAÇÃO COM EMPRÉSTIMO ATUAL
    AND m.status = false                                             -- MULTAS NÃO QUITADAS
);

-- DELETE 3: REMOÇÃO DE USUÁRIOS INATIVOS (PRINCÍPIO DA MINIMIZAÇÃO - LGPD)
DELETE FROM usuario u                                                -- REMOVE DA TABELA DE USUÁRIOS
WHERE u.status = false                                               -- USUÁRIOS INATIVOS
AND NOT EXISTS (                                                     -- VERIFICA AUSÊNCIA DE EMPRÉSTIMOS ATIVOS
    SELECT 1                                                         -- PROJEÇÃO OTIMIZADA PARA VERIFICAÇÃO
    FROM emprestimo emp                                              -- TABELA DE EMPRÉSTIMOS
    WHERE emp.cart_num_usuario = u.cart_num                          -- CORRELAÇÃO COM USUÁRIO ATUAL
    AND emp.status = true                                            -- EMPRÉSTIMOS ATIVOS
)
AND NOT EXISTS (                                                     -- VERIFICA AUSÊNCIA DE MULTAS PENDENTES
    SELECT 1                                                         -- PROJEÇÃO OTIMIZADA PARA VERIFICAÇÃO
    FROM emprestimo e                                                -- TABELA DE EMPRÉSTIMOS
    JOIN multa m ON e.id = m.id_emprestimo                           -- RELACIONAMENTO COM MULTAS
    WHERE e.cart_num_usuario = u.cart_num                            -- CORRELAÇÃO COM USUÁRIO ATUAL
    AND m.status = false                                             -- MULTAS PENDENTES
)
AND NOT EXISTS (                                                     -- VERIFICA AUSÊNCIA DE ATIVIDADE RECENTE
    SELECT 1                                                         -- PROJEÇÃO OTIMIZADA PARA VERIFICAÇÃO
    FROM emprestimo e                                                -- TABELA DE EMPRÉSTIMOS
    WHERE e.cart_num_usuario = u.cart_num                            -- CORRELAÇÃO COM USUÁRIO ATUAL
    AND e.data > CURRENT_DATE - INTERVAL '1 year'                    -- ATIVIDADE NOS ÚLTIMOS 12 MESES
);