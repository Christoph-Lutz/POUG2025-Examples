drop table t purge;
create table t (id number, val number) rowdependencies;
insert into t values(1,0);
commit;
