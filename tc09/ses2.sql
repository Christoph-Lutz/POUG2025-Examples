set echo on
exec dbms_session.reset_package;
exec pkg_tc_restart_09.reset
exec pkg_tc_restart_09.start_ses2
