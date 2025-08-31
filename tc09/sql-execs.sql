define sql_id='08hkrjbutc6gt'

select sql_id, executions, invalidations
from v$sql where sql_id = '&&Sql_id';
