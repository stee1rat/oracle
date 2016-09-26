-- This script moves segments between tablespaces
-- The script supposed to be run in sqlplus as sysdba

SET serveroutput ON format wrapped
SET linesize 1000
SET pagesize 9999
SET feedback OFF

ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY HH24:MI:SS';

variable v_time NUMBER
exec :v_time := dbms_utility.get_time

col "SEGMENTS SIZE (Gb)" format 9999990.99
col "DATAFILES SIZE (Gb)" format 9999990.99

select /*+ RULE */ f.tablespace_name,
       round(e.segments_size,2) "SEGMENTS SIZE (Gb)",
       round(f.datafiles_size,2) "DATAFILES SIZE (Gb)"
  from (select /*+ PARALLEL(64) */ tablespace_name, sum(bytes)/1024/1024/1024 as segments_size from dba_segments group by tablespace_name) e
 right
  join (select tablespace_name, sum(bytes)/1024/1024/1024 as datafiles_size from dba_data_files group by tablespace_name) f
    on e.tablespace_name = f.tablespace_name
 order by datafiles_size-segments_size, tablespace_name ;

variable v_src_tablespace varchar2(200)
exec :v_src_tablespace := '&v_src_tablespace'

variable v_target_tablespace varchar2(200)
exec :v_target_tablespace := '&v_target_tablespace'

begin
   execute immediate 'purge tablespace ' || :v_src_tablespace;
   execute immediate 'purge tablespace ' || :v_target_tablespace;
end;
/

exec dbms_output.put_line(SYSDATE || ': CHANGING USERS DEFAULT TABLESPACE');

begin
  for i in (select 'alter user "' || username || '" default tablespace ' || :v_target_tablespace as cmd
            from dba_users
            where default_tablespace = :v_src_tablespace)
     loop
         execute immediate i.cmd;
     end loop;
end;
/

exec dbms_output.put_line(SYSDATE || ': GRANTING QUOTAS');

begin
  for i in (select distinct 'alter user ' || owner || ' quota unlimited on ' || :v_target_tablespace as cmd
            from dba_segments 
            where tablespace_name = :v_src_tablespace) 
     loop
         execute immediate i.cmd;
     end loop;  
end;
/

-- TABLES
exec dbms_output.put_line(SYSDATE || ': MOVING TABLES');
BEGIN
  FOR j IN (SELECT owner, table_name
              FROM dba_tables
             WHERE tablespace_name = :v_src_tablespace
               AND partitioned = 'NO'
             UNION
            SELECT /*+ PARALLEL(64) */ owner, segment_name as table_name
              FROM dba_segments
             WHERE tablespace_name = :v_src_tablespace
               AND segment_type = 'NESTED TABLE'
             ORDER BY table_name)
      LOOP
      BEGIN
         dbms_output.put_line(SYSDATE || ': Shrinking table ' || j.owner || '.' || j.table_name);
         EXECUTE IMMEDIATE 'alter table "'|| j.owner || '"."' || j.table_name ||'" enable row movement';
         EXECUTE IMMEDIATE 'alter table "'|| j.owner || '"."' || j.table_name ||'" shrink space cascade';
         EXECUTE IMMEDIATE 'alter table "'|| j.owner || '"."' || j.table_name ||'" disable row movement';
      EXCEPTION
         WHEN others THEN
            dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: Table ' || j.owner || '.' || j.table_name);
            dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
      END;

      BEGIN
         dbms_output.put_line(SYSDATE || ': Moving table ' || j.owner || '.' || j.table_name);
         EXECUTE IMMEDIATE 'alter table "'|| j.owner || '"."' || j.table_name ||'" move tablespace ' || :v_target_tablespace;
      EXCEPTION
         WHEN others THEN
            dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: Table ' || j.owner || '.' || j.table_name);
            dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
      END;
   END LOOP;
END;
/
WHENEVER sqlerror CONTINUE

-- TABLE PARTITIONS
exec dbms_output.put_line(SYSDATE || ': MOVING TABLE PARTITIONS');
BEGIN
      FOR j IN (SELECT table_owner, table_name, partition_name
                  FROM dba_tab_partitions
                 WHERE tablespace_name=:v_src_tablespace
                   AND subpartition_count=0
                 ORDER BY BLOCKS)
      LOOP
         BEGIN
            dbms_output.put_line(SYSDATE || ': Shrinking partition ' || j.partition_name || ' of table ' || j.table_owner || '.' || j.table_name);
            EXECUTE IMMEDIATE 'alter table "'|| j.table_owner || '"."' || j.table_name ||'" enable row movement';
            EXECUTE IMMEDIATE 'alter table "'|| j.table_owner || '"."' || j.table_name ||'" modify partition ' || j.partition_name ||' shrink space cascade';
            EXECUTE IMMEDIATE 'alter table "'|| j.table_owner || '"."' || j.table_name ||'" disable row movement';
         EXCEPTION
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: Table ' || j.table_owner || '.' || j.table_name || ', partition: ' || j.partition_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;

         BEGIN
            dbms_output.put_line(SYSDATE || ': Moving partition ' || j.partition_name || ' of table ' || j.table_owner || '.' || j.table_name);
            EXECUTE IMMEDIATE 'alter table "'|| j.table_owner || '"."' || j.table_name ||'" move partition ' || j.partition_name || ' tablespace ' || :v_target_tablespace;
         EXCEPTION
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: Table ' || j.table_owner || '.' || j.table_name || ', partition: ' || j.partition_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
   END LOOP;
END;
/
WHENEVER sqlerror CONTINUE

-- TABLE SUBPARTITIONS
exec dbms_output.put_line(SYSDATE || ': MOVING TABLE SUBPARTITIONS');
BEGIN
      FOR j IN (SELECT table_owner, table_name, subpartition_name
                  FROM dba_tab_subpartitions
                 WHERE tablespace_name = :v_src_tablespace)
      LOOP
         BEGIN
            dbms_output.put_line(SYSDATE || ': Shrinking subpartition ' || j.subpartition_name || ' of table ' || j.table_owner || '.' || j.table_name);
            EXECUTE IMMEDIATE 'alter table "'|| j.table_owner || '"."' || j.table_name ||'" enable row movement';
            EXECUTE IMMEDIATE 'alter table "'|| j.table_owner || '"."' || j.table_name ||'" modify subpartition ' || j.subpartition_name ||' shrink space cascade';
            EXECUTE IMMEDIATE 'alter table "'|| j.table_owner || '"."' || j.table_name ||'" disable row movement';
         EXCEPTION
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: Table ' || j.table_owner || '.' || j.table_name || ', subpartition: ' || j.subpartition_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
         BEGIN
            dbms_output.put_line(SYSDATE || ': Moving subpartition ' || j.subpartition_name || ' of table ' || j.table_owner || '.' || j.table_name);
            EXECUTE IMMEDIATE 'alter table "'|| j.table_owner || '"."' || j.table_name ||'" move subpartition ' || j.subpartition_name || ' tablespace ' || :v_target_tablespace;
         EXCEPTION
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: Table ' || j.table_owner || '.' || j.table_name || ', subpartition: ' || j.subpartition_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
      END LOOP;
END;
/

WHENEVER sqlerror CONTINUE

-- INDEX-ORGANIZED TABLES
exec dbms_output.put_line(SYSDATE || ': MOVING INDEX-ORGANIZED TABLES');
BEGIN
      FOR j IN (SELECT table_owner, table_name
                  FROM dba_indexes
                 WHERE index_type = 'IOT - TOP'
                   AND tablespace_name in (:v_src_tablespace)
                 ORDER BY num_rows)
      LOOP
         dbms_output.put_line(SYSDATE || ': Moving IOT ' || j.table_owner || '.' || j.table_name);
         BEGIN
            execute immediate 'alter table ' || j.table_owner || '.' || j.table_name || ' move parallel 32 tablespace ' || :v_target_tablespace;
         exception
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: IOT ' || j.table_owner || '.' || j.table_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
      END LOOP;
END;
/

WHENEVER sqlerror CONTINUE

-- INDEX-ORGANIZED TABLE PARTITIONS
exec dbms_output.put_line(SYSDATE || ': MOVING INDEX-ORGANIZED TABLE PARTITIONS');
BEGIN
      FOR j IN (select /*+ PARALLEL(64) */ i.table_owner as table_owner, 
                       i.table_name as table_name, 
                       s.partition_name as partition_name 
                  from dba_segments s, dba_indexes i 
                 where s.tablespace_name = :v_src_tablespace
                   and s.segment_type = 'INDEX PARTITION' 
                   and i.index_type ='IOT - TOP' 
                   and s.segment_name = i.index_name
                   and s.owner = i.owner)
      LOOP
         dbms_output.put_line(SYSDATE || ': Moving partition ' || j.partition_name || ' of table ' || j.table_owner || '.' || j.table_name);
         BEGIN
            execute immediate 'alter table ' || j.table_owner || '.' || j.table_name || ' move partition ' || j.partition_name || ' tablespace ' || :v_target_tablespace;
         exception
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: partition ' || j.partition_name || ' of table ' || j.table_owner || '.' || j.table_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
      END LOOP;
END;
/

WHENEVER sqlerror CONTINUE

-- INDEXES
exec dbms_output.put_line(SYSDATE || ': REBUILDING INDEXES');
BEGIN
      FOR j IN (SELECT owner, index_name, uniqueness, tablespace_name, degree
                  FROM dba_indexes
                 WHERE index_type in ('NORMAL', 'FUNCTION-BASED NORMAL','NORMAL/REV', 'BITMAP')
                   AND partitioned='NO'
                   AND tablespace_name in (:v_src_tablespace)
                 ORDER BY num_rows)
      LOOP
         dbms_output.put_line(SYSDATE || ': Rebuilding index ' || j.owner || '.' || j.index_name);
         BEGIN
            execute immediate 'alter index '|| j.owner || '."' || j.index_name || '" rebuild parallel 32 nologging tablespace ' || :v_target_tablespace;
            execute immediate 'alter index '|| j.owner || '."' || j.index_name || '" parallel '|| j.degree;
         exception
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: Index ' || j.owner || '.' || j.index_name);
               dbms_output.put_line(SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
      END LOOP;
END;
/

WHENEVER sqlerror CONTINUE

-- INDEX PARTITIONS
exec dbms_output.put_line(SYSDATE || ': REBUILDING INDEX PARTITIONS');
BEGIN
      FOR j IN (SELECT index_owner, index_name, partition_name, tablespace_name
                  FROM dba_ind_partitions
                 WHERE tablespace_name IN (:v_src_tablespace)
                   AND subpartition_count=0
                 ORDER BY num_rows)
      LOOP
         dbms_output.put_line(SYSDATE || ': Rebuilding partition ' || j.partition_name || ' of index ' || j.index_owner || '.' || j.index_name);
         BEGIN
            execute immediate 'alter index ' || j.index_owner || '."' || j.index_name || '"  rebuild partition '|| j.partition_name|| ' parallel 32 tablespace ' || :v_target_tablespace;
         exception
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: partition ' || j.partition_name || ' of index ' || j.index_owner || '.' || j.index_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
      END LOOP;
END;
/

-- INDEX SUBPARTITIONS
exec dbms_output.put_line(SYSDATE || ': REBUILDING INDEX SUBPARTITIONS');
BEGIN
      FOR j IN (SELECT index_owner, index_name, subpartition_name, tablespace_name
                  FROM dba_ind_subpartitions
                 WHERE tablespace_name = :v_src_tablespace and index_Name <> 'XIF263LETTER'
                 ORDER BY num_rows)
      LOOP
         dbms_output.put_line(SYSDATE || ': Rebuilding subpartition ' || j.subpartition_name || ' of index ' || j.index_owner || '.' || j.index_name);
         BEGIN
            execute immediate 'alter index ' || j.index_owner || '."' || j.index_name || '" rebuild subpartition '|| j.subpartition_name ||' parallel 32 tablespace ' || :v_target_tablespace;
         exception
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: Subpartition ' || j.subpartition_name || ' of index ' || j.index_owner || '.' || j.index_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
      END LOOP;
END;
/

WHENEVER sqlerror CONTINUE

-- LOBSEGMENTS
exec dbms_output.put_line(SYSDATE || ': MOVING LOBSEGMENTS');
BEGIN
      FOR j IN (SELECT owner, table_name, column_name
                  FROM dba_lobs 
                 WHERE tablespace_name=:v_src_tablespace
                   AND partitioned = 'NO')
      LOOP
         dbms_output.put_line(SYSDATE || ': Moving lob segment ' || j.column_name || ' of table ' || j.owner || '.' || j.table_name );
         BEGIN
            execute immediate 'ALTER TABLE ' || j.owner || '.' || j.table_name || ' MOVE tablespace ' || :v_target_tablespace || ' LOB (' || j.column_name || ') store as (TABLESPACE ' || :v_target_tablespace  || ') parallel 32';
         exception
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: lob segment ' || j.column_name || ' of table ' || j.owner || '.' || j.table_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
      END LOOP;
END;
/

WHENEVER sqlerror CONTINUE

-- LOB PARTITIONS
exec dbms_output.put_line(SYSDATE || ': MOVING LOB PARTITIONS');
BEGIN
      FOR j IN (SELECT lp.table_owner, lp.table_name, lp.partition_name, lp.column_name
                  FROM dba_lob_partitions lp,
                       dba_segments s
                 WHERE lp.lob_name = s.segment_name
                   AND s.tablespace_name = :v_src_tablespace
                   AND s.segment_type='LOB PARTITION')
      LOOP
         dbms_output.put_line(SYSDATE || ': Moving lob partition ' || j.partition_name || ' of table ' || j.table_owner || '.' || j.table_name );
         BEGIN
            execute immediate 'ALTER TABLE '|| j.table_owner || '.' || j.table_name||' MOVE partition '||j.partition_name||' TABLESPACE ' || :v_target_tablespace || ' LOB ('||j.column_name||') store as (TABLESPACE ' || :v_target_tablespace || ') parallel 32';
         exception
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: lob partition ' || j.partition_name || ' of table ' || j.table_owner || '.' || j.table_name);
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
      END LOOP;
END;
/

WHENEVER sqlerror CONTINUE

-- LOB SUBPARTITIONS
exec dbms_output.put_line(SYSDATE || ': MOVING LOB SUBPARTITIONS');
BEGIN
      FOR j IN (SELECT table_owner, table_name, subpartition_name, column_name
                  FROM dba_lob_subpartitions lsp,
                       dba_segments s
                 WHERE lsp.lob_name = s.segment_name
                   AND s.tablespace_name=:v_src_tablespace
                   AND s.segment_type='LOB SUBPARTITION')
      LOOP
         dbms_output.put_line(SYSDATE || ': Moving lob subpartition ' || j.subpartition_name || ' of table ' || j.table_owner || '.' || j.table_name );
         BEGIN
            execute immediate 'ALTER TABLE '|| j.table_owner || '.' || j.table_name||' MOVE subpartition '||j.subpartition_name||' TABLESPACE ' || :v_target_tablespace || ' LOB ('||j.column_name||') store as (TABLESPACE ' || :v_target_tablespace || ') parallel 32';
         exception
            WHEN others THEN
               dbms_output.put_line(SYSDATE || ':   ' || 'ERROR: lob subpartition ' || j.subpartition_name || ' of table ' || j.table_owner || '.' || j.table_name)
;
               dbms_output.put_line (SYSDATE || ':   ' || substr(sqlerrm, 1 , 64));
         END;
      END LOOP;
END;
/

WHENEVER sqlerror CONTINUE

exec dbms_output.put_line('');

var v_segments number;
var v_size number;

begin
   execute immediate 'select count(*) from dba_segments where tablespace_name = ''' || :v_src_tablespace  || '''' into :v_segments;
   dbms_output.put_line('Segments left in tablespace ' || :v_src_tablespace || ': '|| :v_segments);

   execute immediate 'select round(sum(bytes/1024/1024/1024), 3) from dba_segments where tablespace_name = ''' || :v_target_tablespace  || '''' into :v_size;
   dbms_output.put_line('Total size of segments in tablespace ' || :v_target_tablespace || ': '|| :v_size || ' Gb');
end;
/

declare
   v_ddl long;
begin
   if :v_segments = 0 then
      dbms_output.put_line('The current DDL for the tablespace ' || :v_src_tablespace || ' is:');
      execute immediate 'select dbms_metadata.get_ddl(''TABLESPACE'',''' || :v_src_tablespace || ''') from dual' into v_ddl;
      dbms_output.put_line(v_ddl);
      dbms_output.put_line('Drop it with the following SQL: ');
      dbms_output.put_line('  drop tablespace ' || :v_src_tablespace || ' including contents and datafiles;'||chr(10));
   end if;
end;
/

exec :v_time :=  round((dbms_utility.get_time - :v_time)/100/60);
exec dbms_output.put_line('Total Minutes elapsed : '||:v_time);

set feedback on
