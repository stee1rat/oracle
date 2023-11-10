-- temp usage by session
SELECT username, 
       sql_id, 
       sql_id_tempseg, 
       round(blocks*8192/1024/1024/1024,2) 
  FROM v$tempseg_usage 
 ORDER BY 4 desc;

-- temp usage
SELECT sysdate,
       (SELECT round(sum(blocks)*8192/1024/1024/1024, 2) FROM v$tempseg_usage) used_total,
       (SELECT round(sum(bytes)/1024/1024/1024, 2) FROM dba_temp_files) allocated
  FROM dual;
