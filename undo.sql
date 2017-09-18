-- undo usage by session
SELECT username, 
       sid || ',' || serial# session_,
       u.status, sum(bytes)/1024/1024/1024 used_gb
  FROM v$transaction t,
       v$session s,
       dba_undo_extents u
 WHERE s.taddr = t.addr
   AND u.segment_name like '_SYSSMU' || t.xidusn || '%$'
 GROUP BY username, 
       u.status, 
       sid || ',' || serial#
 ORDER BY 4 desc;
