set echo on

drop table t_src purge;
create table t_src (n1 number, n2 number);

insert into t_src values(1,1);
insert into t_src values(1,2);
commit;

drop table t_tgt purge;
create table t_tgt (n1 number, n2 number);

insert into t_tgt values(1,1);
commit;

select * from t_src;

select * from t_tgt;

merge into t_tgt t 
using t_src s on (s.n1 = t.n1)
when matched then update set t.n2 = s.n2;

select * from t_tgt;

rollback;
