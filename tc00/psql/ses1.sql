\set ECHO all
start transaction;
update tc set n = n+1 where n > 0;

select * from tc;