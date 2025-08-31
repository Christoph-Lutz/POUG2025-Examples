set lines 150 pages 999
col name for a30

select
   s.name name,
   m.value value
from
    v$mystat m,
    v$statname s
where
    s.statistic# = m.statistic#
and s.name = 'DML statements retried'
/

