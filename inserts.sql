-- SISTEMA DE GERENCIAMENTO DE BIBLIOTECA PÚBLICA
-- DESENVOLVIDO POR: JAYME SANCHES FILHO
-- INSTITUIÇÃO: UNIVERSIDADE CRUZEIRO DO SUL
-- DISCIPLINA: MODELAGEM DE BANCO DE DADOS
-- EXPERIÊNCIA PRÁTICA — ENTREGA 4 (IMPLEMENTAÇÃO E MANIPULAÇÃO DE DADOS)
-- DATA: 26/11/2025

-- ** NOTA TÉCNICA: USO DE CTE PARA IDs **
-- EM SISTEMAS REAIS, IDs SÃO GERADOS AUTOMATICAMENTE, PODENDO VARIAR ENTRE AMBIENTES.
-- EM VEZ DE ASSUMIR VALORES FIXOS (HARDCODING), 
-- ESTE CÓDIGO UTILIZA CTEs (COMMON TABLE EXPRESSIONS) PARA RESOLVER DINAMICAMENTE AS CHAVES ESTRANGEIRAS,
-- GARANTINDO A INTEGRIDADE DOS RELACIONAMENTOS MESMO QUE IDs VARIEM ENTRE AMBIENTES

-- POVOAMENTO: TABELA "editora"
INSERT INTO editora (nome, email) VALUES
('Intrínseca', 'contato@intrinseca.com.br'),
('Companhia das Letras', 'vendas@companhiadasletras.com.br'),
('Editora Aleph', 'atendimento@aleph.com.br'),
('Martins Fontes', 'contato@martinsfontes.com.br'),
('Editora Rocco', 'contato@rocco.com.br'),
('Folhas de Relva Edições', 'contato@folhasderelva.com.br'),
('Scipione', 'contato@scipione.com.br'),
('Principis', 'contato@principis.com.br'),
('Biblioteca Azul', 'contato@bibliotecaazul.com.br'),
('Ecclesiae', 'contato@ecclesiae.com.br');

-- POVOAMENTO: TABELA "livro" (OTIMIZADA; EMPREGO DE CTE)
WITH editora_lookup AS (                                                 -- MAPEIA EDITORAS PARA RESOLUÇÃO DE FKs
    SELECT nome, id FROM editora                                         -- CAPTURA RELAÇÃO NOME→ID PARA JOINS
)
INSERT INTO livro (isbn, titulo, ano_pub, paginas, id_editora)           -- INSERE NA TABELA DESTINO
SELECT                                                                   -- CONSTRÓI RESULTSET PARA INSERÇÃO                                                                  
    dataset.isbn,                                                        -- ISBN (CHAVE NATURAL)
    dataset.titulo,                                                      -- TÍTULO DA OBRA
    dataset.ano_pub,                                                     -- ANO DE PUBLICAÇÃO
    dataset.paginas,                                                     -- QUANTIDADE DE PÁGINAS
    e.id                                                                 -- ID EDITORA (RESOLVIDO VIA JOIN)
FROM (VALUES                                                             -- DADOS EMBUTIDOS PARA INSERÇÃO
    ('9788580576467', 'Uma Breve História do Tempo', 2015, 256, 'Intrínseca'),
    ('9788535933925', 'Sapiens: Uma breve história da humanidade', 2020, 472, 'Companhia das Letras'),
    ('9786586064360', 'Solaris', 2021, 320, 'Editora Aleph'),
    ('9788533613409', 'O Senhor dos Anéis', 2001, 1211, 'Martins Fontes'),
    ('9788532530844', 'Harry Potter e as Relíquias da Morte', 2017, 512, 'Editora Rocco'),
    ('9786580672943', 'Cicatrizes e Esperanças', 2025, 204, 'Folhas de Relva Edições'),
    ('9788526234284', 'Ivanhoé', 1998, 112, 'Scipione'),
    ('9786555522266', '1984', 2021, 336, 'Principis'),
    ('9788525056009', 'Admirável Mundo Novo', 2014, 312, 'Biblioteca Azul'),
    ('9788584910670', 'O Espírito da Música', 2017, 200, 'Ecclesiae')
) AS dataset(isbn, titulo, ano_pub, paginas, nome_editora)               -- ALIAS PARA TABELA VIRTUAL
JOIN editora_lookup e ON e.nome = dataset.nome_editora;                  -- JOIN PARA RESOLUÇÃO DA FK

-- POVOAMENTO: TABELA "autor"
INSERT INTO autor (nome, nacionalidade) VALUES
('Stephen Hawking', 'Reino Unido'),
('Yuval Noah Harari', 'Israel'),
('Stanisław Lem', 'Polônia'),
('J. R. R. Tolkien', 'Reino Unido'),
('J. K. Rowling', 'Reino Unido'),
('Ercilia Fligelman', 'Brasil'),
('Walter Scott', 'Reino Unido'),
('George Orwell', 'Reino Unido'),
('Aldous Huxley', 'Reino Unido'),
('Papa Bento XVI', 'Alemanha');

-- POVOAMENTO: TABELA "livro_autor" (OTIMIZADA; EMPREGO DE CTE)
WITH livro_lookup AS (                              -- CTE PARA MAPEAMENTO ISBN→ID LIVRO
    SELECT isbn, id FROM livro                      -- CAPTURA RELAÇÃO CHAVE NATURAL→SURROGATE
),
autor_lookup AS (                                   -- CTE PARA MAPEAMENTO NOME→ID AUTOR  
    SELECT nome, id FROM autor                      -- CAPTURA RELAÇÃO CHAVE NATURAL→SURROGATE
)
INSERT INTO livro_autor (id_livro, id_autor)          -- TABELA DE RELACIONAMENTO N:N
SELECT                                                -- CONSTRÓI RESULTSET DE RELACIONAMENTOS
    l.id,                                             -- ID LIVRO (RESOLVIDO VIA CTE livro_lookup)
    a.id                                              -- ID AUTOR (RESOLVIDO VIA CTE autor_lookup)
FROM (VALUES                                          -- DADOS EMBUTIDOS: RELACIONAMENTOS LIVRO-AUTOR
    ('9788580576467', 'Stephen Hawking'),             -- UMA BREVE HISTÓRIA DO TEMPO → STEPHEN HAWKING
    ('9788535933925', 'Yuval Noah Harari'),           -- SAPIENS → YUVAL NOAH HARARI
    ('9786586064360', 'Stanisław Lem'),               -- SOLARIS → STANISŁAW LEM
    ('9788533613409', 'J. R. R. Tolkien'),            -- O SENHOR DOS ANÉIS → J. R. R. TOLKIEN
    ('9788532530844', 'J. K. Rowling'),               -- HARRY POTTER → J. K. ROWLING
    ('9786580672943', 'Ercilia Fligelman'),           -- CICATRIZES E ESPERANÇAS → ERCILIA FLIGELMAN
    ('9788526234284', 'Walter Scott'),                -- IVANHOÉ → WALTER SCOTT
    ('9786555522266', 'George Orwell'),               -- 1984 → GEORGE ORWELL
    ('9788525056009', 'Aldous Huxley'),               -- ADMIRÁVEL MUNDO NOVO → ALDOUS HUXLEY
    ('9788584910670', 'Papa Bento XVI')               -- O ESPÍRITO DA MÚSICA → PAPA BENTO XVI
) AS dataset(isbn_livro, nome_autor)                  -- ALIAS TABELA VIRTUAL
JOIN livro_lookup l ON l.isbn = dataset.isbn_livro    -- JOIN PARA RESOLUÇÃO FK LIVRO
JOIN autor_lookup a ON a.nome = dataset.nome_autor;   -- JOIN PARA RESOLUÇÃO FK AUTOR

-- POVOAMENTO DA TABELA "endereco"
INSERT INTO endereco (rua, numero, bairro, cidade, uf, complemento) VALUES
('Rua das Flores', '123', 'Centro', 'São Paulo', 'SP', 'Apto 101'),
('Avenida Paulista', '456', 'Bela Vista', 'São Paulo', 'SP', 'Sala 201'),
('Rua Augusta', '789', 'Consolação', 'São Paulo', 'SP', 'Apto 305'),
('Alameda Santos', '321', 'Cerqueira César', 'São Paulo', 'SP', 'Conjunto 45'),
('Praça da Sé', '654', 'Sé', 'São Paulo', 'SP', 'Andar 3'),
('Rua da Consolação', '112', 'Consolação', 'São Paulo', 'SP', 'Apto 302'),
('Avenida Brigadeiro Faria Lima', '950', 'Itaim Bibi', 'São Paulo', 'SP', 'Bloco B'),
('Rua Oscar Freire', '77', 'Jardins', 'São Paulo', 'SP', 'Apto 501'),
('Travessa Doutor Mário Vinagre', '210', 'Perdizes', 'São Paulo', 'SP', 'Casa 2'),
('Rua Haddock Lobo', '350', 'Cerqueira César', 'São Paulo', 'SP', 'Sala 304');

-- POVOAMENTO DA TABELA "usuario" (OTIMIZADA; EMPREGO DE CTE)
WITH endereco_lookup AS (                                                         -- CTE PARA MAPEAMENTO RUA/NÚMERO→ID
    SELECT id, rua, numero FROM endereco                                          -- CAPTURA RELAÇÃO RUA/NÚMERO→ID
)
INSERT INTO usuario (cart_num, status, nome, email, tel, data_nasc, id_endereco)  -- INSERE USUÁRIOS
SELECT                                                                            -- CONSTRÓI RESULTSET
    dataset.cart_num,                                                             -- CARTEIRINHA (CHAVE NATURAL)
    dataset.status,                                                               -- STATUS ATIVO/INATIVO
    dataset.nome,                                                                 -- NOME COMPLETO
    dataset.email,                                                                -- E-MAIL
    dataset.tel,                                                                  -- TELEFONE
    dataset.data_nasc,                                                            -- DATA NASCIMENTO
    e.id                                                                          -- ID ENDEREÇO (RESOLVIDO VIA JOIN)
FROM (VALUES                                                                      -- DADOS EMBUTIDOS: USUÁRIOS
    ('USR20250001', true,  'João Velloso',     'joao.velloso@email.com',     '5511999981234', DATE '1990-05-15', 'Rua das Flores', '123'),
    ('USR20250002', true,  'Marina Cascudo',   'marina.cascudo@email.com',   '5511888875678', DATE '1985-08-22', 'Avenida Paulista', '456'),
    ('USR20250003', true,  'Pedro Ventosa',    'pedro.ventosa@email.com',    '5511777769012', DATE '1992-12-10', 'Rua Augusta', '789'),
    ('USR20250004', false, 'Ana Figueira',     'ana.figueira@email.com',     '5511666653456', DATE '1988-03-30', 'Alameda Santos', '321'),
    ('USR20250005', true,  'Carlos Sereno',    'carlos.sereno@email.com',    '5511555547890', DATE '1995-07-18', 'Praça da Sé', '654'),
    ('USR20250006', true,  'Bruno Castanho',   'bruno.castanho@email.com',   '5511999345678', DATE '1991-09-12', 'Rua da Consolação', '112'),
    ('USR20250007', true,  'Laura Ventura',    'laura.ventura@email.com',    '5511987654321', DATE '1993-11-03', 'Avenida Brigadeiro Faria Lima', '950'),
    ('USR20250008', false, 'Felipe Guimarães', 'felipe.guimaraes@email.com', '5511976543210', DATE '1989-04-27', 'Rua Oscar Freire', '77'),
    ('USR20250009', true,  'Renata Silveira',  'renata.silveira@email.com',  '5511965432109', DATE '1994-02-19', 'Travessa Doutor Mário Vinagre', '210'),
    ('USR20250010', true,  'Eduardo Fontana',  'eduardo.fontana@email.com',  '5511954321098', DATE '1990-12-01', 'Rua Haddock Lobo', '350')
) AS dataset(cart_num, status, nome, email, tel, data_nasc, rua_endereco, numero_endereco)       -- ALIAS TABELA VIRTUAL
JOIN endereco_lookup e ON e.rua = dataset.rua_endereco AND e.numero = dataset.numero_endereco;   -- JOIN PARA RESOLUÇÃO FK ENDEREÇO

-- POVOAMENTO: TABELA "exemplar" (OTIMIZADA; EMPREGO DE CTE)
WITH livro_lookup AS (                        -- CTE PARA MAPEAMENTO ISBN→ID
    SELECT isbn, id, ano_pub FROM livro       -- CAPTURA RELAÇÃO ISBN→ID + ANO PUBLICAÇÃO
)
INSERT INTO exemplar (cod, status, data_incl, local, id_livro)  -- INSERE EXEMPLARES
SELECT                                                          -- CONSTRÓI RESULTSET
    dataset.cod,                                                -- CÓDIGO EXEMPLAR (CHAVE NATURAL)
    dataset.status,                                             -- STATUS DISPONÍVEL/EMPRESTADO
    dataset.data_incl,                                          -- DATA INCLUSÃO NO ACERVO
    dataset.local,                                              -- LOCALIZAÇÃO FÍSICA
    l.id                                                        -- ID LIVRO (RESOLVIDO VIA JOIN)
FROM (VALUES                                                    -- DADOS EMBUTIDOS: EXEMPLARES
    -- UMA BREVE HISTÓRIA DO TEMPO (2015)
    ('LIV9788580576467E001', false, DATE '2015-03-15', 'Estante A, Prateleira 1', '9788580576467'),
    ('LIV9788580576467E002', true, DATE '2015-03-15', 'Estante A, Prateleira 1', '9788580576467'),
    ('LIV9788580576467E003', false, DATE '2016-08-22', 'Estante A, Prateleira 1', '9788580576467'),
    
    -- SAPIENS (2020)
    ('LIV9788535933925E001', false, DATE '2020-02-10', 'Estante B, Prateleira 2', '9788535933925'),
    ('LIV9788535933925E002', false, DATE '2020-02-10', 'Estante B, Prateleira 2', '9788535933925'),
    ('LIV9788535933925E003', true, DATE '2020-02-10', 'Estante B, Prateleira 2', '9788535933925'),
    ('LIV9788535933925E004', false, DATE '2021-05-18', 'Estante B, Prateleira 2', '9788535933925'),
    ('LIV9788535933925E005', true, DATE '2021-05-18', 'Estante B, Prateleira 2', '9788535933925'),
    
    -- SOLARIS (2021)
    ('LIV9786586064360E001', false, DATE '2021-11-30', 'Estante C, Prateleira 1', '9786586064360'),
    ('LIV9786586064360E002', true, DATE '2022-03-12', 'Estante C, Prateleira 1', '9786586064360'),
    
    -- O SENHOR DOS ANÉIS (2001)
    ('LIV9788533613409E001', false, DATE '2002-01-20', 'Estante A, Prateleira 3', '9788533613409'),
    ('LIV9788533613409E002', true, DATE '2002-01-20', 'Estante A, Prateleira 3', '9788533613409'),
    ('LIV9788533613409E003', false, DATE '2005-09-08', 'Estante A, Prateleira 3', '9788533613409'),
    ('LIV9788533613409E004', true, DATE '2005-09-08', 'Estante A, Prateleira 3', '9788533613409'),
    
    -- HARRY POTTER E AS RELÍQUIAS DA MORTE (2017)
    ('LIV9788532530844E001', false, DATE '2017-12-05', 'Estante D, Prateleira 2', '9788532530844'),
    ('LIV9788532530844E002', true, DATE '2017-12-05', 'Estante D, Prateleira 2', '9788532530844'),
    ('LIV9788532530844E003', false, DATE '2018-06-15', 'Estante D, Prateleira 2', '9788532530844'),
    ('LIV9788532530844E004', true, DATE '2019-11-22', 'Estante D, Prateleira 2', '9788532530844'),
    
    -- CICATRIZES E ESPERANÇAS (2025)
    ('LIV9786580672943E001', true, DATE '2025-02-28', 'Estante E, Prateleira 4', '9786580672943'),
    
    -- IVANHOÉ (1998) - EXEMPLARES MAIS ANTIGOS
    ('LIV9788526234284E001', true, DATE '1998-10-15', 'Estante F, Prateleira 5', '9788526234284'),
    ('LIV9788526234284E002', false, DATE '2003-04-10', 'Estante F, Prateleira 5', '9788526234284'),
    
    -- 1984 (2021)
    ('LIV9786555522266E001', false, DATE '2021-09-05', 'Estante C, Prateleira 2', '9786555522266'),
    ('LIV9786555522266E002', true, DATE '2021-09-05', 'Estante C, Prateleira 2', '9786555522266'),
    ('LIV9786555522266E003', false, DATE '2022-02-14', 'Estante C, Prateleira 2', '9786555522266'),
    
    -- ADMIRÁVEL MUNDO NOVO (2014)
    ('LIV9788525056009E001', true, DATE '2014-07-20', 'Estante D, Prateleira 4', '9788525056009'),
    ('LIV9788525056009E002', false, DATE '2014-07-20', 'Estante D, Prateleira 4', '9788525056009'),
    ('LIV9788525056009E003', true, DATE '2016-03-30', 'Estante D, Prateleira 4', '9788525056009'),
    
    -- O ESPÍRITO DA MÚSICA (2017)
    ('LIV9788584910670E001', true, DATE '2017-10-10', 'Estante E, Prateleira 1', '9788584910670')
) AS dataset(cod, status, data_incl, local, isbn_livro)                                 -- ALIAS TABELA VIRTUAL
JOIN livro_lookup l ON l.isbn = dataset.isbn_livro;                                     -- JOIN PARA RESOLUÇÃO FK LIVRO

-- POVOAMENTO: TABELA "emprestimo"
INSERT INTO emprestimo (status, data, dev_prev, dev_real, cart_num_usuario, cod_exemplar) VALUES   -- INSERE EMPRESTIMOS
(true, DATE '2025-11-10', DATE '2025-11-24', NULL, 'USR20250001', 'LIV9788535933925E001'),
(true, DATE '2025-11-12', DATE '2025-11-26', NULL, 'USR20250002', 'LIV9788533613409E001'),
(true, DATE '2025-11-15', DATE '2025-11-29', NULL, 'USR20250003', 'LIV9788532530844E001'),
(true, DATE '2025-11-18', DATE '2025-12-02', NULL, 'USR20250005', 'LIV9786555522266E001'),
(false, DATE '2025-10-28', DATE '2025-11-11', DATE '2025-11-10', 'USR20250006', 'LIV9788580576467E001'),
(false, DATE '2025-10-30', DATE '2025-11-13', DATE '2025-11-12', 'USR20250007', 'LIV9788535933925E004'),
(false, DATE '2025-11-02', DATE '2025-11-16', DATE '2025-11-15', 'USR20250009', 'LIV9788525056009E002'),
(false, DATE '2025-10-25', DATE '2025-11-08', DATE '2025-11-12', 'USR20250001', 'LIV9788533613409E003'),
(false, DATE '2025-10-29', DATE '2025-11-12', DATE '2025-11-15', 'USR20250003', 'LIV9786555522266E003'),
(false, DATE '2025-11-01', DATE '2025-11-15', DATE '2025-11-18', 'USR20250010', 'LIV9788526234284E002'),
(false, DATE '2025-11-05', DATE '2025-11-19', DATE '2025-11-22', 'USR20250002', 'LIV9788532530844E003'),
(false, DATE '2025-11-08', DATE '2025-11-22', DATE '2025-11-25', 'USR20250007', 'LIV9788535933925E002');

-- POVOAMENTO: TABELA "multa" (OTIMIZADA; EMPREGO DE CTE)
WITH emprestimo_lookup AS (                                             -- CTE PARA MAPEAMENTO EMPRÉSTIMOS→ID
    SELECT id, cart_num_usuario, cod_exemplar FROM emprestimo           -- CAPTURA RELAÇÃO USUÁRIO/EXEMPLAR→ID
)
INSERT INTO multa (status, valor, data_venc, data_pag, id_emprestimo)   -- INSERE MULTAS
SELECT                                                                  -- CONSTRÓI RESULTSET
    dataset.status,                                                     -- STATUS PAGA/PENDENTE
    dataset.valor,                                                      -- VALOR DA MULTA
    dataset.data_venc,                                                  -- DATA VENCIMENTO
    dataset.data_pag,                                                   -- DATA PAGAMENTO (NULL SE PENDENTE)
    e.id                                                                -- ID EMPRÉSTIMO (RESOLVIDO VIA JOIN)
FROM (VALUES                                                            -- DADOS EMBUTIDOS: MULTAS
    (true, 12.00, DATE '2025-11-13', DATE '2025-11-14', 'USR20250001', 'LIV9788533613409E003'),   -- MULTA PAGA: USUÁRIO 01, EXEMPLAR 3409E003
    (true, 18.00, DATE '2025-11-16', DATE '2025-11-17', 'USR20250003', 'LIV9786555522266E003'),   -- MULTA PAGA: USUÁRIO 03, EXEMPLAR 2266E003
    (true, 24.00, DATE '2025-11-20', DATE '2025-11-21', 'USR20250010', 'LIV9788526234284E002'),   -- MULTA PAGA: USUÁRIO 10, EXEMPLAR 4284E002
    (true, 30.00, DATE '2025-11-23', DATE '2025-11-25', 'USR20250002', 'LIV9788532530844E003'),   -- MULTA PAGA: USUÁRIO 02, EXEMPLAR 0844E003
    (true, 18.00, DATE '2025-11-25', DATE '2025-11-25', 'USR20250007', 'LIV9788535933925E002'),   -- MULTA PAGA: USUÁRIO 07, EXEMPLAR 3925E002
    (false, 12.00, DATE '2025-11-25', NULL, 'USR20250001', 'LIV9788535933925E001'),          -- MULTA PENDENTE: USUÁRIO 01, EXEMPLAR 3925E001
    (false, 6.00, DATE '2025-11-26', NULL, 'USR20250002', 'LIV9788533613409E001')            -- MULTA PENDENTE: USUÁRIO 02, EXEMPLAR 3409E001
) AS dataset(status, valor, data_venc, data_pag, cart_num_usuario, cod_exemplar)        -- ALIAS TABELA VIRTUAL
JOIN emprestimo_lookup e ON e.cart_num_usuario = dataset.cart_num_usuario               -- JOIN PARA RESOLUÇÃO FK USUÁRIO
                      AND e.cod_exemplar = dataset.cod_exemplar;                        -- JOIN PARA RESOLUÇÃO FK EXEMPLAR

-- POVOAMENTO: TABELA "cargo"
INSERT INTO cargo (status, nome, descricao, nivel_acesso) VALUES                                          -- INSERE CARGOS
(true, 'Administrador', 'Gerencia sistema e cadastros, configura regras', 3),                             -- ADMIN: ACESSO TOTAL
(true, 'Bibliotecário', 'Gerencia acervo, empréstimos e atendimento', 2),                                 -- BIBLIOTECÁRIO: ACESSO INTERMEDIÁRIO
(true, 'Estagiário', 'Cadastra livros/usuários, monitora devoluções/multas, auxilia no atendimento', 1);  -- ESTAGIÁRIO: ACESSO BÁSICO

-- POVOAMENTO: TABELA "funcionario" (OTIMIZADA; EMPREGO DE CTE)
WITH cargo_lookup AS (                                                   -- CTE PARA MAPEAMENTO CARGO→ID
    SELECT nome, id FROM cargo                                           -- CAPTURA RELAÇÃO NOME→ID PARA JOINS
)
INSERT INTO funcionario (status, nome, email, login, password_salt, password_hash, id_cargo)  -- INSERE FUNCIONÁRIOS
SELECT                                                                                        -- CONSTRÓI RESULTSET
    dataset.status,                                                                           -- STATUS ATIVO/INATIVO
    dataset.nome,                                                                             -- NOME COMPLETO
    dataset.email,                                                                            -- E-MAIL INSTITUCIONAL
    dataset.login,                                                                            -- LOGIN DE ACESSO
    dataset.password_salt,                                                                    -- SALT DA SENHA
    dataset.password_hash,                                                                    -- HASH DA SENHA
    c.id                                                                                      -- ID CARGO (RESOLVIDO VIA JOIN)
FROM (VALUES                                                                                  -- DADOS EMBUTIDOS: FUNCIONÁRIOS
    (true, 'Roberto Alves', 'roberto.alves@biblioteca.com', 'roberto.alves',
     'b7f93a1c5e', '2a6c3dbb186b1e984c4419a5e7f3d28d9f7ce9371e72e51808f4743d56e2a91c', 'Administrador'),
    
    (true, 'Fernanda Venturini', 'fernanda.venturini@biblioteca.com', 'fernanda.venturini',
     'e4a97b3c22', '5c93a8bd1237eab4d691a92c58d2047f83610a6f39b7f7e46b29f5bd3e1289fa', 'Bibliotecário'),
     
    (true, 'Thiago Galhardo', 'thiago.galhardo@biblioteca.com', 'thiago.galhardo',
     '9c51ad3e88', '1f8b5a7d35ac403fd418e2c3d6bba90ea7d92bd56e41c873ea2457b62012c9f8', 'Estagiário'),
    
    (true, 'Carolina Montebello', 'carolina.montebello@biblioteca.com', 'carolina.montebello',
     'a8f3c9d27e', 'a74b215f3796fe82a3f8c4df4d928b7e8ab98fb2f421b31d9c873f67b03c6bbd', 'Estagiário')
) AS dataset(status, nome, email, login, password_salt, password_hash, nome_cargo)            -- ALIAS TABELA VIRTUAL
JOIN cargo_lookup c ON c.nome = dataset.nome_cargo;                                           -- JOIN PARA RESOLUÇÃO FK CARGO