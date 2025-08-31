\set echo all

drop table if exists tc;
create table tc (n integer);

start transaction;
insert into tc values(1);
insert into tc values(2);
commit;

select * from tc;