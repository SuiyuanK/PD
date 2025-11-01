
apldi -c -l ../../data/celllist/rvt/cell_nodecap  -v apldi.conf
apldi -p ../../data/celllist/rvt/cell_decap  -v apldi.conf
aplmerge -o rvt_ff1p21v125c.cdev ./cellresults/ff1p21v125c/CAP/*.cdev
aplmerge -o rvt_ss0p99vm40c.cdev ./cellresults/ss0p99vm40c/CAP/*.cdev

apldi -w -l ../../data/celllist/rvt/cell_nodecap  -v apldi.conf
apldi -w -p ../../data/celllist/rvt/cell_decap  -v apldi.conf
aplmerge -o rvt_ff1p21v125c.pwcdev ./cellresults/ff1p21v125c/PWC/*.pwcdev
aplmerge -o rvt_ss0p99vm40c.pwcdev ./cellresults/ss0p99vm40c/PWC/*.pwcdev

apldi -l ../../data/celllist/rvt/cell_nodecap  -v apldi.conf
aplmerge -o rvt_ff1p21v125c.current ./cellresults/ff1p21v125c/CURRENT/*.current
aplmerge -o rvt_ss0p99vm40c.current ./cellresults/ss0p99vm40c/CURRENT/*.current