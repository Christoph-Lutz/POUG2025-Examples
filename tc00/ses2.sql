set echo on
set serveroutput on size unlimited

select * from tc;
update tc set n=999 where n=2;
select * from tc;
