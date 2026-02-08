-- CREATING SUPPLIER DIMENTION
INSERT INTO dim_fornecedores (Fornecedor, CNPJ)
SELECT DISTINCT Fornecedor, CNPJ
FROM Compras
WHERE Fornecedor IS NOT NULL


-- INSERTING DATA INTO SUPPLIER DIMENTION
INSERT INTO dim_fornecedores (Fornecedor, CNPJ)
SELECT DISTINCT Fornecedor, CNPJ
FROM Compras
WHERE Fornecedor IS NOT NULL

-- CREATING CLIENT DIMENTION
INSERT INTO dim_clientes (Cliente, CNPJ)
SELECT DISTINCT Cliente, CNPJ
FROM Receitas


-- INSERTING DATA INTO CLIENT DIMENTION
INSERT INTO dim_clientes (Cliente, CNPJ)
SELECT DISTINCT Cliente, CNPJ
FROM Receitas

-- CREATING TIME DIMENTION
CREATE TABLE Dim_Tempo (
    Data_ID         INT PRIMARY KEY,    -- 20260123
    Data            DATE,               -- 2026-01-23
    Ano             INT,                -- 2026
    Semestre        INT,                -- 1 ou 2
    Trimestre       INT,                -- 1 a 4
    Mes             INT,                -- 1 a 12
    Nome_Mes        VARCHAR(20),        -- Janeiro
    Mes_Ano         CHAR(7),            -- 2026-01
    Dia             INT,                -- 23
    Dia_Semana      INT,                -- 1=Seg - 7=Dom
    Nome_Dia        VARCHAR(3),         -- Se
    Semana_Ano      INT,                -- 4
    Fim_De_Semana   CHAR(1),            -- 'S' ou 'N'
    Feriado         CHAR(1)             -- 'S' ou 'N'
)


-- INSERTING DATA INTO TIME DIMENTION
DECLARE @DataInicio DATE = '2024-01-01';
DECLARE @DataFim    DATE = '2024-12-31';

;WITH Calendario AS (
    SELECT @DataInicio AS Data
    UNION ALL
    SELECT DATEADD(DAY, 1, Data)
    FROM Calendario
    WHERE Data < @DataFim
)
INSERT INTO dim_tempo (
    Data_ID,
    Data,
    Ano,
    Semestre,
    Trimestre,
    Mes,
    Nome_Mes,
    Ano_Mes,
    Dia,
    Dia_Semana,
    Nome_Dia,
    Semana_Ano,
    Fim_De_Semana
)
SELECT
    CONVERT(INT, FORMAT(Data, 'yyyyMMdd'))              AS Data_ID,
    Data,
    YEAR(Data)                                          AS Ano,
    CASE WHEN MONTH(Data) <= 6 THEN 1 ELSE 2 END        AS Semestre,
    DATEPART(QUARTER, Data)                             AS Trimestre,
    MONTH(Data)                                         AS Mes,
    DATENAME(MONTH, Data)                               AS Nome_Mes,
    FORMAT(Data, 'yyyy-MM')                             AS Ano_Mes,
    DAY(Data)                                           AS Dia,
    DATEPART(WEEKDAY, Data)                             AS Dia_Semana,
    LEFT(DATENAME(WEEKDAY, Data), 3)                    AS Nome_Dia,
    DATEPART(WEEK, Data)                                AS Semana_Ano,
    CASE 
        WHEN DATEPART(WEEKDAY, Data) IN (1,7) THEN 'S' 
        ELSE 'N' 
    END                                              AS Fim_De_Semana
FROM Calendario
OPTION (MAXRECURSION 0)