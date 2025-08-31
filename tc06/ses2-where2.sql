select * from t;
-- update t set val = val + 1 where val is not null;
update t set val = val + 1 where id is not null;
commit;
select * from t;
