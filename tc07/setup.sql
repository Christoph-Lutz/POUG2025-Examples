set echo on

drop table tc_restart purge;

create table tc_restart (n number not null, v varchar2(30)) partition by list(n)
(
    partition p1 values(1),
    partition p2 values(2),
    partition p3 values(3),
    partition p4 values(4),
    partition p5 values(5),
    partition p6 values(6)
)
enable row movement;

insert into tc_restart select level n, null from dual connect by level <= 4;
insert into tc_restart values(5, 'HIGHVAL');
commit;


create index i_n_tc_restart on tc_restart(n) local;

exec dbms_stats.gather_table_stats(ownname=>user, tabname=>'TC_RESTART', estimate_percent=>null, no_invalidate=>false, granularity=>'global and partition');

drop package pkg_tc_restart_07
@pkg_tc_restart_07.sql

set lines 220 pages 999
col table_name for a30
select table_name, num_rows, blocks, last_analyzed from user_tables where table_name = 'TC_RESTART';

col table_name for a30
col partition_name for a30
col segment_created for a16
select 
  table_name, 
  partition_name, 
  num_rows, 
  segment_created, 
  pct_free 
from 
  user_tab_partitions 
where 
  table_name = 'TC_RESTART'
/

col index_owner for a20
col index_name for a20
col partition_name for a20
col high_value for a16
select index_owner, index_name, partition_name, high_value from dba_ind_partitions where index_name = 'I_N_TC_RESTART';
