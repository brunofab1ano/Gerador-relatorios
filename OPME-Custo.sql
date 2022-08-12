select * from

( select
    'Faturado' tipo,
    aa.cod aih ,
    '' doc,
    aa.regint regint,
    dd.codsus item,
    dd.NOME desc_item,
    aa.pac paciente,
    aa.data_fec data,
    aa.mes,
    (select tbprosus.nome from tbprosus where aa.prosol = tbprosus.id) procPrincipal,
    cc.qtde,
   (
        select  max(vlsus.valor_sh)
        from tbprosus prosus
        inner join tbvlrsus vlsus on (prosus.id = vlsus.id_tbprosus)
        where prosus.codsus = dd.codsus
        and extract(month from vlsus.data) = extract(month from bb.data)
        and extract(year from vlsus.data) = extract(year from bb.data)
    )vl_unit,
    cc.qtde * (
        select  max(vlsus.valor_sh)
        from tbprosus prosus
        inner join tbvlrsus vlsus on (prosus.id = vlsus.id_tbprosus)
        where prosus.codsus = dd.codsus
        and extract(month from vlsus.data) = extract(month from bb.data)
        and extract(year from vlsus.data) = extract(year from bb.data)
    ) valorTotal,
    0 ref,
    '' ref_sus,
    '' desc_sus,
    0 vl_Fat,
    0 vl_Saidas
from fhcadaih aa
   inner join fhlancto bb on (aa.id = bb.id_fhcadaih)
   inner join fhlanopm cc on (bb.id = cc.id_fhlancto)
   left join tbprosus dd on (cc.id_material = dd.id)
where --aa.cod = '3222102982330' and
    aa.mes = :mes and
    aa.ano = :ano and
    aa.prosol in ( 2006,2182,2283,2329,2330,2723,3374,3397,3398,3423)


union all

select
    'Saidas' tipo ,
    d.conta aih,
    d.doc ,
    pac REGINT,
    L.ITEM ITEM,
    I.nome desc_item,
    (select ricadpac.nome from ricadpac where ricadpac.id =d.id_ricadpac) paciente,
    d.data data,
    d.mes,
    '' procPrincipal ,
    l.qtde,
    case when i.vlrmed = 0 then i.vlr_unf else i.vlrmed end vl_unit,
    case when i.vlrmed = 0 then i.vlr_unf * l.qtde else i.vlrmed * l.qtde end   valorTotal,
    i.ref, 
    (select tbprosus.codsus from tbprosus where tbprosus.id = i.id_medespaih) ref_sus,
    ( select tbprosus.nome from tbprosus where tbprosus.id = i.id_medespaih) desc_sus ,
    0 vl_Fat,
    0 vl_Saidas
from GECADSAI D
    inner join GELANSAI L on D.DOC = L.DOC
                        and D.ANO = L.ANO
                        and D.MES = L.MES
    inner join GEITENS I on L.ITEM = I.COD


where L.CONSOL = 'T' and
    exists  (
        select DISTINCT
        aaa.regint
    from fhcadaih aaa
    inner join fhlancto bbb on (aaa.id = bbb.id_fhcadaih)
    inner join fhlanopm ccc on (bbb.id = ccc.id_fhlancto)
    where   aaa.mes = :mes and
            aaa.ano = :ano and
            aaa.pac = ( select ricadpac.nome from ricadpac where ricadpac.id =d.id_ricadpac) and
            aaa.prosol in ( 2006,2182,2283,2329,2330,2723,3374,3397,3398,3423)) and
    --d.pac = 196809 and
    i.ref in (5) and
    d.ano = :ano

union all

select
    distinct
    'Saidas' TIPO,
    '' aih,
    '' doc,
    '' REGINT,
    '' ITEM,
    '' desc_item,
    (select ricadpac.nome from ricadpac where ricadpac.id =d.id_ricadpac) paciente,
    '' data,
    '' mes,
    '' procPrincipal,
    '' qtd,
    0 vl_unit,
    0 valorTotal,
    '' ref,
    '' ref_sus,
    '' desc_sus,
    (


     select distinct
    SUM (cc.qtde * (
        select  max(vlsus.valor_sh)
        from tbprosus prosus
        inner join tbvlrsus vlsus on (prosus.id = vlsus.id_tbprosus)
        where prosus.codsus = dd.codsus
        and extract(month from vlsus.data) = extract(month from bb.data)
        and extract(year from vlsus.data) = extract(year from bb.data)
    )) over( partition by aa.pac) valorTotal
from fhcadaih aa
   inner join fhlancto bb on (aa.id = bb.id_fhcadaih)
   inner join fhlanopm cc on (bb.id = cc.id_fhlancto)
   left join tbprosus dd on (cc.id_material = dd.id)
where --aa.regint = 196213 AND
        aa.mes = :mes and
        aa.ano = :ano and
        aa.prosol in ( 2006,2182,2283,2329,2330,2723,3374,3397,3398,3423) and
        aa.pac = ( select ricadpac.nome from ricadpac where ricadpac.id =d.id_ricadpac)


    ) vl_Fat,
    cast (sum (case when i.vlrmed = 0 then i.vlr_unf * l.qtde else i.vlrmed * l.qtde end) over( partition by d.pac, 'Saidas' ) as numeric (18,2))vl_Saidas


from GECADSAI D
    inner join GELANSAI L on D.DOC = L.DOC
                        and D.ANO = L.ANO
                        and D.MES = L.MES
    inner join GEITENS I on L.ITEM = I.COD

where L.CONSOL = 'T' and
    exists
        (
            select DISTINCT
                    aaa.regint
            from fhcadaih aaa
            inner join fhlancto bbb on (aaa.id = bbb.id_fhcadaih)
            inner join fhlanopm ccc on (bbb.id = ccc.id_fhlancto)
            where   aaa.mes = :mes and
                    aaa.ano = :ano and
                    aaa.pac = ( select ricadpac.nome from ricadpac where ricadpac.id =d.id_ricadpac) and
                    aaa.prosol in ( 2006,2182,2283,2329,2330,2723,3374,3397,3398,3423)
        )
    and i.ref in (5)
    and d.ano = :ano
)
order by PACIENTE, AIH, REGINT, TIPO
