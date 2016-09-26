col duration format a10
col database_time format a14
select status, 
       sql_id,
       sql_plan_hash_value "SQL Plan",
       (count(*)-1)/2 "Parallel",       
       round((max(last_refresh_time)-min(sql_exec_start))*24*60*60,2) || 's' duration,
       round(sum(elapsed_time/1e6),2) || 's' database_time,
       min(sql_exec_start) "Start",
       max(last_refresh_time) "Ended"
 from v$sql_monitor 
where sql_id = 'fw0p80jazdgks' 
group by status, 
      sql_id,
      sql_plan_hash_value,
      sql_exec_id
order by 8 desc; 