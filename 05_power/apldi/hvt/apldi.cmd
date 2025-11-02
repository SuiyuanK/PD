apldi -c -l ../../data/celllist/hvt/cell_nodecap  -v apldi.conf
apldi -p ../../data/celllist/hvt/cell_decap  -v apldi.conf
aplmerge -o hvt_ff1p21v125c.cdev ./cellresults/ff1p21v125c/CAP/*.cdev
aplmerge -o hvt_ss0p99vm40c.cdev ./cellresults/ss0p99vm40c/CAP/*.cdev

apldi -w -l ../../data/celllist/hvt/cell_nodecap  -v apldi.conf
apldi -w -p ../../data/celllist/hvt/cell_decap  -v apldi.conf
aplmerge -o hvt_ff1p21v125c.pwcdev ./cellresults/ff1p21v125c/PWC/*.pwcdev
aplmerge -o hvt_ss0p99vm40c.pwcdev ./cellresults/ss0p99vm40c/PWC/*.pwcdev

apldi -l ../../data/celllist/hvt/cell_nodecap  -v apldi.conf
aplmerge -o hvt_ff1p21v125c.spiprof ./cellresults/ff1p21v125c/CURRENT/*.spiprof
aplmerge -o hvt_ss0p99vm40c.spiprof ./cellresults/ss0p99vm40c/CURRENT/*.spiprof