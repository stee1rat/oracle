-- sql execution history

col begin_interval_time format a30

select s.begin_interval_time, 
       h.sql_id,
       h.plan_hash_value,  
       h.executions_delta,
       round(h.px_servers_execs_delta/decode(h.executions_delta,0,1,h.executions_delta)/2,2) px_servers_delta,
       round(h.elapsed_time_delta/decode(h.executions_delta,0,1,h.executions_delta)/1e6, 4) elapsed_seconds 
  from dba_hist_sqlstat h,  dba_hist_snapshot s 
 where sql_id = '3jdcv6xudg5yj' 
   and s.snap_id = h.snap_id
 order by 
       s.begin_interval_time;