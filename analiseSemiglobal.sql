WITH cte AS (
SELECT DISTINCT
    C.COD,
    C.PACIENTE,
    C.CON || '-' || T.NOME CONVENIO,
    (
        SELECT AA.NOME
        FROM TBCLINICA AA
        WHERE AA.COD = E.CLINICA
    ) CLINICA,
    (
        SELECT BB.NOME
        FROM TBESPEC BB
        WHERE BB.COD = E.ESPEC
    ) ESPECIALIDADE,

    e.nome_med medico,

    --Lista Serviço Hospitalar Lançaddo dentro do faturamento
    (
        SELECT COALESCE(SUM(LLL.VALOR_C),0) TOTAL
        FROM FCCTAEXT CCC
            LEFT JOIN FCLANEXT LLL ON CCC.ID = LLL.ID_FCCTAEXT
        WHERE CCC.REG_ATE = C.REG_ATE
            AND (
                (
                    CCC.ANOPRO = C.ANOPRO
                    AND CCC.MESPRO = C.MESPRO
                )
            )
            AND CCC.TIPO_CTA = 'E'
            AND LLL.TIPO = 1
    ) SH,
    
        --Lista Serviço Profissional
    (
        SELECT COALESCE(SUM(LLL.VALOR_C),0)
        FROM FCCTAEXT CCC
            LEFT JOIN FCLANEXT LLL ON CCC.ID = LLL.ID_FCCTAEXT
        WHERE CCC.REG_ATE = C.REG_ATE
            AND (
                (
                    CCC.ANOPRO = C.ANOPRO
                    AND CCC.MESPRO = C.MESPRO
                )
            )
            AND CCC.TIPO_CTA = 'E'
            AND LLL.TIPO = 2
    ) SP,

        (
        SELECT COALESCE(SUM(LLL.VALOR_C),0)
        FROM FCCTAEXT CCC
            LEFT JOIN FCLANEXT LLL ON CCC.ID = LLL.ID_FCCTAEXT
        WHERE CCC.REG_ATE = C.REG_ATE
            AND (
                (
                    CCC.ANOPRO = C.ANOPRO
                    AND CCC.MESPRO = C.MESPRO
                )
            )
            AND CCC.TIPO_CTA = 'E'
            AND LLL.TIPO = 3
    ) RC,

         --Lista Recurso complementar
    (
        SELECT COALESCE(SUM(LLL.VALOR_C),0)
        FROM FCCTAEXT CCC
            LEFT JOIN FCLANEXT LLL ON CCC.ID = LLL.ID_FCCTAEXT
        WHERE CCC.REG_ATE = C.REG_ATE
            AND (
                (
                    CCC.ANOPRO = C.ANOPRO
                    AND CCC.MESPRO = C.MESPRO
                )
            )
            AND CCC.TIPO_CTA = 'E'
            AND LLL.TIPO = 4
    ) MM,

    --Calcular valor com base na saida do estoque (saidas - devoluções) * preço de tabela
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
    FROM SPBRAVEN(5, L.ITEM, fc.data_emi, 1)
) * (CASE WHEN i.classif = 2 THEN (1.10) WHEN i.classif = 1 THEN (0.60) ELSE (1) END))


    FROM GECADSAI D
        INNER JOIN RECADATE A ON D.PAC = A.REG
        INNER JOIN GELANSAI L ON D.DOC = L.DOC
                                AND D.ANO = L.ANO
                                AND D.MES = L.MES
        INNER JOIN GEITENS I ON L.ITEM = I.COD
        INNER JOIN RICADPAC CP ON A.PRONT = CP.PRONT
        INNER JOIN fcctaext fc ON a.reg = fc.cod
    WHERE L.CONSOL = 'T'
        AND D.CONV = c.con
        AND D.PAC = c.reg_ate
        AND CHAR_LENGTH(D.PAC) > 6
        AND A.PEXT = 'S'
) vl_MM




FROM FCCTAEXT C
    LEFT JOIN FCLANEXT L ON C.ID = L.ID_FCCTAEXT
    LEFT JOIN TBCONVEN T ON (T.COD = C.CON)
    LEFT JOIN RECADATE E ON E.REG = C.REG_ATE
WHERE --C.REG_ATE = 1640811 AND
    C.IND_EMI = 'T'
    AND (
        (
            C.ANOPRO = 2021
            AND C.MESPRO = 05
        )
    )
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
