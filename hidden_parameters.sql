select ksppinm,
       ksppstvl
  from x$ksppi pi,
       x$ksppcv cv
 where cv.indx=pi.indx
   and upper(ksppinm) like upper('%_use_realfree_heap%');