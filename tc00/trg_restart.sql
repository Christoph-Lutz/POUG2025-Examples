set serveroutput on size unlimited

create or replace trigger trg_restart_bufer
before update on tc for each row
begin
  dbms_output.put_line('old.n = ' || :old.n);
  dbms_output.put_line('new.n = ' || :new.n);
end;
/
