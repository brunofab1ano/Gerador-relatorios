select D.PAC REG,
    CP.NOME nome_paciente,
    TBC.COD,
    TBC.NOME,
    a.crm,
    a.dt_ate,
    TB.NOME CLINICA,
    TBE.NOME ESPECIALIDADE,
    (
        select sum(
                (
                    select VLRMED
                    from SPVLRMED(G.ITEM, g.qtde, 0)
                )
            )
        from GELANPAC G
        where G.REG = D.pac
            and G.TIPO = 'E'
    ) lanc,
    sum(L.VLRMED) - coalesce(
        sum(
            (
                select sum(LD.VLRMED)
                from GECADDEV CD
                    inner join GELANDEV LD on CD.ID = LD.ID_GECADDEV
                where L.ID_GELANSAI = LD.ID_GELANSAI
                    and LD.CONSOL = 'T'
            )
        ),
        0
    ) saidas
from GECADSAI D
    INNER JOIN recadate A ON D.pac = A.reg
    inner join GELANSAI L on D.DOC = L.DOC
    and D.ANO = L.ANO
    and D.MES = L.MES
    inner join GEITENS I on L.ITEM = I.COD
    inner join RICADPAC CP on a.PRONT = CP.PRONT
    inner join TBCLINICA TB on a.CLINICA = TB.COD
    inner join TBESPEC TBE on a.ESPEC = TBE.COD
    inner join TBCONVEN TBC on D.CONV = TBC.COD
where L.CONSOL = 'T'
    and d.conv = :conv
    and d.data between :dataInicial and :dataFinal
    AND CHAR_LENGTH(d.pac) > 6
    AND A.PEXT = 'S'
group by 1,
    2,
    3,
    4,
    5,
    6,
    7,
    8
ORDER BY nome_paciente
