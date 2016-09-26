-- Run from SYS

col object_name format a40
col owner format a8
select b.*, round(s.bytes/1024/1024/1024,2) segment_size_gb
  from (select o.owner, 
               o.object_name, 
               o.object_type,        
               round(count(*)*8192/1024/1024/1024,2) cached_gb
          from x$bh b, 
               dba_objects o       
         where o.object_id = b.obj        
         group by o.owner, 
               o.object_name, 
               o.object_type
          order by 4 desc) b,
       dba_segments s
 where rownum < 10 
   and s.segment_name=b.object_name 
   and s.owner = b.owner;