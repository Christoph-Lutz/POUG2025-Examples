define sql_id='d9t1dbspapv82'

select sql_id, executions, invalidations
from v$sql where sql_id = '&&Sql_id';
