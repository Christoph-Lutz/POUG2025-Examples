set echo on
exec dbms_session.reset_package;
exec pkg_tc_restart_04.reset
exec pkg_tc_restart_04.start_ses1
