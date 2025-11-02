
apldi -c -l ../../data/celllist/rvt/cell_nodecap  -v apldi.conf
apldi -p ../../data/celllist/rvt/cell_decap  -v apldi.conf
aplmerge -o rvt_ff1p21v125c.cdev ./cellresults/ff1p21v125c/CAP/*.cdev
aplmerge -o rvt_ss0p99vm40c.cdev ./cellresults/ss0p99vm40c/CAP/*.cdev

apldi -w -l ../../data/celllist/rvt/cell_nodecap  -v apldi.conf
apldi -w -p ../../data/celllist/rvt/cell_decap  -v apldi.conf
aplmerge -o rvt_ff1p21v125c.pwcdev ./cellresults/ff1p21v125c/PWC/*.pwcdev
aplmerge -o rvt_ss0p99vm40c.pwcdev ./cellresults/ss0p99vm40c/PWC/*.pwcdev

apldi -l ../../data/celllist/rvt/cell_nodecap  -v apldi.conf
aplmerge -o rvt_ff1p21v125c.spiprof ./cellresults/ff1p21v125c/CURRENT/*.spiprof
aplmerge -o rvt_ss0p99vm40c.spiprof ./cellresults/ss0p99vm40c/CURRENT/*.spiprof