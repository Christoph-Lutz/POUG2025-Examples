set echo on
exec dbms_session.reset_package;
exec pkg_tc_restart_08.reset
exec pkg_tc_restart_08.start_ses2
