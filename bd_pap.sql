-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 11, 2026 at 01:49 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bd_pap`
--

-- --------------------------------------------------------

--
-- Table structure for table `t_admin`
--

CREATE TABLE `t_admin` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `nome_de_usario` varchar(50) NOT NULL,
  `palavra_passe` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_admin`
--

INSERT INTO `t_admin` (`id`, `nome`, `email`, `nome_de_usario`, `palavra_passe`) VALUES
(1, 'Administrador', 'admin@hansaflex.com', 'administrador', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92');

-- --------------------------------------------------------

--
-- Table structure for table `t_categoria_produto`
--

CREATE TABLE `t_categoria_produto` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `descricao` varchar(100) NOT NULL,
  `id_produto` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_categoria_produto`
--

INSERT INTO `t_categoria_produto` (`id`, `nome`, `descricao`, `id_produto`) VALUES
(1, 'Mangueiras Hidráulicas', 'Mangueiras de alta pressão para sistemas hidráulicos industriais', 101),
(2, 'Conexões Hidráulicas', 'Conexões, adaptadores e terminais para mangueiras hidráulicas', 102),
(3, 'Mangueiras Industriais', 'Mangueiras para ar, água, produtos químicos e alimentos', 103),
(4, 'Vedação Industrial', 'O-rings, retentores e soluções de vedação', 104),
(5, 'Tecnologia de Acionamento', 'Componentes para transmissão de potência como correias e correntes', 105);

-- --------------------------------------------------------

--
-- Table structure for table `t_cliente`
--

CREATE TABLE `t_cliente` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `telefone` varchar(9) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `endereco` varchar(50) NOT NULL DEFAULT '',
  `id_tipo_utilizador` int(11) NOT NULL DEFAULT 2,
  `palavra_passe` varchar(64) NOT NULL,
  `pergunta_seguranca` varchar(255) DEFAULT NULL,
  `resposta_seguranca` varchar(255) DEFAULT NULL,
  `nome_de_usario` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_cliente`
--

INSERT INTO `t_cliente` (`id`, `email`, `telefone`, `nome`, `endereco`, `id_tipo_utilizador`, `palavra_passe`, `pergunta_seguranca`, `resposta_seguranca`, `nome_de_usario`) VALUES
(1, 'joao.silva@gmail.com', '912345678', 'Joao Silva', 'Rua de Santa Catarina, 120 - Porto', 1, 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', NULL, NULL, 'Joaosilva'),
(2, 'maria.santos@gmail.com', '913456789', 'Maria Santos', 'Avenida da Liberdade, 45 - Lisboa', 2, '626e3c805e77eeb472c42c6be607be2af7ac5c08fd7050f278e0330fe81abf57', NULL, NULL, 'Mariasantos'),
(3, 'netofabio2004gmail.com', '912345678', 'Fabio Neto', 'Rua de Santa Catarina, 120 - Porto', 2, '8681d505cb1b0344d0c7aa3c0e655c7e3a5add0f0960c1d142070a64cacab031', NULL, NULL, 'Fabioneto'),
(5, 'pedro.costa@gmail.com', '914567890', 'Pedro Costa', 'Rua de Cedofeita, 210 - Porto', 2, '2702cb34ee041711b9df0c67a8d5c9de02110c80e3fc966ba8341456dbc9ef2b', NULL, NULL, 'Pedrocosta'),
(11, 'fabioneto123@gmail.com', '917891821', 'Fabio Neto', '', 2, '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', NULL, NULL, 'fabioneto123'),
(12, 'euricopires25@gmail.com', '917689543', 'Eurico Pires', '', 2, '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', NULL, NULL, 'euricopires'),
(13, 'amilca123@gmail.com', '911899711', 'Amilca', '', 2, '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', NULL, NULL, 'amilca123');

-- --------------------------------------------------------

--
-- Table structure for table `t_encomenda`
--

CREATE TABLE `t_encomenda` (
  `id` int(11) NOT NULL,
  `produto_id` int(11) NOT NULL,
  `nome_cliente` varchar(150) NOT NULL,
  `email_cliente` varchar(200) NOT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `morada` varchar(250) NOT NULL,
  `localidade` varchar(100) NOT NULL,
  `codigo_postal` varchar(20) NOT NULL,
  `pais` varchar(50) DEFAULT 'Portugal',
  `nif` varchar(20) DEFAULT NULL,
  `quantidade` int(11) NOT NULL,
  `observacoes` text DEFAULT NULL,
  `data_encomenda` datetime DEFAULT current_timestamp(),
  `estado` varchar(20) NOT NULL DEFAULT 'Pendente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_encomenda`
--

INSERT INTO `t_encomenda` (`id`, `produto_id`, `nome_cliente`, `email_cliente`, `telefone`, `morada`, `localidade`, `codigo_postal`, `pais`, `nif`, `quantidade`, `observacoes`, `data_encomenda`, `estado`) VALUES
(1, 2, 'Maria Santos', 'maria.santos@email.com', '934567890', 'Av. da Liberdade 45', 'Porto', '4000-123', 'Portugal', '987654321', 1, 'Sem observações', '2026-02-21 00:00:00', 'Pendente'),
(2, 3, 'Carlos Ferreira', 'carlos.ferreira@email.com', '965432187', 'Rua do Sol 78', 'Coimbra', '3000-456', 'Portugal', '192837465', 5, 'Pagamento por transferência', '2026-02-22 00:00:00', 'Pendente'),
(3, 4, 'Ana Costa', 'ana.costa@email.com', '923456781', 'Travessa do Mar 12', 'Faro', '8000-789', 'Portugal', '564738291', 3, 'Ligar antes da entrega', '2026-02-23 00:00:00', 'Pendente'),
(4, 5, 'Pedro Almeida', 'pedro.almeida@email.com', '918273645', 'Rua Central 9', 'Braga', '4700-321', 'Portugal', '102938475', 4, 'Entregar em horário laboral', '2026-02-24 00:00:00', 'Pendente'),
(9, 2, 'Fabio Neto', 'fabioneto123@gmail.com', '917891821', 'Rua Epromat 123', 'Porto', '4450-019', 'Portugal', NULL, 1, 'Quero na porta direita', '2026-03-10 19:48:52', 'Pendente'),
(10, 4, 'Fabio Neto', 'fabioneto123@gmail.com', '917891821', 'rua dos palops 123', 'porto', '4440-039', 'Portugal', NULL, 1, 'em casa\r\n', '2026-03-11 10:09:05', 'Pendente'),
(11, 4, 'Fabio Neto', 'fabioneto123@gmail.com', '917891821', 'rua mamÃ£o', 'porto', '4400-039', 'Portugal', NULL, 1, 'rua', '2026-03-11 11:18:11', 'Pendente');

-- --------------------------------------------------------

--
-- Table structure for table `t_item_de_pedido`
--

CREATE TABLE `t_item_de_pedido` (
  `id` int(11) NOT NULL,
  `quantidade` int(11) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `preco_unitario` decimal(10,2) NOT NULL,
  `id_produto` int(11) NOT NULL,
  `id_pedido` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_item_de_pedido`
--

INSERT INTO `t_item_de_pedido` (`id`, `quantidade`, `subtotal`, `preco_unitario`, `id_produto`, `id_pedido`) VALUES
(1, 10, 500.00, 50.00, 201, 301),
(2, 5, 250.00, 50.00, 202, 301),
(3, 3, 120.00, 40.00, 203, 302),
(4, 7, 210.00, 30.00, 204, 303),
(5, 2, 160.00, 80.00, 205, 304),
(7, 11, 0.08, 0.08, 6, 9),
(11, 4, 1399.96, 349.99, 1, 16);

-- --------------------------------------------------------

--
-- Table structure for table `t_noticia`
--

CREATE TABLE `t_noticia` (
  `id` int(11) NOT NULL,
  `titulo` varchar(70) NOT NULL,
  `conteudo` text DEFAULT NULL,
  `data_publicacao` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_noticia`
--

INSERT INTO `t_noticia` (`id`, `titulo`, `conteudo`, `data_publicacao`) VALUES
(1, 'Hansa-Flex inaugura nova unidade em Luanda', 'A Hansa-Flex inaugurou uma nova unidade operaciona', '2026-02-01'),
(2, 'Novas soluções em mangueiras hidráulicas de alta pressão', 'A empresa apresenta uma nova linha de mangueiras h', '2026-02-03'),
(3, 'Hansa-Flex participa na Feira Industrial 2026', 'A Hansa-Flex marcou presença na Feira Industrial 2', '2026-02-05'),
(4, 'Programa de formação técnica para clientes', 'A empresa lançou um programa de formação técnica d', '2026-02-07'),
(5, 'Hansa-Flex reforça compromisso com sustentabilidade', 'A Hansa-Flex implementou novas práticas sustentáve', '2026-02-10'),
(8, 'Hansa-Flex lança novo catálogo 2026', 'A Hansa-Flex apresentou o novo catálogo de produto', '2026-03-11');

-- --------------------------------------------------------

--
-- Table structure for table `t_orcamento`
--

CREATE TABLE `t_orcamento` (
  `id` int(11) NOT NULL,
  `estatus` varchar(50) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `validade` date NOT NULL,
  `id_pedido` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_orcamento`
--

INSERT INTO `t_orcamento` (`id`, `estatus`, `valor`, `validade`, `id_pedido`) VALUES
(1, 'aprovado', 125000.00, '2026-03-15', 201),
(2, 'pendente', 78500.50, '2026-03-20', 202),
(3, 'rejeitado', 45200.00, '2026-02-28', 203),
(4, 'aprovado', 230000.75, '2026-04-05', 204),
(5, 'pendente', 15000.00, '2026-03-01', 205),
(6, 'Aprovado', 0.14, '2026-02-16', 6),
(7, 'Pendente', 0.08, '2026-02-06', 7),
(8, 'Aprovado', 2.00, '2026-02-17', 5);

-- --------------------------------------------------------

--
-- Table structure for table `t_pedido`
--

CREATE TABLE `t_pedido` (
  `id` int(11) NOT NULL,
  `status` varchar(50) NOT NULL,
  `data` date NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `filial` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_pedido`
--

INSERT INTO `t_pedido` (`id`, `status`, `data`, `id_cliente`, `filial`) VALUES
(10, 'pendente', '2026-02-12', 201, 1),
(11, 'em processamento', '2026-02-12', 202, 2),
(12, 'concluido', '2026-02-11', 203, 1),
(13, 'cancelado', '2026-02-10', 204, 3),
(16, 'Pendente', '2026-02-25', 2, 2);

-- --------------------------------------------------------

--
-- Table structure for table `t_produto`
--

CREATE TABLE `t_produto` (
  `id` int(11) NOT NULL,
  `descricao` varchar(100) NOT NULL,
  `categoria` varchar(100) NOT NULL DEFAULT 'Geral',
  `imagem` varchar(255) DEFAULT NULL,
  `estoque` int(11) NOT NULL,
  `preco` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_produto`
--

INSERT INTO `t_produto` (`id`, `descricao`, `categoria`, `imagem`, `estoque`, `preco`) VALUES
(1, 'Mangueiras hidráulicas e pneumáticas', 'Mangueiras', 'produto1.png', 17, 349.99),
(2, 'Tubulações e tubos dobrados', 'Tubagens', 'produto3.png', 10, 699.00),
(3, 'Válvulas e conectores', 'Conexões', 'produto2.png', 50, 19.99),
(4, 'Bomba hidráulica', 'Bombas', 'produto4.png', 15, 850.00),
(5, 'Válvulas de Controle', 'Válvulas', 'produto5.png', 20, 450.00),
(6, 'Filtros Hidráulicos', 'Filtração', 'produto6.png', 30, 120.00),
(7, 'Acumuladores Hidráulicos', 'Acumuladores', 'produto7.png', 8, 1200.00),
(8, 'Reservatórios Hidráulicos', 'Reservatórios', 'produto8.png', 5, 2500.00),
(9, 'Selos e Vedações', 'Vedação', 'produto9.png', 50, 35.00);

-- --------------------------------------------------------

--
-- Table structure for table `t_solicitacao_de_contato`
--

CREATE TABLE `t_solicitacao_de_contato` (
  `id` int(11) NOT NULL,
  `data` date NOT NULL,
  `mensagem` text NOT NULL,
  `status` varchar(50) NOT NULL,
  `id_cliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_solicitacao_de_contato`
--

INSERT INTO `t_solicitacao_de_contato` (`id`, `data`, `mensagem`, `status`, `id_cliente`) VALUES
(1, '2026-02-10', 'Solicito informações sobre mangueiras hidráulicas.', 'pendente', 101),
(2, '2026-02-10', 'Gostaria de receber o catálogo atualizado de produtos.', 'pendente', 102),
(3, '2026-02-10', 'Houve um problema com o último pedido, preciso de suporte.', 'em andamento', 103),
(4, '2026-02-10', 'Solicito orçamento para manutenção preventiva.', 'pendente', 104),
(5, '2026-02-10', 'Preciso alterar os dados de contato do cadastro.', 'resolvido', 105);

-- --------------------------------------------------------

--
-- Table structure for table `t_tipo_utilizador`
--

CREATE TABLE `t_tipo_utilizador` (
  `id` int(11) NOT NULL,
  `tipo` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_tipo_utilizador`
--

INSERT INTO `t_tipo_utilizador` (`id`, `tipo`) VALUES
(1, 'Admin'),
(2, 'Cliente');

-- --------------------------------------------------------

--
-- Table structure for table `t_unidade_filial`
--

CREATE TABLE `t_unidade_filial` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `cidade` text NOT NULL,
  `telefone` varchar(9) NOT NULL,
  `id_noticia` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `t_unidade_filial`
--

INSERT INTO `t_unidade_filial` (`id`, `nome`, `cidade`, `telefone`, `id_noticia`) VALUES
(1, 'Hansa Flex Lisboa Centro', 'Lisboa', '912345678', 1),
(2, 'Hansa Flex Porto Industrial', 'Porto', '913456789', 2),
(3, 'Hansa Flex Braga Norte', 'Braga', '914567890', 3),
(4, 'Hansa Flex Coimbra Sul', 'Coimbra', '915678901', 4);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `t_admin`
--
ALTER TABLE `t_admin`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `nome_de_usario` (`nome_de_usario`);

--
-- Indexes for table `t_categoria_produto`
--
ALTER TABLE `t_categoria_produto`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t_cliente`
--
ALTER TABLE `t_cliente`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t_encomenda`
--
ALTER TABLE `t_encomenda`
  ADD PRIMARY KEY (`id`),
  ADD KEY `produto_id` (`produto_id`);

--
-- Indexes for table `t_item_de_pedido`
--
ALTER TABLE `t_item_de_pedido`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t_noticia`
--
ALTER TABLE `t_noticia`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t_orcamento`
--
ALTER TABLE `t_orcamento`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t_pedido`
--
ALTER TABLE `t_pedido`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t_produto`
--
ALTER TABLE `t_produto`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t_solicitacao_de_contato`
--
ALTER TABLE `t_solicitacao_de_contato`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t_tipo_utilizador`
--
ALTER TABLE `t_tipo_utilizador`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `t_unidade_filial`
--
ALTER TABLE `t_unidade_filial`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `t_admin`
--
ALTER TABLE `t_admin`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `t_categoria_produto`
--
ALTER TABLE `t_categoria_produto`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `t_cliente`
--
ALTER TABLE `t_cliente`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `t_encomenda`
--
ALTER TABLE `t_encomenda`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `t_item_de_pedido`
--
ALTER TABLE `t_item_de_pedido`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `t_noticia`
--
ALTER TABLE `t_noticia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `t_orcamento`
--
ALTER TABLE `t_orcamento`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `t_pedido`
--
ALTER TABLE `t_pedido`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `t_produto`
--
ALTER TABLE `t_produto`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `t_solicitacao_de_contato`
--
ALTER TABLE `t_solicitacao_de_contato`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `t_tipo_utilizador`
--
ALTER TABLE `t_tipo_utilizador`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `t_unidade_filial`
--
ALTER TABLE `t_unidade_filial`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `t_encomenda`
--
ALTER TABLE `t_encomenda`
  ADD CONSTRAINT `t_encomenda_ibfk_1` FOREIGN KEY (`produto_id`) REFERENCES `t_produto` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
