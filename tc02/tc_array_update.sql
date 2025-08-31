/*
 * Purpose:
 *   Very simple test program to demonstrate array updates in pl/sql using forall.
 *
 * Date:
 *  Jun-24 2025
 *
 * Author:
 *   Christoph Lutz
 *
 * Tested on:
 *   Oracle 19.26
 * 
 * Test table creation:
 *   create table t_array_update as select level n1, level n2 from dual connect by level <= 42;
 * 
 * Notes:
 *   Update statement sql_id is: dynxpvskqc946
 */

set serveroutput on size unlimited

declare
    type n1_arr_t is table of t_array_update.n1%type index by pls_integer;
    type n2_arr_t is table of t_array_update.n2%type index by pls_integer;
    n1_arr n1_arr_t; 
    n2_arr n2_arr_t;
begin
    for i in 1..42 loop
        n1_arr(i) := i * 10;
        n2_arr(i) := i;
    end loop;

    forall n in n2_arr.first..n2_arr.last
        update /*+ monitor test_array_upd */ t_array_update set n1 = n1_arr(n) where n2 = n2_arr(n);

    commit;
    -- rollback;

    dbms_output.put_line('Array update complete.');

exception
    when others then
        rollback;
        dbms_output.put_line('Error: ' ||sqlerrm);

end;
/
