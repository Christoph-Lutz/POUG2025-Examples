set echo on
@sql-execs.sql
@dml-statement-restries.sql
exec pkg_tc_restart_07.reset
exec pkg_tc_restart_07.start_ses1
exec pkg_tc_restart_07.stop_ses2
@sql-execs.sql
@dml-statement-restries.sql
