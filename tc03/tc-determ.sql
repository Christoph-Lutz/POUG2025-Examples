create or replace package my_pkg as
  function f_deterministic(p_n number)
    return number;

  function f_non_deterministic(p_n number)
    return number;
end;
/

create or replace package body my_pkg as
  g_n number := 0;

  function f_deterministic(p_n number)
    return number is
   begin
      return p_n;
   end;

  function f_non_deterministic(p_n number)
    return number is
   begin
      g_n := g_n + p_n;
      return mod(g_n, 2);
   end;

begin
    null;
end;
/

set echo on
select my_pkg.f_deterministic(1) from dual;
select my_pkg.f_deterministic(1) from dual;
select my_pkg.f_deterministic(1) from dual;

select my_pkg.f_non_deterministic(1) from dual;
select my_pkg.f_non_deterministic(1) from dual;
select my_pkg.f_non_deterministic(1) from dual;

drop package my_pkg;
