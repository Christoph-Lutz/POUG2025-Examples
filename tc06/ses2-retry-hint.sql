select * from t;
update /*+ RETRY_ON_ROW_CHANGE */ t set val = val + 1;
commit;
select * from t;
