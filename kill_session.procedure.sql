create or replace procedure system.kill_session(sid integer, serial# integer)
   is
begin
   execute immediate 'alter system kill session ''' || sid || ',' || ' serial# ' || ''' immediate';
end;
