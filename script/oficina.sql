-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS oficina;
USE oficina;

-- Tabela: Clientes
CREATE TABLE Clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,  -- Identificador único
    nome VARCHAR(50) NOT NULL,                 -- Nome obrigatório
    telefone VARCHAR(20),                      -- Telefone opcional
    email VARCHAR(100) UNIQUE                  -- E-mail único (não obrigatório)
);

-- Tabela: Veículo
CREATE TABLE Veiculo (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único
    id_cliente INT NOT NULL,                   -- FK obrigatória para Cliente
    placa VARCHAR(10) NOT NULL UNIQUE,         -- Placa única e obrigatória
    modelo VARCHAR(50) NOT NULL,               -- Modelo obrigatório
    ano INT CHECK (ano >= 1980), -- Ano válido
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
        ON DELETE CASCADE                      -- Se cliente for removido, remove veículos
        ON UPDATE CASCADE
);

-- Tabela: Equipe
CREATE TABLE Equipe (
    id_equipe INT AUTO_INCREMENT PRIMARY KEY,  -- Identificador único
    nome_equipe VARCHAR(50) NOT NULL UNIQUE    -- Nome da equipe único e obrigatório
);

-- Tabela: Mecânico
CREATE TABLE Mecanico (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY, -- Identificador único
    nome VARCHAR(50) NOT NULL,                  -- Nome obrigatório
    especialidade VARCHAR(50),                  -- Campo opcional
    id_equipe INT,                              -- FK pode ser nula
    FOREIGN KEY (id_equipe) REFERENCES Equipe(id_equipe)
        ON DELETE SET NULL                      -- Se equipe for deletada, mecânico fica sem equipe
        ON UPDATE CASCADE
);

-- Tabela: Ordem de Serviço
CREATE TABLE OrdemServico (
    id_os INT AUTO_INCREMENT PRIMARY KEY,       -- Identificador único da OS
    id_veiculo INT NOT NULL,                    -- FK obrigatória para Veículo
    id_equipe INT,                              -- FK pode ser nula se equipe for removida
    data_entrada DATE NOT NULL,                 -- Data obrigatória
    data_entrega DATE NOT NULL, 				-- Data obrigatória
    FOREIGN KEY (id_veiculo) REFERENCES Veiculo(id_veiculo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_equipe) REFERENCES Equipe(id_equipe)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- Tabela: Serviço
CREATE TABLE Servico (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,  -- Identificador único
    descricao VARCHAR(255) NOT NULL UNIQUE,     -- Descrição única e obrigatória
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0) -- Preço não pode ser negativo
);

-- Tabela associativa: Ordem de Serviço x Serviço
CREATE TABLE OrdemServico_Servico (
    id_os INT NOT NULL,                         -- FK para Ordem de Serviço
    id_servico INT NOT NULL,                    -- FK para Serviço
    PRIMARY KEY (id_os, id_servico),            -- Chave composta evita duplicidade
    FOREIGN KEY (id_os) REFERENCES OrdemServico(id_os)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (id_servico) REFERENCES Servico(id_servico)
        ON DELETE RESTRICT                     -- Impede deletar serviço que já está em uso
        ON UPDATE CASCADE
);
