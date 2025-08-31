set echo on

drop table tc_restart purge;

create table tc_restart (n number not null, v varchar2(30)) partition by list(n)
(
    partition p01_04 values(1,2,3,4),
    partition p05_08 values(5,6,7,8),
    partition p09_12 values(9,10,11,12)
)
enable row movement;

-- P01_04
insert into tc_restart values(1, null);
insert into tc_restart values(2, null);
insert into tc_restart values(3, null);

-- P05_08
insert into tc_restart values(5, null);
insert into tc_restart values(6, null);
insert into tc_restart values(7, null);

-- P789
-- insert into tc_restart values(9, null);

commit;

create index i_n_tc_restart on tc_restart(n) local online;

exec dbms_stats.gather_table_stats(ownname=>user, tabname=>'TC_RESTART', estimate_percent=>null, cascade=>true, no_invalidate=>false, granularity=>'global and partition');

drop package pkg_tc_restart_08
@pkg_tc_restart_08.sql

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

col index_owner for a16 
col index_name for a16
col partition_name for a16
col high_value for a16
select index_owner, index_name, partition_name, high_value from dba_ind_partitions where index_name = 'I_N_TC_RESTART';
