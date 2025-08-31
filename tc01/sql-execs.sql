define sql_id='cpdd39fdup01h'

select sql_id, executions 
from v$sql where sql_id = '&&Sql_id';
