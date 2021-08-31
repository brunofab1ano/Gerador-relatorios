with CTE AS (

SELECT DISTINCT
    C.COD,
    C.PACIENTE,
    C.CON || '-' || T.NOME CONVENIO,
    cli.nome CLINICA,
    ESP.nome ESPECIALIDADE ,
    e.nome_med medico,

    --Serviço Hospitalar faturamento
    (
        SELECT COALESCE(SUM(LLL.VALOR_C),0) TOTAL

        FROM FCLANEXT LLL

        WHERE lll.id_fcctaext = c.id
        AND LLL.TIPO = 1
    ) SH ,

    --Serviço PROFISSIONAL
    (
        SELECT COALESCE(SUM(LLL.VALOR_C),0) TOTAL
        FROM FCLANEXT LLL
        WHERE lll.id_fcctaext = c.id
        AND LLL.TIPO = 2
    ) SP,

    --RECURSO COMPLEMENTAR
    (
        SELECT COALESCE(SUM(LLL.VALOR_C),0) TOTAL
        FROM FCLANEXT LLL
        WHERE lll.id_fcctaext = c.id
        AND LLL.TIPO = 3
    ) RC,

    -- MAT/MED FATURAMENTO
    (
        SELECT COALESCE(SUM(LLL.VALOR_C),0) TOTAL
        FROM FCLANEXT LLL
        WHERE lll.id_fcctaext = c.id
        AND LLL.TIPO = 4
    ) MM ,

    (SELECT
        SUM (
            (
            (L.QTDE) - COALESCE(
                SUM(
                    (
                        SELECT SUM(QTDE)
                        FROM GECADDEV CD
                            INNER JOIN GELANDEV LD ON CD.ID = LD.ID_GECADDEV
                        WHERE L.ID_GELANSAI = LD.ID_GELANSAI
                            AND LD.CONSOL = 'T'
                    )
                ),
                0
            )
        ) * (
    SELECT VALOR1
    FROM SPBRAVEN(5, L.ITEM, C.data_emi, 1)
) * (CASE WHEN i.classif = 2 THEN (1.10) WHEN i.classif = 1 THEN (0.60) ELSE (1) END))


    FROM GECADSAI D
        INNER JOIN GELANSAI L ON D.DOC = L.DOC
                                AND D.ANO = L.ANO
                                AND D.MES = L.MES
        INNER JOIN GEITENS I ON L.ITEM = I.COD
    WHERE L.CONSOL = 'T'
        AND D.CONV = c.con
        AND D.PAC = c.reg_ate
) vl_MM



    
FROM FCCTAEXT C
    --INNER JOIN FCLANEXT L ON C.ID = L.ID_FCCTAEXT
    iNNER JOIN TBCONVEN T ON (T.COD = C.CON)
    INNER JOIN RECADATE E ON E.REG = C.REG_ATE
    INNER JOIN TBCLINICA CLI ON E.clinica = CLI.cod
    INNER JOIN tbespec ESP ON E.espec = ESP.cod
WHERE --c.reg_ate = 1640811 and
    C.IND_EMI = 'T'
    AND C.ANOPRO = 2021
    AND C.MESPRO = 05
     AND C.TIPO_CTA = 'E'
    AND C.CON IN (12,85)
    AND E.CDC = 218

)

SELECT
cod,
paciente,
convenio,
CLINICA,
especialidade,
medico,
sh,
sp,
rc,
mm,
COALESCE (CAST (SUM (vl_MM) OVER(PARTITION BY cod) AS DECIMAL(18,2)),0) vL_Estoque
FROM cte
