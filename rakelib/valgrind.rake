VG_SUPP_LOG_SUFFIX        = '.log'
VG_SUPP_SUPP_SUFFIX       = '.supp'
VG_SUPP_SRC_PATH          = 'test/valgrind/suppression'
VG_SUPP_BUILD_PATH        = 'build/var/test_valgrind'
VG_SUPP_GENERATION_SCRIPT = 'test/valgrind/gen_suppression_file.sh'

c_vg_supp_c_files         = FileList[VG_SUPP_SRC_PATH + '/*.c']
c_vg_supp_supp_files      = c_vg_supp_c_files.sub(VG_SUPP_SRC_PATH, VG_SUPP_BUILD_PATH).sub('.c', VG_SUPP_SUPP_SUFFIX)

desc 'Generate a suppression file for each file that exists in the path VG_SUPP_SRC_PATH'
multitask :valgrind_suppression => [c_vg_supp_supp_files]

rule( /build\/var\/.*\.supp$/ => [proc {|task_name| task_name.sub('.supp', '.c').sub(VG_SUPP_BUILD_PATH + '/', VG_SUPP_SRC_PATH + '/') }]) do |t|
  _output_path = File.dirname(t.name)
  _cmd         = "#{VG_SUPP_GENERATION_SCRIPT} . #{t.source} #{_output_path}"
  run_sh_cmd_formatted(_cmd, 'VALGRIND SUPP GEN', t.source, $opt['verbose_cmd'], $opt['dry_run'])
end

task      :valgrind_suppression_clean do
  del_files = FileList["#{VG_SUPP_BUILD_PATH}/*"]
  delete_filelist(del_files, $opt)
end
