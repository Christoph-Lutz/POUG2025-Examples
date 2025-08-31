set echo on

drop table tc purge;
create table tc (n number not null);

insert into tc select level n from dual connect by level <= 2;
commit;

exec dbms_stats.gather_table_stats(ownname=>user, tabname=>'TC', cascade=>true, estimate_percent=>null);

@reset.sql
