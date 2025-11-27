-- SISTEMA DE GERENCIAMENTO DE BIBLIOTECA PÚBLICA
-- DESENVOLVIDO POR: JAYME SANCHES FILHO
-- INSTITUIÇÃO: UNIVERSIDADE CRUZEIRO DO SUL
-- DISCIPLINA: MODELAGEM DE BANCO DE DADOS
-- EXPERIÊNCIA PRÁTICA — ENTREGA 4 (IMPLEMENTAÇÃO E MANIPULAÇÃO DE DADOS)
-- DATA: 26/11/2025

-- CONSULTA 1: EMPRÉSTIMOS ATIVOS (COM DETALHES DE USUÁRIO E EXEMPLAR)
SELECT 
    e.id AS cod_emprestimo,              -- IDENTIFICADOR ÚNICO DO EMPRÉSTIMO
    u.nome AS usuario,                   -- NOME COMPLETO DO USUÁRIO
    u.cart_num,                          -- NÚMERO IDENTIFICADOR DA CARTEIRINHA
    l.titulo AS livro,                   -- TÍTULO DA OBRA EMPRESTADA
    ex.cod AS exemplar,                  -- CÓDIGO DO EXEMPLAR FÍSICO
    e.data AS data_emprestimo,           -- DATA DE REALIZAÇÃO DO EMPRÉSTIMO
    e.dev_prev AS previsao_devolucao     -- DATA PREVISTA PARA DEVOLUÇÃO
FROM emprestimo e                        -- TABELA BASE: REGISTROS DE EMPRÉSTIMOS
JOIN usuario u ON e.cart_num_usuario = u.cart_num   -- JOIN: VINCULA EMPRÉSTIMO AO USUÁRIO
JOIN exemplar ex ON e.cod_exemplar = ex.cod         -- JOIN: VINCULA EMPRÉSTIMO AO EXEMPLAR
JOIN livro l ON ex.id_livro = l.id                  -- JOIN: VINCULA EXEMPLAR AO LIVRO
WHERE e.status = true                   -- FILTRO: EMPRÉSTIMOS ATIVOS (NÃO DEVOLVIDOS)
ORDER BY e.dev_prev ASC;                -- ORDENAÇÃO: DEVOLUÇÃO MAIS PRÓXIMA PRIMEIRO

-- CONSULTA 2: TOP 5 LIVROS MAIS EMPRESTADOS
SELECT 
    l.titulo,                           -- TÍTULO DA OBRA
    ed.nome AS editora,                 -- NOME DA EDITORA
    COUNT(e.id) AS total_emprestimos    -- CONTAGEM DE EMPRÉSTIMOS POR LIVRO
FROM livro l                            -- TABELA BASE: CATÁLOGO DE LIVROS
JOIN editora ed ON l.id_editora = ed.id                 -- JOIN: VINCULA LIVRO À EDITORA
JOIN exemplar ex ON ex.id_livro = l.id                  -- JOIN: VINCULA LIVRO AOS EXEMPLARES
JOIN emprestimo e ON e.cod_exemplar = ex.cod            -- JOIN: VINCULA EXEMPLARES A EMPRÉSTIMOS
GROUP BY l.id, l.titulo, ed.nome        -- AGREGAÇÃO: AGRUPA POR LIVRO E EDITORA
ORDER BY total_emprestimos DESC         -- ORDENAÇÃO: MAIOR NÚMERO DE EMPRÉSTIMOS PRIMEIRO
LIMIT 5;                                -- LIMITE: APENAS OS 5 PRIMEIROS RESULTADOS

-- CONSULTA 3: MULTAS PENDENTES COM DETALHES DE ATRASO
SELECT 
    u.nome AS usuario,                                                  -- NOME DO USUÁRIO MULTADO
    u.cart_num,                                                         -- IDENTIFICADOR DA CARTEIRINHA
    l.titulo AS livro,                                                  -- TÍTULO DO LIVRO RELACIONADO
    m.valor AS multa,                                                   -- VALOR ORIGINAL DA MULTA
    m.data_venc,                                                        -- DATA DE VENCIMENTO DA MULTA
    (CURRENT_DATE - m.data_venc) AS dias_atraso,                        -- CÁLCULO: DIAS EM ATRASO
    m.valor AS valor_total                                              -- VALOR TOTAL (SEM JUROS)
FROM multa m                                                            -- TABELA BASE: REGISTROS DE MULTAS
JOIN emprestimo emp ON m.id_emprestimo = emp.id                         -- JOIN: VINCULA MULTA AO EMPRÉSTIMO
JOIN usuario u ON emp.cart_num_usuario = u.cart_num                     -- JOIN: VINCULA EMPRÉSTIMO AO USUÁRIO
JOIN exemplar ex ON emp.cod_exemplar = ex.cod                           -- JOIN: VINCULA EMPRÉSTIMO AO EXEMPLAR
JOIN livro l ON ex.id_livro = l.id                                      -- JOIN: VINCULA EXEMPLAR AO LIVRO
WHERE m.status = false                                                  -- FILTRO: MULTAS NÃO PAGAS
AND m.data_venc < CURRENT_DATE                                          -- FILTRO: MULTAS VENCIDAS
ORDER BY m.data_venc ASC;                                               -- ORDENAÇÃO: VENCIMENTO MAIS ANTIGO PRIMEIRO

-- CONSULTA 4: ANÁLISE DE USUÁRIOS POR FAIXA ETÁRIA
SELECT 
    CASE    -- EXPRESSÃO CONDICIONAL: CLASSIFICAÇÃO POR FAIXA ETÁRIA
        WHEN DATE_PART('year', AGE(data_nasc)) < 18 THEN 'Jovem (até 17)'
        WHEN DATE_PART('year', AGE(data_nasc)) BETWEEN 18 AND 30 THEN 'Adulto Jovem (18-30)'
        WHEN DATE_PART('year', AGE(data_nasc)) BETWEEN 31 AND 50 THEN 'Adulto (31-50)'
        ELSE 'Sênior (51+)'
    END AS faixa_etaria,               -- COLUNA: FAIXA ETÁRIA CALCULADA
    COUNT(*) AS total_usuarios,        -- CONTAGEM: TOTAL DE USUÁRIOS POR FAIXA
    COUNT(e.id) AS total_emprestimos,  -- CONTAGEM: EMPRÉSTIMOS POR FAIXA
    ROUND(AVG(COALESCE(e.dev_real, CURRENT_DATE) - e.data), 1) AS dias_medio_com_livro   -- CÁLCULO: MÉDIA DE DIAS DE EMPRÉSTIMO
FROM usuario u                         -- TABELA BASE: USUÁRIOS CADASTRADOS
LEFT JOIN emprestimo e ON u.cart_num = e.cart_num_usuario        -- LEFT JOIN: INCLUI USUÁRIOS SEM EMPRÉSTIMOS
WHERE u.status = true                     -- FILTRO: APENAS USUÁRIOS ATIVOS
GROUP BY faixa_etaria                     -- AGREGAÇÃO: AGRUPA POR FAIXA ETÁRIA
ORDER BY total_emprestimos DESC;          -- ORDENAÇÃO: MAIOR NÚMERO DE EMPRÉSTIMOS PRIMEIRO

-- CONSULTA 5: BUSCA AVANÇADA DE LIVROS POR CRITÉRIOS ESPECÍFICOS
SELECT 
    l.titulo,                           -- TÍTULO DO LIVRO
    a.nome AS nome_autor,               -- NOME COMPLETO DO AUTOR
    a.nacionalidade,                    -- NACIONALIDADE DO AUTOR
    l.ano_pub,                          -- ANO DE PUBLICAÇÃO
    l.paginas,                          -- QUANTIDADE DE PÁGINAS
    ed.nome AS nome_editora,            -- NOME DA EDITORA
    ex.cod AS cod_exemplar_disponivel,  -- CÓDIGO DO EXEMPLAR DISPONÍVEL
    ex.local AS localizacao             -- LOCALIZAÇÃO FÍSICA NA BIBLIOTECA
FROM livro l                            -- TABELA BASE: CATÁLOGO DE LIVROS
JOIN livro_autor la ON l.id = la.id_livro   -- JOIN: RELACIONAMENTO N:N LIVRO-AUTOR
JOIN autor a ON la.id_autor = a.id          -- JOIN: VINCULA AO AUTOR
JOIN editora ed ON l.id_editora = ed.id     -- JOIN: VINCULA À EDITORA
JOIN exemplar ex ON l.id = ex.id_livro      -- JOIN: VINCULA AOS EXEMPLARES
WHERE a.nacionalidade = 'Reino Unido'       -- FILTRO: AUTORES BRITÂNICOS
AND l.ano_pub BETWEEN 2015 AND 2020         -- FILTRO: INTERVALO DE ANOS
AND ex.status = true                        -- FILTRO: EXEMPLARES DISPONÍVEIS
AND l.paginas > 200                         -- FILTRO: LIVROS COM MAIS DE 200 PÁGINAS
ORDER BY l.ano_pub DESC, l.titulo ASC;      -- ORDENAÇÃO: ANO DECRESCENTE, TÍTULO CRESCENTE