set echo on

drop table tc_restart purge;

create table tc_restart(n number not null, v varchar2(30));

insert into tc_restart select level n, null from dual connect by level <= 3;
insert into tc_restart values(4, 'HIGHVAL');
commit;

-- create index i_n_tc_restart on tc_restart(n);
create index i_v_tc_restart on tc_restart(v);

exec dbms_stats.gather_table_stats(ownname=>user, tabname=>'TC_RESTART', cascade=>true, estimate_percent=>null);

drop package pkg_tc_restart_04;
@pkg_tc_restart_04.sql

@reset.sql
