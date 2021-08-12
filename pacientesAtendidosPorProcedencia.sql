Select
    r.reg,
    (
        select nome
        from ricadpac p
        where r.pront = p.pront
            and r.otmu = p.otmu
            and r.tipopac = p.tipopac
    ) nome,
    r.pront,
    dt_ate,
    r.horas,
    r.conv || ' - ' ||     (
        select nome
        from tbconven
        where cod = r.conv
    ) nconv,
    ate_rep Retorno,
    r.crm,

    (
        select nome
        from tbprofis tp
            inner join tbcbopro tc on tp.id = tc.id_tbprofis
        where tc.id = r.id_tbcboprocrm
    ) medico,
    (
        select max(nome)
        from tbclinica
        where cod = r.clinica
    ) Clinica,

    (
        select nome
        from tbespec
        where cod = r.espec
    ) n_espec,

    case
    r.procedencia
        when '3' then 'HGL'
        when '21' then 'Policia Militar'
        when '22' then 'ECO 101'
        when '23' then 'BOMBEIRO'
        when '24' then 'SAMU'
        end  Poced
from recadate r
where r.dt_ate between :DataInical and :DataFinal
and r.procedencia in (03,21,22,23,24)
and pext = 'S'
order by dt_ate, Poced
