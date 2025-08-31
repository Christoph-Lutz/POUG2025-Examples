define sql_id='bbxsy37utuhn6'

select sql_id, executions, invalidations
from v$sql where sql_id = '&&Sql_id';
