-- ** Database generated with pgModeler (PostgreSQL Database Modeler).
-- ** pgModeler version: 1.2.2
-- ** PostgreSQL version: 18.0
-- ** Project Site: pgmodeler.io
-- ** Model Author: Jayme Sanches Filho

-- object: biblioteca_publica | type: DATABASE --

-- ** EXECUÇÃO VIA TERMINAL (CONTÉM META-COMANDOS PSQL) **

-- META-COMANDO PSQL
-- DEFINE ENCODING DO CLIENTE PARA UTF8
-- GARANTE CORRETA INTERPRETAÇÃO DE CARACTERES ESPECIAIS (ACENTOS, Ç, ETC)
\encoding UTF8

CREATE DATABASE biblioteca_publica;
-- ddl-end --
COMMENT ON DATABASE biblioteca_publica IS E'Sistema integrado para gestão de biblioteca pública.\nGerencia acervo, processa empréstimos e devoluções, controla multas por atraso.';
-- ddl-end --

-- META-COMANDO PSQL
-- CONECTA À DATABASE RECÉM-CRIADA ANTES DE CRIAR AS TABELAS
-- SEM ISSO, AS TABELAS SERIAM CRIADAS NA DATABASE PADRÃO (posgres)
-- PERMITE A CRIAÇÃO DA DATABASE E TABELAS COM UM ÚNICO SCRIPT
\connect biblioteca_publica

SET search_path TO pg_catalog,public;
-- ddl-end --

-- object: public.usuario | type: TABLE --
-- DROP TABLE IF EXISTS public.usuario CASCADE;
CREATE TABLE public.usuario (
	cart_num varchar(20) NOT NULL,
	status boolean NOT NULL,
	nome varchar(100) NOT NULL,
	email varchar(100),
	tel varchar(20) NOT NULL,
	data_nasc date NOT NULL,
	id_endereco integer,
	CONSTRAINT usuario_pk PRIMARY KEY (cart_num)
);
-- ddl-end --
COMMENT ON TABLE public.usuario IS E'Cadastro de usuários da biblioteca.';
-- ddl-end --
COMMENT ON COLUMN public.usuario.cart_num IS E'Número da carteirinha do usuário.\nPadrão: [USR] + [ANO] + [NÚMERO]\n(e.g., USR20250001)';
-- ddl-end --
COMMENT ON COLUMN public.usuario.status IS E'Status da carteirinha. \nTRUE = ativa;\nFALSE = cancelada.';
-- ddl-end --
COMMENT ON COLUMN public.usuario.nome IS E'Nome completo do usuário.';
-- ddl-end --
COMMENT ON COLUMN public.usuario.email IS E'Endereço de e-mail do usuário.';
-- ddl-end --
COMMENT ON COLUMN public.usuario.tel IS E'Número de telefone de contato do usuário.\nPadrão: [COD. PAÍS] + [DDD] + [NÚMERO]\n(e.g., 551199999-1234)';
-- ddl-end --
COMMENT ON COLUMN public.usuario.data_nasc IS E'Data de nascimento do usuário.';
-- ddl-end --
ALTER TABLE public.usuario OWNER TO postgres;
-- ddl-end --

-- object: public.livro | type: TABLE --
-- DROP TABLE IF EXISTS public.livro CASCADE;
CREATE TABLE public.livro (
	id serial NOT NULL,
	isbn varchar(13) NOT NULL,
	titulo varchar(200) NOT NULL,
	ano_pub integer NOT NULL,
	paginas integer NOT NULL,
	id_editora integer,
	CONSTRAINT livro_pk PRIMARY KEY (id),
	CONSTRAINT isbn_uq UNIQUE (isbn)
);
-- ddl-end --
COMMENT ON TABLE public.livro IS E'Cadastro das obras do acervo.\nContém dados bibliográficos essenciais.';
-- ddl-end --
COMMENT ON COLUMN public.livro.id IS E'Identificador único do livro.';
-- ddl-end --
COMMENT ON COLUMN public.livro.isbn IS E'Código ISBN de 13 dígitos. \nPadronizado, formato internacional fixo.\nPode indicar edições diferentes de um mesmo livro, não servindo como PK.';
-- ddl-end --
COMMENT ON COLUMN public.livro.titulo IS E'Título da obra.';
-- ddl-end --
COMMENT ON COLUMN public.livro.ano_pub IS E'Ano de publicação da obra.';
-- ddl-end --
COMMENT ON COLUMN public.livro.paginas IS E'Número de páginas do exemplar.';
-- ddl-end --
COMMENT ON CONSTRAINT isbn_uq ON public.livro IS E'ISBNs são sempre códigos únicos.';
-- ddl-end --
ALTER TABLE public.livro OWNER TO postgres;
-- ddl-end --

-- object: public.exemplar | type: TABLE --
-- DROP TABLE IF EXISTS public.exemplar CASCADE;
CREATE TABLE public.exemplar (
	cod varchar(20) NOT NULL,
	status boolean NOT NULL,
	data_incl date,
	local varchar(100) NOT NULL,
	id_livro integer,
	CONSTRAINT exemplar_pk PRIMARY KEY (cod)
);
-- ddl-end --
COMMENT ON TABLE public.exemplar IS E'Cadastro das unidades físicas dos livros.\nGerencia disponibilidade e localização dos exemplares.';
-- ddl-end --
COMMENT ON COLUMN public.exemplar.cod IS E'Código único do exemplar.\nPadrão: [LIV]+[ISBN]+[E]+[NÚMERO]. \n(e.g., LIV9788582850350E001)';
-- ddl-end --
COMMENT ON COLUMN public.exemplar.status IS E'Status do exemplar. \nTRUE = disponível;\nFALSE = emprestado.';
-- ddl-end --
COMMENT ON COLUMN public.exemplar.data_incl IS E'Data de inclusão do exemplar no acervo da biblioteca.';
-- ddl-end --
COMMENT ON COLUMN public.exemplar.local IS E'Localização física do exemplar na biblioteca.\n(estante, prateleira, setor)';
-- ddl-end --
ALTER TABLE public.exemplar OWNER TO postgres;
-- ddl-end --

-- object: public.emprestimo | type: TABLE --
-- DROP TABLE IF EXISTS public.emprestimo CASCADE;
CREATE TABLE public.emprestimo (
	id serial NOT NULL,
	status boolean NOT NULL,
	data date NOT NULL,
	dev_prev date NOT NULL,
	dev_real date,
	cart_num_usuario varchar(20),
	cod_exemplar varchar(20),
	CONSTRAINT emprestimo_pk PRIMARY KEY (id)
);
-- ddl-end --
COMMENT ON TABLE public.emprestimo IS E'Empréstimos de exemplares aos usuários. \nControla prazos, devoluções e situação dos empréstimos.';
-- ddl-end --
COMMENT ON COLUMN public.emprestimo.id IS E'Identificador único do empréstimo.';
-- ddl-end --
COMMENT ON COLUMN public.emprestimo.status IS E'Status do empréstimo. \nTRUE = ativo;\nFALSE = finalizado.';
-- ddl-end --
COMMENT ON COLUMN public.emprestimo.data IS E'Data do empréstimo';
-- ddl-end --
COMMENT ON COLUMN public.emprestimo.dev_prev IS E'Data de devolução prevista \n(calculada a partir da data de empréstimo).';
-- ddl-end --
COMMENT ON COLUMN public.emprestimo.dev_real IS E'Data de devolução real \n(preenchida apenas quando o exemplar é devolvido).';
-- ddl-end --
ALTER TABLE public.emprestimo OWNER TO postgres;
-- ddl-end --

-- object: public.multa | type: TABLE --
-- DROP TABLE IF EXISTS public.multa CASCADE;
CREATE TABLE public.multa (
	id serial NOT NULL,
	status boolean NOT NULL,
	valor numeric(10,2) NOT NULL,
	data_venc date NOT NULL,
	data_pag date,
	id_emprestimo integer,
	CONSTRAINT multa_pk PRIMARY KEY (id)
);
-- ddl-end --
COMMENT ON TABLE public.multa IS E'Multas aplicadas por atraso na devolução de exemplares. \nControla valores, status de pagamento e prazos.';
-- ddl-end --
COMMENT ON COLUMN public.multa.id IS E'Identificador único da multa.';
-- ddl-end --
COMMENT ON COLUMN public.multa.status IS E'Status da multa. \nTRUE = paga;\nFALSE = pendente.';
-- ddl-end --
COMMENT ON COLUMN public.multa.valor IS E'Valor da multa calculado com base na taxa diária e dias de atraso.';
-- ddl-end --
COMMENT ON COLUMN public.multa.data_venc IS E'Data de vencimento da multa.';
-- ddl-end --
COMMENT ON COLUMN public.multa.data_pag IS E'Data em que a multa foi paga.\n(Preenchida apenas quando a multa é paga) \n(NULL se ainda pendente)';
-- ddl-end --
ALTER TABLE public.multa OWNER TO postgres;
-- ddl-end --

-- object: public.funcionario | type: TABLE --
-- DROP TABLE IF EXISTS public.funcionario CASCADE;
CREATE TABLE public.funcionario (
	id serial NOT NULL,
	status boolean NOT NULL,
	nome varchar(100) NOT NULL,
	email varchar(100) NOT NULL,
	login varchar(50) NOT NULL,
	password_salt char(32) NOT NULL,
	password_hash char(64) NOT NULL,
	id_cargo integer,
	CONSTRAINT funcionario_pk PRIMARY KEY (id),
	CONSTRAINT login_uq UNIQUE (login),
	CONSTRAINT email_uq UNIQUE (email)
);
-- ddl-end --
COMMENT ON TABLE public.funcionario IS E'Cadastro dos funcionários da biblioteca com seus dados de acesso ao sistema e vinculação aos cargos correspondentes';
-- ddl-end --
COMMENT ON COLUMN public.funcionario.id IS E'Identificador único do funcionário.';
-- ddl-end --
COMMENT ON COLUMN public.funcionario.status IS E'Status do funcionário. \nTRUE = ativo;\nFALSE = inativo.';
-- ddl-end --
COMMENT ON COLUMN public.funcionario.nome IS E'Nome completo do funcionário.';
-- ddl-end --
COMMENT ON COLUMN public.funcionario.email IS E'E-mail institucional do funcionário.';
-- ddl-end --
COMMENT ON COLUMN public.funcionario.login IS E'Login de acesso ao sistema.';
-- ddl-end --
COMMENT ON COLUMN public.funcionario.password_salt IS E'Valor aleatório único aplicado ao hash.\nProtege contra rainbow tables e pré-computação.';
-- ddl-end --
COMMENT ON COLUMN public.funcionario.password_hash IS E'Hash seguro da senha (Bcrypt/Argon2), com salt.\n(Irreversível)';
-- ddl-end --
ALTER TABLE public.funcionario OWNER TO postgres;
-- ddl-end --

-- object: public.cargo | type: TABLE --
-- DROP TABLE IF EXISTS public.cargo CASCADE;
CREATE TABLE public.cargo (
	id serial NOT NULL,
	status boolean NOT NULL,
	nome varchar(50) NOT NULL,
	descricao varchar(200) NOT NULL,
	nivel_acesso integer NOT NULL,
	CONSTRAINT cargo_pk PRIMARY KEY (id),
	CONSTRAINT nome_uq UNIQUE (nome)
);
-- ddl-end --
COMMENT ON TABLE public.cargo IS E'Define os papéis, funções e níveis de acesso dos funcionários da biblioteca.';
-- ddl-end --
COMMENT ON COLUMN public.cargo.id IS E'Identificador único do cargo.';
-- ddl-end --
COMMENT ON COLUMN public.cargo.status IS E'Status do cargo. \nTRUE = ativo;\nFALSE = inativo.';
-- ddl-end --
COMMENT ON COLUMN public.cargo.nome IS E'Nome do cargo. \n(Bibliotecário, Administrador, Estagiário)';
-- ddl-end --
COMMENT ON COLUMN public.cargo.descricao IS E'Descrição das atribuições e responsabilidades do cargo.';
-- ddl-end --
COMMENT ON COLUMN public.cargo.nivel_acesso IS E'Nível de acesso do cargo.\n(1-3).';
-- ddl-end --
COMMENT ON CONSTRAINT nome_uq ON public.cargo IS E'Evita duplicidade e garante identificação clara do cargo.';
-- ddl-end --
ALTER TABLE public.cargo OWNER TO postgres;
-- ddl-end --

-- object: cargo_fk | type: CONSTRAINT --
-- ALTER TABLE public.funcionario DROP CONSTRAINT IF EXISTS cargo_fk CASCADE;
ALTER TABLE public.funcionario ADD CONSTRAINT cargo_fk FOREIGN KEY (id_cargo)
REFERENCES public.cargo (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: public.autor | type: TABLE --
-- DROP TABLE IF EXISTS public.autor CASCADE;
CREATE TABLE public.autor (
	id serial NOT NULL,
	nome varchar(100) NOT NULL,
	nacionalidade varchar(50),
	CONSTRAINT autor_pk PRIMARY KEY (id)
);
-- ddl-end --
COMMENT ON TABLE public.autor IS E'Cadastro dos autores das obras. \nArmazena cada autor com identificador único.\n(1FN)';
-- ddl-end --
COMMENT ON COLUMN public.autor.id IS E'Identificador único do autor.';
-- ddl-end --
COMMENT ON COLUMN public.autor.nome IS E'Nome ou pseudônimo do autor.';
-- ddl-end --
COMMENT ON COLUMN public.autor.nacionalidade IS E'Nacionalidade do autor.';
-- ddl-end --
ALTER TABLE public.autor OWNER TO postgres;
-- ddl-end --

-- object: public.livro_autor | type: TABLE --
-- DROP TABLE IF EXISTS public.livro_autor CASCADE;
CREATE TABLE public.livro_autor (
	id_autor integer,
	id_livro integer

);
-- ddl-end --
COMMENT ON TABLE public.livro_autor IS E'Implementa relacionamento N:N entre LIVRO e AUTOR. \nChave primária composta (ID_LIVRO + ID_AUTOR).\n(2FN/3FN)';
-- ddl-end --
ALTER TABLE public.livro_autor OWNER TO postgres;
-- ddl-end --

-- object: autor_fk | type: CONSTRAINT --
-- ALTER TABLE public.livro_autor DROP CONSTRAINT IF EXISTS autor_fk CASCADE;
ALTER TABLE public.livro_autor ADD CONSTRAINT autor_fk FOREIGN KEY (id_autor)
REFERENCES public.autor (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: public.endereco | type: TABLE --
-- DROP TABLE IF EXISTS public.endereco CASCADE;
CREATE TABLE public.endereco (
	id serial NOT NULL,
	rua varchar(100) NOT NULL,
	numero varchar(10) NOT NULL,
	bairro varchar(50),
	cidade varchar(100) NOT NULL,
	uf char(2) NOT NULL,
	complemento varchar(50),
	CONSTRAINT endereco_pk PRIMARY KEY (id)
);
-- ddl-end --
COMMENT ON TABLE public.endereco IS E'Endereços dos usuários.\nRelacionamento 1:1 com USUARIO.\nNormaliza dados de localização.';
-- ddl-end --
COMMENT ON COLUMN public.endereco.id IS E'Identificador único do endereço.';
-- ddl-end --
COMMENT ON COLUMN public.endereco.rua IS E'Rua em que reside o usuário.';
-- ddl-end --
COMMENT ON COLUMN public.endereco.numero IS E'Número da residência do usuário.';
-- ddl-end --
COMMENT ON COLUMN public.endereco.bairro IS E'Bairro em que reside o usuário.';
-- ddl-end --
COMMENT ON COLUMN public.endereco.cidade IS E'Cidade em que reside o usuário.';
-- ddl-end --
COMMENT ON COLUMN public.endereco.uf IS E'Unidade federativa em que reside o usuário.';
-- ddl-end --
COMMENT ON COLUMN public.endereco.complemento IS E'Complemento do endereço do usuário.';
-- ddl-end --
ALTER TABLE public.endereco OWNER TO postgres;
-- ddl-end --

-- object: endereco_fk | type: CONSTRAINT --
-- ALTER TABLE public.usuario DROP CONSTRAINT IF EXISTS endereco_fk CASCADE;
ALTER TABLE public.usuario ADD CONSTRAINT endereco_fk FOREIGN KEY (id_endereco)
REFERENCES public.endereco (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: public.editora | type: TABLE --
-- DROP TABLE IF EXISTS public.editora CASCADE;
CREATE TABLE public.editora (
	id serial NOT NULL,
	nome varchar(50) NOT NULL,
	email varchar(100),
	CONSTRAINT editora_pk PRIMARY KEY (id)
);
-- ddl-end --
COMMENT ON TABLE public.editora IS E'Editoras das obras do acervo.\nCentraliza dados das publicadoras.';
-- ddl-end --
COMMENT ON COLUMN public.editora.id IS E'Identificador único da editora.';
-- ddl-end --
COMMENT ON COLUMN public.editora.nome IS E'Nome da editora.';
-- ddl-end --
COMMENT ON COLUMN public.editora.email IS E'E-mail de contato da editora.';
-- ddl-end --
ALTER TABLE public.editora OWNER TO postgres;
-- ddl-end --

-- object: editora_fk | type: CONSTRAINT --
-- ALTER TABLE public.livro DROP CONSTRAINT IF EXISTS editora_fk CASCADE;
ALTER TABLE public.livro ADD CONSTRAINT editora_fk FOREIGN KEY (id_editora)
REFERENCES public.editora (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: livro_fk | type: CONSTRAINT --
-- ALTER TABLE public.exemplar DROP CONSTRAINT IF EXISTS livro_fk CASCADE;
ALTER TABLE public.exemplar ADD CONSTRAINT livro_fk FOREIGN KEY (id_livro)
REFERENCES public.livro (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: livro_fk | type: CONSTRAINT --
-- ALTER TABLE public.livro_autor DROP CONSTRAINT IF EXISTS livro_fk CASCADE;
ALTER TABLE public.livro_autor ADD CONSTRAINT livro_fk FOREIGN KEY (id_livro)
REFERENCES public.livro (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: usuario_fk | type: CONSTRAINT --
-- ALTER TABLE public.emprestimo DROP CONSTRAINT IF EXISTS usuario_fk CASCADE;
ALTER TABLE public.emprestimo ADD CONSTRAINT usuario_fk FOREIGN KEY (cart_num_usuario)
REFERENCES public.usuario (cart_num) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: exemplar_fk | type: CONSTRAINT --
-- ALTER TABLE public.emprestimo DROP CONSTRAINT IF EXISTS exemplar_fk CASCADE;
ALTER TABLE public.emprestimo ADD CONSTRAINT exemplar_fk FOREIGN KEY (cod_exemplar)
REFERENCES public.exemplar (cod) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: emprestimo_fk | type: CONSTRAINT --
-- ALTER TABLE public.multa DROP CONSTRAINT IF EXISTS emprestimo_fk CASCADE;
ALTER TABLE public.multa ADD CONSTRAINT emprestimo_fk FOREIGN KEY (id_emprestimo)
REFERENCES public.emprestimo (id) MATCH FULL
ON DELETE SET NULL ON UPDATE CASCADE;
-- ddl-end --

-- object: multa_uq | type: CONSTRAINT --
-- ALTER TABLE public.multa DROP CONSTRAINT IF EXISTS multa_uq CASCADE;
ALTER TABLE public.multa ADD CONSTRAINT multa_uq UNIQUE (id_emprestimo);
-- ddl-end --