prompt
accept sql_id prompt 'Enter sql_id: '
prompt

set trimspool     on
set trim          on
set pages         0
set linesize      32767
set long          1000000
set longchunksize 1000000
 
spool /tmp/&&sql_id..html
 
select 
    dbms_sqltune.report_sql_monitor(sql_id=>'&sql_id', 
	                                type  =>'ACTIVE') 
from dual
/
 
spool off
