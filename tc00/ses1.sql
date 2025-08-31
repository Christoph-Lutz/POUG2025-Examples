set echo on
select * from tc;
update tc set n = n+1 where n > 0;
select * from tc;

set echo off
prompt
pause Start update in session 2, then hit enter to continue ...
prompt

set echo on
commit;
