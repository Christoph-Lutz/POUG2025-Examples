-- ------------------------------------------
-- Note:
-- You must create a vars.sql file with all 
-- sqlplus variables!
-- ------------------------------------------
@vars.sql

create user &&test_user identified by &&test_user_pwd
default tablespace &&test_ts temporary tablespace &&temp_ts;

grant connect, resource to &&test_user;;

alter user &&test_user quota unlimited on &&test_ts;

grant execute on dbms_pipe to &&test_user;
grant execute on sys.dbms_system to &&test_user;
