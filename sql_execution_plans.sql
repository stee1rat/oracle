select sql_id, 
       plan_hash_value,        
       sum(executions) executions, 
       round(sum(elapsed_time)/decode(sum(executions),0,1,sum(executions))/1e6,5) avg_time, 
       round(sum(disk_reads)/decode(sum(executions),0,1,sum(executions)),2) avg_disk_reads, 
       round(sum(buffer_gets)/decode(sum(executions),0,1,sum(executions)),2) avg_buffer_gets,
       max(last_active_time)
  from v$sql 
 where sql_id = '3njba9fjtzfa9'
 group by 
       sql_id,
       plan_hash_value;