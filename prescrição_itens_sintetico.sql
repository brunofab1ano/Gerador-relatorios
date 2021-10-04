with cte as  (
select
    d.pac reg,
    ri.bloco,
    d.id_presc presc,
    p.data_hora_prescricao,
    p.data_hora_final_vigencia,
    ri.alta || ' : ' || ri.horasai Hora_alta,
    pro.nome n_medico_prescr,
    d.doc,
    d.data data_doc,
    d.cdc,
    classif,
    l.item,
    i.nome,
    l.qtde saida,
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
    --and ri.reg = 182124
GROUP BY
    d.pac,
    bloco,
    Hora_alta,
    p.data_hora_prescricao,
    p.data_hora_final_vigencia,
    n_medico_prescr,
    presc,
    d.doc,
    d.data,
    d.cdc,
    classif,
    l.item,
    i.nome ,
    saida
)

select
    distinct
    reg,
    bloco,
    presc,
    data_hora_prescricao,
    data_hora_final_vigencia,
    Hora_alta  ,
    n_medico_prescr,
    doc,
    data_doc,
    cdc,
    sum(saida) over(partition by doc) saida,
    sum(consumo) over(partition by doc) consumo,
    sum(saida) over(partition by doc) - sum(consumo) over(partition by doc) devolucao
from cte
--order by reg, bloco, presc, data_hora_prescricao, data_hora_final_vigencia, Hora_alta, n_medico_prescr, doc, data_doc, cdc, saida, consumo, devolucao
order by reg, presc, n_medico_prescr, data_hora_prescricao, data_hora_final_vigencia, Hora_alta
