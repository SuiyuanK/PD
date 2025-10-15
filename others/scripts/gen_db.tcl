#enable_write_lib_mode

set lib_files [glob *.lib]

foreach lib_file $lib_files {
  remove_design -all
  read_lib $lib_file
  set lib_name [get_attr [get_libs] name]
  if {![regsub -all ".*\.lib.*" $lib_file ".db" lib_file_sufix]} {
    set lib_file_sufix ".db"
  }
  write_lib -o ${lib_name}${lib_file_sufix} $lib_name
}
