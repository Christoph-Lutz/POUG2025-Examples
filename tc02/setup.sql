set echo on

drop table tc_restart purge;
create table tc_restart(n number not null, v varchar2(30));

insert into tc_restart select level n, null from dual connect by level <= 2;
insert into tc_restart values(3, 'HIGHVAL');
commit;

create index i_v_tc_restart on tc_restart(v);

exec dbms_stats.gather_table_stats(ownname=>user, tabname=>'TC_RESTART', cascade=>true, estimate_percent=>null);

create table t_array_update as select level n1, level n2 from dual connect by level <= 42;

exec dbms_stats.gather_table_stats(ownname=>user, tabname=>'T_ARRAY_UPDATE', cascade=>true, estimate_percent=>null);

drop package pkg_tc_restart_02;
@pkg_tc_restart_02.sql

@reset.sql
