with cte as  (
select
    d.pac reg,
    ri.bloco,
    d.dest,
    case
    d.dest
    when '1' then 'Saida para Paciente interno'
    when '3' then 'Saida para Externo '
   end Destino,
    d.id_presc presc,
    p.data_hora_prescricao,
    p.data_hora_final_vigencia,
    ri.alta || ' : ' || ri.horasai Hora_alta,
    pro.nome n_medico_prescr,
    d.ano,
    d.mes,
    d.doc,
    d.data data_doc,
    d.cdc,
    classif,
    l.item,
    i.nome,
    l.qtde qt_Item_saida,
    sum(l.qtde) - coalesce(
        sum(
            (
                select sum(qtde)
                from gecaddev cd
                    inner join gelandev ld on cd.id = ld.id_gecaddev
                WHERE l.id_gelansai = ld.id_gelansai
                    AND ld.consol = 'T'
            )
        ),
        0
    ) as consumo


from gecadsai d
    left join ricadint ri on ri.reg = d.pac
    left join prpresc p on (d.id_presc = p.id)
    left join tbcbopro cbo on (p.id_tbcbopro_prescricao = cbo.id)
    left join tbprofis pro on (cbo.id_tbprofis = pro.id)
    inner join gelansai l on d.doc = l.doc
    and d.ano = l.ano
    and d.mes = l.mes
    inner join geitens i on l.item = i.cod --where d.pac between ? and ? and d.dest=?
    --and d.arm between ? and ?
    --and d.cdc between ? and ?
    and d.data >= '01.01.2021'
    and l.consol = 'T'
    and d.dest != 2
    and p.data_hora_prescricao > ri.alta
    and ri.alta != '30.12.1899'
GROUP BY
    d.pac,
    bloco,
    d.dest,
    Destino,
    Hora_alta,
    p.data_hora_prescricao,
    p.data_hora_final_vigencia,
    n_medico_prescr,
    presc,
    d.ano,
    d.mes,
    d.doc,
    d.data,
    d.cdc,
    classif,
    l.item,
    i.nome ,
    qt_Item_saida
)

select
    reg,
    bloco,
    dest,
    Destino,
    presc,
    data_hora_prescricao,
    data_hora_final_vigencia,
    Hora_alta  ,
    n_medico_prescr,
    ano,
    mes,
    doc,
    data_doc,
    cdc,
    classif,
    item,
    nome,
    qt_Item_saida,
    consumo,
    qt_Item_saida -  consumo devol
from cte
