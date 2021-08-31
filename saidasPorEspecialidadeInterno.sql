select D.PAC REG,
    CP.NOME nome_paciente,
    TBC.COD || ' - ' || TBC.NOME,
    --TBC.COD || ' - ' || TBC.NOME,
    TB.NOME CLINICA,
    TBE.NOME ESPECIALIDADE,
    PR.NOME MEDICO,
    (
        select sum(
                (
                    select VLRMED
                    from SPVLRMED(G.ITEM, g.qtde, 0)
                )
            )
        from GELANPAC G
        where G.REG = D.pac
            and G.TIPO = 'I'
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
    inner join GELANSAI L on D.DOC = L.DOC
    and D.ANO = L.ANO
    and D.MES = L.MES
    inner join GEITENS I on L.ITEM = I.COD
    inner join RICADINT J on D.PAC = J.REG
    inner join RICADPAC CP on J.PRONT = CP.PRONT
    inner join TBCLINICA TB on J.CLINICA = TB.COD
    inner join TBESPEC TBE on J.ESPEC = TBE.COD
    inner join TBCONVEN TBC on D.CONV = TBC.COD
    inner join TBPROFIS PR on J.MEDSOL = PR.CNPJ_CPF
where --D.PAC = 185688     and
    L.CONSOL = 'T'
    and d.conv = :Conv
    and d.data between :DtInicial and :DtFinal
group by 1,
    2,
    3,
    4,
    5,
    6,
    7
