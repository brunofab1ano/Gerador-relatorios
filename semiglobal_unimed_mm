select
    distinct
    R.COD ||' - '||
    (
        select NOME
        from TBMATMED
        where TAB = R.TAB
            and COD = R.COD
    ) NOMEMAT,
    R.CODREF ||' - '|| F.NOME NOMEREF,
    F.DATA,
    (
        select COD_TUSS
        from TBREFMEMTUSS Q
        where Q.TAB_FCREFUND = F.TAB
            and Q.COD_FCREFUND = F.COD
            and Q.CLASSIF_FCREFUND = F.CLASSIF
            and (DATA_VIGENCIA_INICIAL != '31.12.1899')
            and (DATA_VIGENCIA_FINAL >= :Data)
    ) COD_TUSS,
    case
        F.LABORA
        when 'MATERIAL ESPECIAL' then 'MATERIAL ESPECIAL COM AUTORIZAÇÃO'
        when 'MATERIAL ESPECIAL SEM' then 'MATERIAL ESPECIAL SEM AUTORIZAÇÃO'
        when 'ORTESES' then 'ORTESES COM AUTORIZAÇÃO'
        when 'ORTESES SEM AUTORIZACA' then 'ORTESES SEM AUTORIZAÇÃO'
        when 'PROTESES' then 'PROTESES COM AUTORIZAÇÃO'
    end CLASSIFICACAO
from TBREFUNI R
    inner join FCREFUND F on F.TAB = R.TAB
                        and R.CODREF = F.COD
    inner join TBMATMED T on R.ID_TBMATMED = T.ID
where R.TAB = :TAB
    and F.CLASSIF = :CLASS
    and F.DATA in (
        select max(FCREFUND.DATA)
        from FCREFUND
        where FCREFUND.COD = F.COD
            and FCREFUND.TAB = F.TAB
    )
    and F.LABORA in (
        'MATERIAL ESPECIAL',
        'MATERIAL ESPECIAL SEM',
        'ORTESES',
        'ORTESES SEM AUTORIZACA',
        'PROTESES'
    )
order by 5
