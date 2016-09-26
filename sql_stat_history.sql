select h.begin_interval_time,
       s.sql_id,
       s.plan_hash_value,
       s.executions_delta,
       round(s.buffer_gets_delta/s.executions_delta,2) buffer_gets,
       round(s.elapsed_time_delta/decode(s.executions_delta,0,1,s.executions_delta)/1e6,5) elapsed_seconds
  from dba_hist_sqlstat s,
       dba_hist_snapshot h
 where sql_id = 'adc0nxpxm0ghs' 
   and h.dbid = 3647405474
   and s.snap_id = h.snap_id
   and s.executions_delta > 0
 order by s.snap_id;  