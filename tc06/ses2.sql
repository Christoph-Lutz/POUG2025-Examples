set echo on
select * from t;
update t set val = val + 1;
commit;
select * from t;
