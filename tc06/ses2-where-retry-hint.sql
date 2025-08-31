select * from t;
update /*+ RETRY_ON_ROW_CHANGE */ t set val = val + 1 where val is not null;
commit;
select * from t;
