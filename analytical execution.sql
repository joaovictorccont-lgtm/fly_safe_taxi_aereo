-- ANÁLISE EXPLORATÓRIA DAS TABELAS
EXEC sp_help 'nome_tabela' -- ideal fazer para cada uma das tabelas

SELECT COUNT(*) AS total_linhas
FROM nome_tabela -- ideal fazer para cada uma das tabelas

-- a) Quais pagamentos foram aprovados pela mesma pessoa que registrou?
SELECT
    numero_nf,
    valor_pago,
    aprovador,
    registrador
FROM fato_pagamentos AS pag
WHERE aprovador = registrador

-- além disso, incluí um indicador de “maiores ofensores”, onde podemos verificar o quantitativo de “autoaprovação” de notas fiscais por usuário registrador
SELECT
registrador,
COUNT(*) AS qtd_autoaprovacoes
FROM fato_pagamentos AS pag
WHERE aprovador = registrador
GROUP BY registrador
ORDER BY qtd_autoaprovacoes DESC

-- b) Quais pagamentos foram feitos para fornecedores sem contrato ativo?
SELECT *
FROM (
    SELECT 
        com.numero_nf, 
        com.valor AS valor_compra, 
        pag.data_id, 
        pag.forma_pagamento, 
        pag.valor_pago, 
        tem.data AS data_pagamento, 
        cont.fornecedor,
        CASE 
            WHEN GETDATE() BETWEEN cont.data_inicio AND cont.data_fim 
                THEN 'Vigente'
            ELSE 'Vencido'
        END AS status_contrato
    FROM fato_compras AS com
    LEFT JOIN fato_pagamentos AS pag 
        ON com.numero_nf = pag.numero_nf
    LEFT JOIN dim_contratos AS cont 
        ON com.fornecedor_id = cont.fornecedor_id
    LEFT JOIN dim_tempo AS tem 
        ON pag.data_id = tem.data_id
    ) AS base_subquery
WHERE status_contrato = 'Vencido'

-- c) Quais fornecedores estão duplicados (mesmo nome com CNPJs diferentes)?
SELECT 
    fornecedor,
    cnpj,
    COUNT(fornecedor) AS qtd_registros_forn
FROM dim_fornecedor
WHERE fornecedor IN
    (
    SELECT fornecedor
    FROM dim_fornecedor
    GROUP BY fornecedor
    HAVING COUNT(DISTINCT cnpj) > 1
    )
GROUP BY fornecedor, cnpj
HAVING COUNT (fornecedor) > 1

-- após verificar ,ais a fundo o resultado acima, percebi que a QUERY não detecta casos de fornecedores iguais com escritas diferentes, portanto, tivemos que normalizar a coluna fornecedor
SELECT 
    fornecedor,
    cnpj,
    COUNT(*) OVER(PARTITION BY fornecedor COLLATE Latin1_General_CI_AI) AS qtd_registros_forn
FROM dim_fornecedor
WHERE fornecedor COLLATE Latin1_General_CI_AI IN
	(
    SELECT fornecedor COLLATE Latin1_General_CI_AI
    FROM dim_fornecedor
    GROUP BY fornecedor COLLATE Latin1_General_CI_AI
    HAVING COUNT(DISTINCT cnpj) > 1
	)

-- d) Quais notas fiscais possuem imposto calculado diferente do imposto correto? Mostre o valor das diferenças; ranqueie da maior diferença para a menor.
SELECT *, (imposto_correto  - imposto_calculado) AS diferenca_imposto
FROM fato_compras
WHERE (imposto_correto  - imposto_calculado) <> '0'
ORDER BY (imposto_correto  - imposto_calculado) DESC

-- e) Qual a quantidade e valor de manutenções preventivas e corretivas no período? Adicione a comparação da manutenção preventiva  - corretiva para quantidade e valor? 
-- 1ª pergunta:
SELECT
	tipo,
	COUNT (*)   AS qtd_manut,  -- somatorio da quantidade de registros
	SUM (custo) AS custo_total_manut  -- somatorio do custo total de manutencao
FROM fato_manutencao
GROUP BY tipo

-- 2ª pergunta:
SELECT
    tipo,
    COUNT (*)   AS qtd_manutencoes, -- somatorio da quantidade de registros
    SUM(custo)  AS custo_total_manut, -- somatorio do custo total de manutencao
    ROUND
        (
        (SUM(custo) / SUM (SUM (custo)) OVER()) * 100,
        2) AS percentual_custo -- representação percentual de cada tipo de manutencao
FROM fato_manutencao
GROUP BY tipo

-- f) Quais receitas foram contratadas, mas não faturadas integralmente? Apresente a porcentagem faturada e o valor restante a ser faturado
SELECT
    *,
    (valor_contratado  - valor_faturado)            AS valor_a_faturar,
    ROUND
    (
    ((valor_faturado / valor_contratado) * 100),
    2)  AS percentual_faturado
FROM fato_receitas
WHERE (valor_contratado  - valor_faturado) <> '0'
ORDER BY (valor_contratado  - valor_faturado)

-- adicional: verificar, na tabela fato “fato_compras”, se há registros de compras com “Numero_NF” duplicados
-- analisar se o resultado se trata de um registro duplicado da compra (como um todo) ou se foi apenas um erro no registro da nota fiscal
-- mostrar quantas vezes cada nota fiscal repetida aparece (se se ela se repete 2, 3 ou mais vezes)
SELECT
    *,
    COUNT(*) OVER (PARTITION BY numero_nf) AS qtd_total_nf
FROM fato_compras
WHERE numero_nf IN
    (
    SELECT numero_nf
    FROM fato_compras
    GROUP BY numero_nf
    HAVING COUNT (*) > 1
    )
ORDER BY numero_nf