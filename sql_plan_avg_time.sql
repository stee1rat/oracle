define sqlid = 'agf14c77khwnh'
with
p AS (
SELECT sql_id,
       plan_hash_value
  FROM gv$sql_plan
 WHERE sql_id = TRIM('&sqlid')
   AND other_xml IS NOT NULL
 UNION
SELECT sql_id,
       plan_hash_value
  FROM dba_hist_sql_plan
 WHERE sql_id = TRIM('&sqlid')
   AND other_xml IS NOT NULL ),
m AS (
SELECT plan_hash_value,
       SUM(elapsed_time)/SUM(executions) avg_et_secs
  FROM gv$sql
 WHERE sql_id = TRIM('&sqlid')
   AND executions > 0
 GROUP BY
       plan_hash_value ),
a AS (
SELECT plan_hash_value,
       SUM(elapsed_time_total)/SUM(executions_total) avg_et_secs
  FROM dba_hist_sqlstat
 WHERE sql_id = TRIM('&sqlid')
   AND executions_total > 0
 GROUP BY
       plan_hash_value )
SELECT p.sql_id,
       p.plan_hash_value,
       ROUND(NVL(m.avg_et_secs, a.avg_et_secs)/1e6, 3) avg_et_secs
  FROM p, m, a
 WHERE p.plan_hash_value = m.plan_hash_value(+)
   AND p.plan_hash_value = a.plan_hash_value(+)
 order by
       avg_et_secs nulls last;