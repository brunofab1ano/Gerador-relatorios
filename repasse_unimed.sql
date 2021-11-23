select
cod,
paciente,
convenio,
CLINICA,
especialidade,
sh as F_SH,
sp as f_sp,
rc as f_rc,
mm  as f_mm,
VALOR_SEMI_GLOBAL,
CRM_MEDICO,
TX_ABERTA as a_sh,
sp as a_sp,
rc as a_rc,


vL_Estoque as a_mm,
sum (vL_Estoque + SP + RC + TX_ABERTA ) over(partition by cod) VALOR_CONTA_ABERTA,

iif (CRM_MEDICO != 19,sp, 0 ) repasse


from (
with CTE as (

select distinct
    C.COD,
    C.PACIENTE,
    C.CON || '-' || T.NOME CONVENIO,
    cli.nome CLINICA,
    ESP.nome ESPECIALIDADE ,
    C.med_sol,

    --Serviço Hospitalar faturamento
    (
        select coalesce(sum(LLL.VALOR_C),0) TOTAL

        from FCLANEXT LLL

        where lll.id_fcctaext = c.id
        and LLL.TIPO = 1
    ) SH ,

    --Serviço PROFISSIONAL
    (
        select coalesce(sum(LLL.VALOR_C),0) TOTAL
        from FCLANEXT LLL
        where lll.id_fcctaext = c.id
        and LLL.TIPO = 2
    ) SP,

    --RECURSO COMPLEMENTAR
    (
        select coalesce(sum(LLL.VALOR_C),0) TOTAL
        from FCLANEXT LLL
        where lll.id_fcctaext = c.id
        and LLL.TIPO = 3
    ) RC,

    -- MAT/MED FATURAMENTO
    (
        select coalesce(sum(LLL.VALOR_C),0) TOTAL
        from FCLANEXT LLL
        where lll.id_fcctaext = c.id
        and LLL.TIPO = 4
    ) MM ,

    (select
        sum (
            (
            (L.QTDE) - coalesce(
                sum(
                    (
                        select sum(QTDE)
                        from GECADDEV CD
                            inner join GELANDEV LD on CD.ID = LD.ID_GECADDEV
                        where L.ID_GELANSAI = LD.ID_GELANSAI
                            and LD.CONSOL = 'T'
                    )
                ),
                0
            )
        ) * (
    select VALOR1
    from SPBRAVEN(5, L.ITEM, C.data_emi, 1)
) * (case when i.classif = 2 then (1.10) when i.classif = 1 then (0.60) else (1) end))


    from GECADSAI D
        inner join GELANSAI L on D.DOC = L.DOC
                                and D.ANO = L.ANO
                                and D.MES = L.MES
        inner join GEITENS I on L.ITEM = I.COD
    where L.CONSOL = 'T'
        and D.CONV = c.con
        and D.PAC = c.reg_ate
) vl_MM,


    (
        select  first 1 ( COD)
        from FCLANEXT LLL
        inner join TBCBOPRO on LLL.id_tbcbopro_titular = TBCBOPRO.id
        where lll.id_fcctaext = c.id
        and LLL.TIPO = 2
    ) CRM_MEDICO  ,


    (
        select
        5
        from FCLANEXT LLL
        where lll.id_fcctaext = c.id
        and LLL.TIPO =1
        and LLL.procto = 830
        )
        TX_ABERTA




    
from FCCTAEXT C
    --INNER JOIN FCLANEXT L ON C.ID = L.ID_FCCTAEXT
    inner join TBCONVEN T on (T.COD = C.CON)
    inner join RECADATE E on E.REG = C.REG_ATE
    inner join TBCLINICA CLI on E.clinica = CLI.cod
    inner join tbespec ESP on E.espec = ESP.cod
where --c.reg_ate = 1640811 and
    C.IND_EMI = 'T'
    and C.ANOPRO = 2021
    and C.MESPRO between 09 and 9
    --AND E.dt_ate = '01.09.2021'
    and C.TIPO_CTA = 'E'
    and C.CON in (12,85)
    and E.CDC = 218

)

select
cod,
paciente,
convenio,
CLINICA,
especialidade,
sh,
sp,
rc,
mm ,
coalesce (cast (sum (SH+SP+RC+MM ) over(partition by cod) as decimal(18,2)),0) VALOR_SEMI_GLOBAL,
CRM_MEDICO,
coalesce (TX_ABERTA, 0) TX_ABERTA,
coalesce (cast (sum (vl_MM) over(partition by cod) as decimal(18,2)),0) vL_Estoque
--COALESCE (CAST (SUM (TX_ABERTA + SP + RC) OVER(PARTITION BY cod) AS DECIMAL(18,2)),0) AAAA
from cte
)



/*SELECT
    coalesce (5,'0')

FROM fcctaext a
inner join FCLANEXT LLL on LLL.id_fcctaext  = a.id
WHERE a.reg_ate = 1666673
AND LLL.TIPO =1
aND LLL.procto = 830
and a.anopro = 2021
and a.mespro = 09*/
