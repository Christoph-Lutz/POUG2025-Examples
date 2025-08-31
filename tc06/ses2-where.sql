select * from t;
update t set val = val + 1 where val is not null;
commit;
select * from t;
