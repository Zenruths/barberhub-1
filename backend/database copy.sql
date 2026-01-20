-- backend/database.sql
-- Arquivo central para scripts SQL do projeto (estrutura e dados iniciais)

-- Coloque aqui os comandos de criação de banco e tabelas:
--
-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           11.4.4-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Copiando estrutura para tabela tailadmin.basictables
CREATE TABLE IF NOT EXISTS `basictables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `User` varchar(100) DEFAULT NULL,
  `ProjectName` varchar(255) DEFAULT NULL,
  `team` varchar(255) DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `Budget` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela tailadmin.user_login_logs
CREATE TABLE IF NOT EXISTS `user_login_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `device_info` varchar(255) DEFAULT NULL,
  `login_time` timestamp NULL DEFAULT current_timestamp(),
  `logout_time` timestamp NULL DEFAULT NULL,
  `success` tinyint(1) DEFAULT 1,
  `user_agent` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_login_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportação de dados foi desmarcado.

-- Copiando estrutura para tabela tailadmin.usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Exportação de dados foi desmarcado.

-- Tabela de vendas de balcão
CREATE TABLE IF NOT EXISTS vendas_balcao (
  id INT AUTO_INCREMENT PRIMARY KEY,
  data_venda DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cliente_nome VARCHAR(100),
  total DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ABERTA',
  usuario_id INT,
  INDEX (usuario_id)
);

-- Tabela de sessões de usuário para controle de sessão única
CREATE TABLE IF NOT EXISTS user_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  jwt_id VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  revoked BOOLEAN NOT NULL DEFAULT FALSE,
  INDEX (user_id),
  INDEX (jwt_id)
);

-- Tabela de refresh tokens para controle de sessão (idle timeout)
CREATE TABLE IF NOT EXISTS user_refresh_tokens (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_used_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at DATETIME NOT NULL,
  revoked BOOLEAN NOT NULL DEFAULT FALSE,
  INDEX (user_id),
  INDEX (token_hash)
);

CREATE TABLE IF NOT EXISTS clientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  telefone_principal VARCHAR(20),
  telefone_secundario VARCHAR(20),
  email VARCHAR(100),
  data_nascimento DATE,
  data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  vip TINYINT(1) NOT NULL DEFAULT 0,
  frequencia VARCHAR(20), -- Semanal / Quinzenal / Mensal / Ocasional
  plano_ativo VARCHAR(100), -- nome do plano/pacote atual (se aplicável)
  pontos_fidelidade INT NOT NULL DEFAULT 0,
  desconto_personalizado DECIMAL(5,2) DEFAULT 0.00, -- percentual (%), ex: 10.00 = 10%
  preferencia_horario VARCHAR(100), -- ex: Manhã, Tarde, Noite, Dias específicos
  profissional_padrao_id INT NULL,
  observacoes TEXT,
  CONSTRAINT fk_cli_prof_padrao FOREIGN KEY (profissional_padrao_id) REFERENCES profissionais(id)
);

CREATE TABLE IF NOT EXISTS profissionais (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  apelido VARCHAR(50),
  ativo TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS servicos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  descricao VARCHAR(255),
  preco DECIMAL(10,2) NOT NULL,
  duracao_minutos INT NOT NULL
);

CREATE TABLE IF NOT EXISTS agendamentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cliente_id INT NOT NULL,
  profissional_id INT NOT NULL,
  servico_id INT NOT NULL,
  data_hora_inicio DATETIME NOT NULL,
  data_hora_fim DATETIME NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'AGENDADO', -- AGENDADO / CONCLUIDO / CANCELADO / NAO_COMPARECEU
  observacoes VARCHAR(255),
  CONSTRAINT fk_ag_cli FOREIGN KEY (cliente_id) REFERENCES clientes(id),
  CONSTRAINT fk_ag_prof FOREIGN KEY (profissional_id) REFERENCES profissionais(id),
  CONSTRAINT fk_ag_serv FOREIGN KEY (servico_id) REFERENCES servicos(id),
  INDEX (data_hora_inicio),
  INDEX (profissional_id, data_hora_inicio)
);

CREATE TABLE IF NOT EXISTS produtos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  descricao VARCHAR(255),
  unidade VARCHAR(20) NOT NULL DEFAULT 'UN',
  preco_custo DECIMAL(10,2),
  preco_venda DECIMAL(10,2),
  estoque_atual DECIMAL(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS estoque_movimentacoes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  produto_id INT NOT NULL,
  tipo VARCHAR(20) NOT NULL, -- ENTRADA / SAIDA / AJUSTE
  quantidade DECIMAL(10,2) NOT NULL,
  data_mov DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  origem VARCHAR(50), -- compra, venda, uso interno, etc.
  observacoes VARCHAR(255),
  CONSTRAINT fk_est_prod FOREIGN KEY (produto_id) REFERENCES produtos(id),
  INDEX (produto_id, data_mov)
);

CREATE TABLE IF NOT EXISTS financeiro_lancamentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tipo VARCHAR(20) NOT NULL, -- RECEITA / DESPESA
  categoria VARCHAR(50) NOT NULL, -- corte, barba, produto, aluguel, etc.
  descricao VARCHAR(255),
  valor DECIMAL(10,2) NOT NULL,
  data_lancamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  forma_pagamento VARCHAR(30), -- dinheiro, cartão, pix
  referencia_id INT,           -- opcional (id da venda, agendamento, etc.)
  referencia_tipo VARCHAR(30)  -- 'VENDA_BALCAO', 'AGENDAMENTO', etc.
);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
-- Fim do arquivo backend/database.sql