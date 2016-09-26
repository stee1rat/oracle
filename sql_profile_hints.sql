-- > 11g
SELECT extractvalue(value(h),'.') AS hint
FROM sys.sqlobj$data od, sys.sqlobj$ so,
table(xmlsequence(extract(xmltype(od.comp_data),'/outline_data/hint'))) h
WHERE so.name = 'profile_4zrw9nv0634mt'
AND so.signature = od.signature
AND so.category = od.category
AND so.obj_type = od.obj_type
AND so.plan_id = od.plan_id;

-- < 11g
SELECT attr_val
FROM sys.sqlprof$ p, sys.sqlprof$attr a
WHERE p.sp_name = 'opt_estimate'
AND p.signature = a.signature
AND p.category = a.category;