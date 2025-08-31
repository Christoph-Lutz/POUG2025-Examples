set echo on
alter system flush shared_pool;
@sql-execs.sql
exec pkg_tc_restart_01.reset
exec pkg_tc_restart_01.start_ses1
exec pkg_tc_restart_01.stop_ses2
@sql-execs.sql
