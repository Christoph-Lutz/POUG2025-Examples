set echo on
@sql-execs.sql
@dml-statement-restries.sql
exec dbms_session.reset_package;
exec pkg_tc_restart_08.reset
exec pkg_tc_restart_08.start_ses1
exec pkg_tc_restart_08.stop_ses2
@sql-execs.sql
@dml-statement-restries.sql
