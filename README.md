# 🔧 Projeto de Banco de Dados - Oficina Mecânica

Este projeto tem como objetivo a modelagem e implementação de um banco de dados relacional para gerenciamento de ordens de serviço em uma oficina mecânica, utilizando o **MySQL**.

## 📚 Narrativa

- Clientes levam veículos à oficina mecânica para manutenção ou revisão.
- Cada veículo é vinculado a um cliente e designado a uma equipe de mecânicos.
- Os mecânicos realizam os serviços e preenchem uma **Ordem de Serviço (OS)** com data de entrada e entrega.
- Cada OS pode conter vários serviços realizados.

---

## 🧱 Modelo Conceitual (Entidades)

- **Cliente**
- **Veículo**
- **Equipe**
- **Mecânico**
- **Ordem de Serviço**
- **Serviço**
- **Relacionamento Ordem-Serviço/Serviço (N:N)**

---

## 🗃️ Modelo Relacional com Constraints

```sql
CREATE TABLE Cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100) UNIQUE
);

CREATE TABLE Veiculo (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    placa VARCHAR(10) NOT NULL UNIQUE,
    modelo VARCHAR(50) NOT NULL,
    ano INT CHECK (ano >= 1980),
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Equipe (
    id_equipe INT AUTO_INCREMENT PRIMARY KEY,
    nome_equipe VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Mecanico (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100),
    id_equipe INT,
    FOREIGN KEY (id_equipe) REFERENCES Equipe(id_equipe)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE OrdemServico (
    id_os INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    id_equipe INT,
    data_entrada DATE NOT NULL,
    data_entrega DATE,
    FOREIGN KEY (id_veiculo) REFERENCES Veiculo(id_veiculo)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_equipe) REFERENCES Equipe(id_equipe)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Servico (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(200) NOT NULL UNIQUE,
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0)
);

CREATE TABLE OrdemServico_Servico (
    id_os INT NOT NULL,
    id_servico INT NOT NULL,
    PRIMARY KEY (id_os, id_servico),
    FOREIGN KEY (id_os) REFERENCES OrdemServico(id_os)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_servico) REFERENCES Servico(id_servico)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


# Triggers 


## Trigger check_datas_os
Garante que a data de entrega da ordem de serviço nunca seja anterior à data de entrada.

DELIMITER $$

CREATE TRIGGER check_datas_os
BEFORE INSERT ON OrdemServico
FOR EACH ROW
BEGIN
    IF NEW.data_entrega IS NOT NULL AND NEW.data_entrega < NEW.data_entrada THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A data de entrega não pode ser anterior à data de entrada.';
    END IF;
END$$

DELIMITER ;


## Trigger validar_ano_veiculo
Evita o cadastro de veículos com ano superior ao ano atual, substituindo o uso de funções dinâmicas (CURDATE()) que não são aceitas em **CHECK**.

DELIMITER $$

CREATE TRIGGER validar_ano_veiculo
BEFORE INSERT ON Veiculo
FOR EACH ROW
BEGIN
    IF NEW.ano > YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ano do veículo não pode ser maior que o ano atual.';
    END IF;
END$$

DELIMITER ;
