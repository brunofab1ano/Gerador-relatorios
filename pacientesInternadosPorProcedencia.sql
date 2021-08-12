select
    i.reg,
        (
        select max(nome)
        from ricadpac
        where pront = i.pront
            and tipopac = 'I'
            and otmu = i.otmu
    ) paciente,
    i.pront,
    i.entrada,
    i.alta,
    (Select max(perm) from spperman(i.entrada, i.alta) ) permanen,
    ( select max(nome) from tbconven where cod = i.conv ) convenio,
    i.bloco || '-' || i.acomod || '-'  ||i.leito Acomodacao,
    (        select p.nome
        from tbprofis p
            inner join tbcbopro c on c.id_tbprofis = p.id
        where c.id = i.id_tbcbopromedsol
    ) Medico_Solicitante,
    (
        select max(nome)
        from tbclinica
        where cod = i.clinica
    ) Clinica,
    (
        select max(nome)
        from tbespec
        where cod = i.espec
    ) Especialidade,
     case
     i.procedencia
        when '3' then 'HGL'
        when '21' then 'PM'
        when '22' then 'ECO 101'
        when '23' then 'BOMB'
        when '24' then 'SAMU'
        end  Proced
from ricadint i
where i.entrada between :DataInical and :DataFinal
and i.procedencia in (03,21,22,23,24)
order by entrada, convenio,Proced
