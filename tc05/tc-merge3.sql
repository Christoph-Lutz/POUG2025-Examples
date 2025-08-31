set echo on
set lines 200 pages 999

drop table t_src purge;
create table t_src (n1 number, n2 number);

insert into t_src values(1,1);
insert into t_src values(1,2);
commit;

exec dbms_stats.gather_table_stats(ownname=>user, tabname=>'T_SRC', cascade=>true, estimate_percent=>null);

drop table t_tgt purge;
create table t_tgt (n1 number, n2 number);

insert into t_tgt select level n, null from dual connect by level <= 500000;
-- insert into t_tgt values(1,0);
commit;

exec dbms_stats.gather_table_stats(ownname=>user, tabname=>'T_TGT', cascade=>true, estimate_percent=>null);

-- Enable HCC
alter table t_tgt move compress for query low;
-- alter table t_tgt move compress for query high;
-- alter table t_tgt move compress for archive low;
-- alter table t_tgt move compress for archive high;

col table_name for a30
col compresson for a20
col cmpress_for a20
select table_name, compression, compress_for from dba_tables where table_name = 'T_TGT';

select * from t_src;

merge /*+ gather_plan_statistics */ into t_tgt t 
using t_src s on (s.n1 = t.n1)
when matched then update set t.n2 = s.n2;

select * from table(dbms_xplan.display_cursor(format=>'ALLSTATS LAST'));

rollback;
