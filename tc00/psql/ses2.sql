\set ECHO all
start transaction;
update tc set n = 999 where n = 2;
select * from tc;