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


-- Copiando estrutura do banco de dados para edenerp
CREATE DATABASE IF NOT EXISTS `edenerp` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `edenerp`;

-- Copiando estrutura para tabela edenerp.agendamentos
CREATE TABLE IF NOT EXISTS `agendamentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cliente_id` int(11) NOT NULL,
  `profissional_id` int(11) NOT NULL,
  `servico_id` int(11) NOT NULL,
  `data_hora_inicio` datetime NOT NULL,
  `data_hora_fim` datetime NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'AGENDADO',
  `observacoes` varchar(255) DEFAULT NULL,
  `google_event_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_ag_cli` (`cliente_id`),
  KEY `fk_ag_serv` (`servico_id`),
  KEY `data_hora_inicio` (`data_hora_inicio`),
  KEY `profissional_id` (`profissional_id`,`data_hora_inicio`),
  CONSTRAINT `fk_ag_cli` FOREIGN KEY (`cliente_id`) REFERENCES `clientesbkp` (`id`),
  CONSTRAINT `fk_ag_prof` FOREIGN KEY (`profissional_id`) REFERENCES `profissionais` (`id`),
  CONSTRAINT `fk_ag_serv` FOREIGN KEY (`servico_id`) REFERENCES `servicos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.agendamentos: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela edenerp.basictables
CREATE TABLE IF NOT EXISTS `basictables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `User` varchar(100) DEFAULT NULL,
  `ProjectName` varchar(255) DEFAULT NULL,
  `team` varchar(255) DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `Budget` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.basictables: ~2 rows (aproximadamente)
INSERT INTO `basictables` (`id`, `User`, `ProjectName`, `team`, `Status`, `Budget`) VALUES
	(1, 'Two Nine', 'ERP', 'Delfin', 'Ativo', 10.00),
	(2, 'Rafa', 'ERP', 'Delfin', 'Ativo', 10.00);

-- Copiando estrutura para tabela edenerp.clientes
CREATE TABLE IF NOT EXISTS `clientes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `telefone_principal` varchar(20) DEFAULT NULL,
  `telefone_secundario` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `data_nascimento` date DEFAULT NULL,
  `data_cadastro` datetime NOT NULL DEFAULT current_timestamp(),
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `vip` tinyint(1) NOT NULL DEFAULT 0,
  `frequencia` varchar(20) DEFAULT NULL,
  `plano_ativo` varchar(100) DEFAULT NULL,
  `pontos_fidelidade` int(11) NOT NULL DEFAULT 0,
  `desconto_personalizado` decimal(5,2) DEFAULT 0.00,
  `preferencia_horario` varchar(100) DEFAULT NULL,
  `profissional_padrao_id` int(11) DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_cli_prof_padrao` (`profissional_padrao_id`),
  CONSTRAINT `fk_cli_prof_padrao` FOREIGN KEY (`profissional_padrao_id`) REFERENCES `profissionais` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.clientes: ~2 rows (aproximadamente)
INSERT INTO `clientes` (`id`, `nome`, `telefone_principal`, `telefone_secundario`, `email`, `data_nascimento`, `data_cadastro`, `ativo`, `vip`, `frequencia`, `plano_ativo`, `pontos_fidelidade`, `desconto_personalizado`, `preferencia_horario`, `profissional_padrao_id`, `observacoes`) VALUES
	(1, 'Consumidor', NULL, NULL, NULL, NULL, '2026-01-17 17:16:47', 1, 0, 'Mensal', 'Mensalidade Premium', 0, 0.00, NULL, NULL, NULL),
	(2, 'Rafa', '(46)99929-9356', NULL, 'rafaelzenruths@gmail.com', '2002-05-05', '2026-01-17 17:52:18', 1, 1, NULL, NULL, 0, 0.00, NULL, NULL, NULL);

-- Copiando estrutura para tabela edenerp.clientesbkp
CREATE TABLE IF NOT EXISTS `clientesbkp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `data_cadastro` datetime NOT NULL DEFAULT current_timestamp(),
  `observacoes` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.clientesbkp: ~1 rows (aproximadamente)
INSERT INTO `clientesbkp` (`id`, `nome`, `telefone`, `email`, `data_cadastro`, `observacoes`) VALUES
	(1, 'Consumidor', NULL, NULL, '2026-01-16 20:10:33', NULL);

-- Copiando estrutura para tabela edenerp.estoque_movimentacoes
CREATE TABLE IF NOT EXISTS `estoque_movimentacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `produto_id` int(11) NOT NULL,
  `tipo` varchar(20) NOT NULL,
  `quantidade` decimal(10,2) NOT NULL,
  `data_mov` datetime NOT NULL DEFAULT current_timestamp(),
  `origem` varchar(50) DEFAULT NULL,
  `observacoes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `produto_id` (`produto_id`,`data_mov`),
  CONSTRAINT `fk_est_prod` FOREIGN KEY (`produto_id`) REFERENCES `produtos` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.estoque_movimentacoes: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela edenerp.financeiro_lancamentos
CREATE TABLE IF NOT EXISTS `financeiro_lancamentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(20) NOT NULL,
  `categoria` varchar(50) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `valor` decimal(10,2) NOT NULL,
  `data_lancamento` datetime NOT NULL DEFAULT current_timestamp(),
  `forma_pagamento` varchar(30) DEFAULT NULL,
  `referencia_id` int(11) DEFAULT NULL,
  `referencia_tipo` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.financeiro_lancamentos: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela edenerp.produtos
CREATE TABLE IF NOT EXISTS `produtos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `unidade` varchar(20) NOT NULL DEFAULT 'UN',
  `preco_custo` decimal(10,2) DEFAULT NULL,
  `preco_venda` decimal(10,2) DEFAULT NULL,
  `estoque_atual` decimal(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.produtos: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela edenerp.profissionais
CREATE TABLE IF NOT EXISTS `profissionais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `apelido` varchar(50) DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `usuario_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_profissionais_usuario_id` (`usuario_id`),
  CONSTRAINT `fk_prof_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.profissionais: ~2 rows (aproximadamente)
INSERT INTO `profissionais` (`id`, `nome`, `apelido`, `ativo`, `usuario_id`) VALUES
	(2, 'jc albuquerque', 'devjc24', 1, 3),
	(3, 'teste', 'teste', 1, 4);

-- Copiando estrutura para tabela edenerp.servicos
CREATE TABLE IF NOT EXISTS `servicos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `preco` decimal(10,2) NOT NULL,
  `duracao_minutos` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.servicos: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela edenerp.user_google_calendar_tokens
CREATE TABLE IF NOT EXISTS `user_google_calendar_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `google_email` varchar(255) DEFAULT NULL,
  `calendar_id` varchar(255) NOT NULL DEFAULT 'primary',
  `access_token_enc` text DEFAULT NULL,
  `access_token_iv` varchar(64) DEFAULT NULL,
  `access_token_tag` varchar(64) DEFAULT NULL,
  `refresh_token_enc` text DEFAULT NULL,
  `refresh_token_iv` varchar(64) DEFAULT NULL,
  `refresh_token_tag` varchar(64) DEFAULT NULL,
  `expiry_date_ms` bigint(20) DEFAULT NULL,
  `connected_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `fk_ugc_user` FOREIGN KEY (`user_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.user_google_calendar_tokens: ~2 rows (aproximadamente)
INSERT INTO `user_google_calendar_tokens` (`id`, `user_id`, `google_email`, `calendar_id`, `access_token_enc`, `access_token_iv`, `access_token_tag`, `refresh_token_enc`, `refresh_token_iv`, `refresh_token_tag`, `expiry_date_ms`, `connected_at`, `updated_at`) VALUES
	(1, 2, 'joaocls2406@gmail.com', 'joaocls2406@gmail.com', 'V8glNYwyVqfPPXJ5gN4o8+iw9G1TeVIJJIxOFV+xy0eK9B3/0BnRFqo76TOS/fJu1rglFbd/B0PtkWPFdGGJPo5ELqqeZ3O4uZFJPoACw2m5+OTMPZ2igIGEo6yc6394fXH+Vuj7iJUp//2PF82Twqz3ZHyrwwaQY/WjXuuDYllt+VSX5l3YomrVO5cnZ6lp5gCmp0AAkzKSTMn/fqfIMql5k2ntVc2vjeW1QxvkBueoZHc/nBP8AC7oyktwA+ur3Agr6JLkouj9W5K+KjYSFm5iuORr/5De38a4ejz1ubRd6797kVb92OTkOeHj6nUNgFIpdEQC5Ek40tpdpw==', 'FLESmPhEjiZHiCVW', 'AsFW4XzLIXrajuGBTeVvpA==', '3SVYYUc3U14tgSunfdNkVzbtkWQzdxW8bTSdM5ZMjXib1SnPCsbTl4fqthTnSvEino0hlyKNP7ncd6fbIp1inBdsytG089QgEAZEBWCa/x77GkiK9Lr9ngXl9hBuh7PbNLGMB79nLg==', 'G9EeQEi8bEBGzv38', 'uACWWNKJqWBpvi7dVyRKNw==', 1768781434548, '2026-01-18 23:05:05', '2026-01-18 23:10:35'),
	(2, 3, 'cijtutors@gmail.com', 'cijtutors@gmail.com', 'LU33crxM3fMdDV/ko5H9j90C15IBrNrGIATsUfV9EIqLi/f19gM37yV3JYz4NOGTXZMbY23RuYJlEx+XZKDlan82SvPp1fNyFn9Bv6JltfM6kwzdU1f3yLRUl3jDD+5Wh4I4ThM0wIj9XGU1eu/MXlZ798bLUeQbwWGt+A43N8+8yf6pE9prueA85UHr0sqnSY/Fo+uxDvYs0Kq4ysM4DukbjHEJgYTSW2IcyXJILeJADf6UKPPxMEPmrQmup1/Us95+v03tjNgut42axsXpv15IK1HYI4vm4ZyQLkAwNLRISX8w9/G2LLU05LAb6cJJrbe4GwDtMrkcXjPvhg==', 'Ls3QxrUfJVcKJGDb', 'JQRjKpwKjH92EH+IgtZ/7w==', 'lBamqq+mSM/QIAhM1VGvY4OEKunt7MrEnFPb880xOZ5SWYEFaQ71QkLidkPIHu8GGwA3qLdU/zAbexdpZt/VAY54e0ozYd/Lqrkwh8az+LwxaLR2utyK5ggzV7zl9Vt+iDLxMC5bFA==', '6qD5+EwSMgOTfD+e', 'JFep9viTlSZZUofHCgZylg==', 1768786661721, '2026-01-19 00:37:43', '2026-01-19 00:37:43');

-- Copiando estrutura para tabela edenerp.user_login_logs
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
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.user_login_logs: ~53 rows (aproximadamente)
INSERT INTO `user_login_logs` (`id`, `user_id`, `username`, `email`, `ip_address`, `device_info`, `login_time`, `logout_time`, `success`, `user_agent`) VALUES
	(1, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 03:05:59', '2026-01-12 03:06:15', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(2, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 03:25:12', '2026-01-12 03:25:22', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(3, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 03:25:32', '2026-01-12 03:25:34', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(4, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 03:25:38', '2026-01-12 03:26:15', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(5, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 03:26:19', '2026-01-12 03:26:21', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(6, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 03:31:11', '2026-01-12 03:31:43', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(7, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 03:31:45', '2026-01-12 03:34:42', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(8, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 03:36:01', '2026-01-12 03:45:24', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(9, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-12 03:45:28', '2026-01-12 03:46:21', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(10, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 00:55:49', '2026-01-13 01:59:49', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(11, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 01:59:55', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(12, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-13 02:34:36', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(13, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 04:11:40', '2026-01-16 04:11:43', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(14, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 04:12:33', '2026-01-16 04:15:30', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(15, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 04:16:45', NULL, 0, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(16, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 04:16:57', '2026-01-16 04:17:19', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(17, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 04:18:08', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(18, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 21:12:00', '2026-01-16 21:35:15', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(19, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 21:35:17', '2026-01-16 21:35:22', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(20, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 21:35:25', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(21, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 22:37:30', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(22, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 22:49:22', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(23, 2, 'Joao', 'joaocls2406@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-16 23:31:36', '2026-01-16 23:31:44', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(24, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-17 05:52:56', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(25, 1, 'Rafa', 'rafaelzenruths@gmail.com', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-17 13:47:56', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(26, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-17 17:46:37', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(27, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-17 17:52:10', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(28, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-17 18:06:44', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(29, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1', '2026-01-17 19:55:37', NULL, 1, 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1'),
	(30, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 03:39:21', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(31, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 14:26:57', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(32, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 17:07:26', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(33, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 19:48:29', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(34, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-18 19:53:25', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(35, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 20:34:28', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(36, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 21:12:36', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(37, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 21:36:58', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(38, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-18 22:03:24', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(39, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 22:55:36', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(40, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 22:56:34', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(41, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-18 23:13:57', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(42, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-18 23:32:29', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(43, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1', '2026-01-18 23:51:53', NULL, 1, 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1'),
	(44, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-19 00:02:42', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(45, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-19 00:21:54', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(46, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-19 00:28:25', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(47, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-19 00:29:33', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(48, 3, 'devjc24', 'devjc24@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-19 00:30:10', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(49, 2, 'Joao', 'joaocls2406@gmail.com', '190.124.190.176', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', '2026-01-19 00:44:56', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36'),
	(50, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-19 01:11:07', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(51, 4, 'teste', 'teste@teste.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-19 01:12:27', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(52, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-19 02:32:35', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36'),
	(53, 1, 'Rafa', 'rafaelzenruths@gmail.com', '138.117.89.108', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36', '2026-01-19 02:33:02', NULL, 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36');

-- Copiando estrutura para tabela edenerp.user_refresh_tokens
CREATE TABLE IF NOT EXISTS `user_refresh_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token_hash` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `last_used_at` datetime NOT NULL DEFAULT current_timestamp(),
  `expires_at` datetime NOT NULL,
  `revoked` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `token_hash` (`token_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.user_refresh_tokens: ~52 rows (aproximadamente)
INSERT INTO `user_refresh_tokens` (`id`, `user_id`, `token_hash`, `created_at`, `last_used_at`, `expires_at`, `revoked`) VALUES
	(1, 1, '$2b$10$k4uJdM5S6RwHKq.Zlw2c2OpZ83KAsvI0N3HQ4Pshk0Q80lJe8O9dW', '2026-01-12 00:05:59', '2026-01-12 00:05:59', '2026-01-12 00:35:59', 1),
	(2, 1, '$2b$10$l6hmF55Odp7DDF3qCBT4ke3mn3fPK5gdZDvqdIR3nseAhLdO7oe9q', '2026-01-12 00:25:12', '2026-01-12 00:25:12', '2026-01-12 00:55:12', 1),
	(3, 1, '$2b$10$hBj2VzN4JAOziCo9owB3tuXtV4YTtAKxLcg4EBe0c9ExYwL.OFkj2', '2026-01-12 00:25:32', '2026-01-12 00:25:32', '2026-01-12 00:55:32', 1),
	(4, 1, '$2b$10$9xGBfCNNtdf86CETCVLU4OYqxIpUVR8ADME3T/Cq98O3W1Cx.pKF6', '2026-01-12 00:25:38', '2026-01-12 00:25:38', '2026-01-12 00:55:38', 1),
	(5, 1, '$2b$10$fEPmOb/9L8ZMKUQ7s3GjW.RiILBVprDcu9dU6WoXcXVBteDW3MI5W', '2026-01-12 00:26:19', '2026-01-12 00:26:19', '2026-01-19 00:26:19', 1),
	(6, 1, '$2b$10$7KSQEmambIdN.zhmiSWy.unZo2Wun2gjmSRgcmr6smI6Ia0fKcH26', '2026-01-12 00:31:11', '2026-01-12 00:31:11', '2026-01-19 00:31:11', 1),
	(7, 1, '$2b$10$ETkN7YT5A4MnivV43Gy6p.GdhRhuswV/3XOft4BBJ/Cc4uGe1S0BW', '2026-01-12 00:31:45', '2026-01-12 00:31:45', '2026-01-12 01:01:45', 1),
	(8, 1, '$2b$10$8WUhLeMxwrZd0lgjL5JoheC6EXI7sYH10tRRtparGSkepF3J5ojMe', '2026-01-12 00:36:01', '2026-01-12 00:36:01', '2026-01-12 01:06:01', 1),
	(9, 1, '$2b$10$xFuiOGqAwwsKuJnoUYwBHuRbB/l/OJ3a9DQBehcU7thQwZKaOnoR.', '2026-01-12 00:45:28', '2026-01-12 00:45:28', '2026-01-12 01:15:28', 1),
	(10, 1, '$2b$10$T99BznVSZuMpJimnXpcjuOkj/5pcX4VCrx42KI8kDGhV4187srP7e', '2026-01-12 21:55:49', '2026-01-12 22:53:47', '2026-01-12 23:23:47', 1),
	(11, 1, '$2b$10$c8jSg9zacvplbwaOSoceLenqEwdp1qjxyPaciN1I1Zc1816DPxgBi', '2026-01-12 22:59:55', '2026-01-12 22:59:55', '2026-01-12 23:29:55', 1),
	(12, 1, '$2b$10$UIcMk7ZkHugLvV4ACjuYOOWoaK.J0b0Oe7d4V7n9PHMvxH2po2Zr.', '2026-01-12 23:34:36', '2026-01-12 23:51:48', '2026-01-13 00:21:48', 1),
	(13, 1, '$2b$10$Al0CBICfG8PGft3VoZkFPuApa6MwHmrxj8/LuyvyoboD4Zd/.oI8W', '2026-01-16 01:11:40', '2026-01-16 01:11:40', '2026-01-16 01:41:40', 1),
	(14, 1, '$2b$10$so1ClYc/4q2xD9n7piw50ePgstThwtIbwHmGTizgTSESLuRtpyHiS', '2026-01-16 01:12:33', '2026-01-16 01:12:33', '2026-01-16 01:42:33', 1),
	(15, 1, '$2b$10$/LK7incQZoV5R97NDNMJwODyjN3QQK899EsirF3NbUvR/HDg4DApa', '2026-01-16 01:16:57', '2026-01-16 01:16:57', '2026-01-16 01:46:57', 1),
	(16, 1, '$2b$10$yR48QcQGJKmMbWurGWI4.eRu69Y9flBpLdBDctB3KRm6vMQy62Z5W', '2026-01-16 01:18:08', '2026-01-16 01:18:08', '2026-01-16 01:48:08', 1),
	(17, 1, '$2b$10$0lZzuGusy0q2SqXYWyTUteHUbsgSPbY9Bg/MSyfZ7O38uFu3kXFse', '2026-01-16 18:12:00', '2026-01-16 18:29:34', '2026-01-16 18:59:34', 1),
	(18, 1, '$2b$10$KcSByaVVLS75YOgYffvSSeoMevhS.fkidwL8c9yl5Q9a66vjkb/pm', '2026-01-16 18:35:17', '2026-01-16 18:35:17', '2026-01-16 19:05:17', 1),
	(19, 1, '$2b$10$WO3xlvYB9BiTKKPmXkLEEekZo4CMv7VkbDGyF4/FBPkfBWye.CwXG', '2026-01-16 18:35:25', '2026-01-16 18:35:25', '2026-01-16 19:05:25', 1),
	(20, 1, '$2b$10$fpa.R6uDGsdlYckfilHR9eDTLRxXKRHP6nGdtjJnzY7j1dWYu3XJm', '2026-01-16 19:37:30', '2026-01-16 19:37:30', '2026-01-16 20:07:30', 1),
	(21, 1, '$2b$10$mLsGuy/CgiQXL6wo3zzaGO/HwyBofgVNvldntVYBjMMGPVXgypRPO', '2026-01-16 19:49:22', '2026-01-16 19:49:22', '2026-01-16 20:19:22', 1),
	(22, 2, '$2b$10$NOzN8TKim3XQFzcHRyztGuwDmLbuASPL82.ZOzQPqtnDw1JhH9Kxi', '2026-01-16 20:31:36', '2026-01-16 20:31:36', '2026-01-16 21:01:36', 1),
	(23, 1, '$2b$10$IiEvU2MbzJOmQKPf/nf.K.euoWErLvuuqW9yKKz3PbpvteDwAQrf2', '2026-01-17 02:52:56', '2026-01-17 02:52:56', '2026-01-17 03:22:56', 1),
	(24, 1, '$2b$10$acuhuKg5tPd9osWklhVkM.7qkyfc53ienqHOpaMsKGWzQ2yd4Azv6', '2026-01-17 10:47:56', '2026-01-17 10:47:56', '2026-01-17 11:17:56', 1),
	(25, 2, '$2b$10$PXvUnhnrypiJ0/4pVteAXObUIwnTdTLG.wYEGxD9qV5qMlKqYO6rm', '2026-01-17 14:46:37', '2026-01-17 14:46:37', '2026-01-17 15:16:37', 1),
	(26, 1, '$2b$10$.HzskI39I1kWk3U/dX3HVuPb6emuqZWsWBT3qaL2.3Pl6YL5mSG0.', '2026-01-17 14:52:10', '2026-01-17 14:52:10', '2026-01-17 15:22:10', 1),
	(27, 1, '$2b$10$/FI19pEbxBoUlcy0Zi8aeeQpUBFn/4LBJDPW/G/71eesh1T20DEDW', '2026-01-17 15:06:44', '2026-01-17 15:06:44', '2026-01-17 15:36:44', 1),
	(28, 1, '$2b$10$ByNko/bGheVHvK7tA8MfteEubetLa7OGD9L96qGSIcAkHU8bm7bGS', '2026-01-17 16:55:37', '2026-01-17 16:55:37', '2026-01-17 17:25:37', 1),
	(29, 2, '$2b$10$tCzfKcbTSnuBpEhMOS9lkeiO.dhfLaxvezMciN2zN3hCI4evsTZeW', '2026-01-18 00:39:21', '2026-01-18 00:39:21', '2026-01-18 01:09:21', 1),
	(30, 2, '$2b$10$zaRs0/W36dTxCh7/eG95Rul4JwSzVd.JEXGBcGgLB0gwKdIDlfQyi', '2026-01-18 11:26:57', '2026-01-18 11:26:57', '2026-01-18 11:56:57', 1),
	(31, 2, '$2a$10$LFPQk1l6QqEB2R3WIipyUumRwPe//rmYFXfa5qZILUASeNJfS0Wd2', '2026-01-18 14:07:26', '2026-01-18 14:07:26', '2026-01-18 14:37:26', 1),
	(32, 2, '$2a$10$jopi40AIr/9Yeec2JbH4g.3ruHuoj0TAQxWuKoUfytSY1bg4wT/SS', '2026-01-18 16:48:29', '2026-01-18 16:48:29', '2026-01-18 17:18:29', 1),
	(33, 1, '$2a$10$MjGd2zdlLzNTYOs3w4COMuhMR8z1kZbmY06iMe.5yoiOooebpMxQO', '2026-01-18 16:53:25', '2026-01-18 16:53:25', '2026-01-18 17:23:25', 1),
	(34, 2, '$2a$10$ZY6bFPqZTet0ODaFmecde.MGgGOfXCAM3KnOkVVtSa1vkfAr1KAmy', '2026-01-18 17:34:28', '2026-01-18 17:34:28', '2026-01-18 18:04:28', 1),
	(35, 2, '$2a$10$MXYPqRTZwhoLS9JA9EcIi..jOVbh8dIXMiVw0eSQmAlVFHANla9cO', '2026-01-18 18:12:36', '2026-01-18 18:35:11', '2026-01-18 19:05:11', 1),
	(36, 2, '$2a$10$Dmj.8IRtt5hHAuaV9LfqJ.VFsxXeGDctUI9x2m3VNTKkTnYjyiGO6', '2026-01-18 18:36:58', '2026-01-18 18:36:58', '2026-01-18 19:06:58', 1),
	(37, 1, '$2a$10$H8OvBJzxMwnHueVTggq2hOj0iGJy.8yZCZof2YYQLyV8xiuiI7zW6', '2026-01-18 19:03:24', '2026-01-18 19:03:24', '2026-01-18 19:33:24', 1),
	(38, 2, '$2a$10$a.CW/6v6k8EFXG/2HP93Qu17i72/ZJCjI0x.91NR0suBGVeW5Zpti', '2026-01-18 19:55:36', '2026-01-18 19:55:36', '2026-01-18 20:25:36', 1),
	(39, 2, '$2a$10$cxZ7xdEYQKuxXtogWdyWneySqJbVDmynwBePmCCg3AJEJBDHY3RAG', '2026-01-18 19:56:34', '2026-01-18 20:14:01', '2026-01-18 20:44:01', 1),
	(40, 1, '$2a$10$qLj65Ic41p1cReEPoichPeSyYl8U800G3m3i40tixQQPrdd8tF5Ty', '2026-01-18 20:13:57', '2026-01-18 20:13:57', '2026-01-18 20:43:57', 1),
	(41, 2, '$2a$10$Ry.D2qdiSMYTmZ8sOQbgaukYI2OGg6TEipl/cJ44ZqaXoyernnoPi', '2026-01-18 20:32:29', '2026-01-18 20:32:29', '2026-01-18 21:02:29', 1),
	(42, 1, '$2a$10$FAPlBaO9G27v7zwt/0v5A.cO3swEFMZlKrjR9ByfHxh6YY2obK80G', '2026-01-18 20:51:53', '2026-01-18 20:51:53', '2026-01-18 21:21:53', 1),
	(43, 1, '$2a$10$ewhONFLw./633e6VzO6kK.SwmYXrlpY3iGI7rTdXpE7aDuEe7btTq', '2026-01-18 21:02:42', '2026-01-18 21:02:42', '2026-01-18 21:32:42', 1),
	(44, 2, '$2a$10$pDTQknIcbPb5hMD8x/pm/OjuyxTVlVG8jZQxgOGOub6z2gliVJrta', '2026-01-18 21:21:54', '2026-01-18 21:21:54', '2026-01-18 21:51:54', 1),
	(45, 1, '$2a$10$sX5edEPru.lpsGv1Qg2fd.suasxz75BkbOZRg4hEEYxs/Q37WA2AS', '2026-01-18 21:28:25', '2026-01-18 21:28:25', '2026-01-18 21:58:25', 1),
	(46, 2, '$2a$10$DlXnXEbYDOGCLpmDIyOQseFQL35JXmPq2K6PptxblQpE6Kvh6jFQa', '2026-01-18 21:29:33', '2026-01-18 21:29:33', '2026-01-18 21:59:33', 1),
	(47, 3, '$2a$10$qPnXS3Q46kyT7/WUIwZ0HejoseruvSnFgfrq5NHRLo/JxRY2KTvei', '2026-01-18 21:30:10', '2026-01-18 21:30:10', '2026-01-18 22:00:10', 0),
	(48, 2, '$2a$10$VyViXIl3yykLIaWjUVc3CuNI8Syn/738m.gPXjP1/AlZagYrfhAxK', '2026-01-18 21:44:56', '2026-01-18 21:44:56', '2026-01-18 22:14:56', 0),
	(49, 1, '$2a$10$H1maDk25BODMXn/VhYEaTuNufG5uXeJxvetPOypHOSRL9BBF.cbNK', '2026-01-18 22:11:07', '2026-01-18 22:11:07', '2026-01-18 22:41:07', 1),
	(50, 4, '$2a$10$4fTdn0KXmWo8R3WCCYYnB.rFzcS/./amwtKZQcjkpfU.PZfQ.6F66', '2026-01-18 22:12:27', '2026-01-18 22:12:27', '2026-01-18 22:42:27', 0),
	(51, 1, '$2a$10$G8u9lK.Sgew0bhFvvI4kS.iS173csQMFWhuy7lp/N2cDZB98CkXVm', '2026-01-18 23:32:35', '2026-01-18 23:32:35', '2026-01-19 00:02:35', 1),
	(52, 1, '$2a$10$rlAPDgOQr3Sf2ArHm8Jq.uzgGltAp2CLMPL1PfLasw2hrmp6MkwVS', '2026-01-18 23:33:02', '2026-01-18 23:33:02', '2026-01-19 00:03:02', 0);

-- Copiando estrutura para tabela edenerp.user_sessions
CREATE TABLE IF NOT EXISTS `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `jwt_id` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `revoked` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `jwt_id` (`jwt_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.user_sessions: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela edenerp.usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.usuarios: ~4 rows (aproximadamente)
INSERT INTO `usuarios` (`id`, `username`, `email`, `password_hash`, `created_at`) VALUES
	(1, 'Rafa', 'rafaelzenruths@gmail.com', '$2b$10$XLECs54pMJ77ERCx8nyeRegNAQbJRXekRxIihwnCj03UzmQatVw.a', '2025-12-30 03:01:14'),
	(2, 'Joao', 'joaocls2406@gmail.com', '$2b$12$Bv5V4sNCeLrbkN6zqibIEuzZCQpCclm3WAEoUoHAaJU.Jvb4udkha', '2025-12-30 03:08:01'),
	(3, 'devjc24', 'devjc24@gmail.com', '$2a$10$ewVq5u6YyY8LbSaQEmJS3.kgEBKOZFoWsF36haLmWjNzhsrPGpSci', '2026-01-19 00:22:32'),
	(4, 'teste', 'teste@teste.com', '$2a$10$YXXriWUmaPV54nQB.5Qapusor.nV3Kt67csqHfTYJBQkg2LXT3gLy', '2026-01-19 01:11:42');

-- Copiando estrutura para tabela edenerp.vendas_balcao
CREATE TABLE IF NOT EXISTS `vendas_balcao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_venda` datetime NOT NULL DEFAULT current_timestamp(),
  `cliente_nome` varchar(100) DEFAULT NULL,
  `total` decimal(10,2) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'ABERTA',
  `usuario_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela edenerp.vendas_balcao: ~6 rows (aproximadamente)
INSERT INTO `vendas_balcao` (`id`, `data_venda`, `cliente_nome`, `total`, `status`, `usuario_id`) VALUES
	(1, '2025-12-31 02:03:55', 'Consumidor', 1.00, 'FINALIZADA', 1),
	(2, '2025-12-31 02:14:55', 'Maria', 2.00, 'ABERTA', 1),
	(3, '2025-12-31 02:19:55', 'João', 5.50, 'ABERTA', 1),
	(4, '2025-12-31 02:30:12', 'Ana', 15.00, 'FINALIZADA', 1),
	(5, '2025-12-30 06:50:45', 'Tiago', 10.00, 'FINALIZADA', 3),
	(56, '2025-12-30 06:50:45', 'Tiago', 8.40, 'FINALIZADA', 3);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
