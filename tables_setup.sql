-- ADDING FK COLUMN
ALTER TABLE dim_contratos
ADD Fornecedor_ID INT


-- INSERTING DATA INTO SUPPLIER FK COLUMN (Fornecedor_ID) OF DIM_CONTRATOS
UPDATE con
SET con.Fornecedor_ID = forn.Fornecedor_ID
FROM dim_contratos AS con
INNER JOIN dim_fornecedor AS forn
ON con.CNPJ = forn.CNPJ

-- ADDING FK COLUMNS
ALTER TABLE fato_compras
ADD Fornecedor_ID INT

ALTER TABLE fato_compras
ADD Data_ID INT


-- INSERTING DATA INTO SUPPLIER FK COLUMN (Fornecedor_ID) OF DIM_COMPRAS
UPDATE com
SET com.Fornecedor_ID = forn.Fornecedor_ID
FROM fato_compras AS com
INNER JOIN dim_fornecedor AS forn
ON com.CNPJ = forn.CNPJ


-- INSERTING DATA INTO DATE FK COLUMN (DATA_ID) OF DIM_COMPRAS
UPDATE com
SET com.Data_ID = tem.Data_ID
FROM fato_compras AS com
INNER JOIN dim_tempo AS tem
ON com.Data = tem.Data


-- DELETING OLD COLUMNS FROM FATO_COMPRAS
ALTER TABLE fato_compras
DROP COLUMN fornecedor

ALTER TABLE fato_compras
DROP COLUMN CNPJ

ALTER TABLE fato_compras
DROP COLUMN Data

-- ADDING FK COLUMN
ALTER TABLE fato_manutencao
ADD Data_ID INT


-- INSERTING DATA INTO DATE FK COLUMN (DATA_ID) OF FATO_MANUTENCAO
UPDATE manut
SET manut.Data_ID = tem.Data_ID
FROM fato_manutencao AS manut
INNER JOIN dim_tempo AS tem
ON manut.Data = tem.Data


-- DELETING OLD COLUMN FROM FATO_MANUTENCAO
ALTER TABLE fato_manutencao
DROP COLUMN Data

-- ADDING FK COLUMNS
ALTER TABLE fato_pagamentos
ADD Fornecedor_ID INT

ALTER TABLE fato_pagamentos
ADD Data_ID INT


-- INSERTING DATA INTO SUPPLIER FK COLUMN (FORNECEDOR_ID) OF FATO_PAGAMENTOS
UPDATE pag
SET pag.Fornecedor_ID = com.Fornecedor_ID
FROM fato_pagamentos AS pag
INNER JOIN fato_compras AS com
ON pag.Numero_NF = com.Numero_NF

-- INSERTING DATA INTO DATE FK COLUMN (DATA_ID) OF FATO_PAGAMENTOS
UPDATE pag
SET pag.Data_ID = tem.Data_ID
FROM fato_pagamentos AS pag
INNER JOIN dim_tempo AS tem
ON pag.Data = tem.Data


-- DELETING OLD COLUMN FROM FATO_PAGAMENTOS
ALTER TABLE fato_pagamentos
DROP COLUMN Data

-- ADDING FK COLUMNS
ALTER TABLE fato_receitas
ADD Cliente_ID INT

ALTER TABLE fato_receitas
ADD Data_ID INT


-- INSERTING DATA INTO CLIENT FK COLUMN (CLIENTE_ID) OF FATO_RECEITAS
UPDATE rec
SET rec.Cliente_ID = dim_cli.Cliente_ID
FROM fato_receitas AS rec
INNER JOIN dim_clientes AS dim_cli
ON rec.CNPJ = dim_cli.CNPJ


-- INSERTING DATA INTO DATE FK COLUMN (DATA_ID) OF FATO_RECEITAS
UPDATE rec
SET rec.Data_ID = tem.Data_ID
FROM fato_receitas AS rec
INNER JOIN dim_tempo AS tem
ON rec.Data = tem.Data


-- DELETING OLD COLUMN FROM FATO_RECEITAS
ALTER TABLE fato_receitas
DROP COLUMN Cliente

ALTER TABLE fato_receitas
DROP COLUMN CNPJ

ALTER TABLE fato_receitas
DROP COLUMN Data