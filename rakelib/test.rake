TEST_BUILD_DIR = 'build/var/test'

# c_unit_test_files                  = FileList['test/unit/*.c']
# c_unit_test_dep_job                = c_unit_test_files.gsub(/\//, '#').sub(/test\#unit\#/, TEST_BUILD_DIR + '/' + $opt['target'] + '/').sub(/\.c$/, '.test_dep')
# c_unit_test_run_list               = FileList.new
# c_unit_test_result_list_native     = c_unit_test_dep_job.sub('.test_dep', '.result_native')
# c_unit_test_result_list_valgrind   = c_unit_test_dep_job.sub('.test_dep', '.result_valgrind')

#c_unit_test_vendor_file_relaltions = {

#desc 'Run a list of unit tests'
#task      :test, [:arg]         => [:test_run_test_list[:arg],         :test_unit_test_list]
#task      :test_unit_test_list  => [:test_c_obj,                       :test_link]
task      :test                 => [:test_unit_test_list]
task      :test_unit_test_list  => [:test_c_obj,                       :test_link]
#task      :test                 => [:test_c_obj,                       :test_link]
multitask :test_c_obj           => [:test_recursive_c_obj_debug,       :test_recursive_c_obj_release      ]
multitask :test_clean           => [:test_recursive_clean_release,     :test_recursive_clean_debug        ]
multitask :test_link            => [:test_recursive_link_c_test_debug, :test_recursive_link_c_test_release]
# multitask :test_c_obj           => [:test_recursive_c_obj_debug,       :test_recursive_c_obj_release,       :test_recursive_c_obj_coverage]
# multitask :test_clean           => [:test_recursive_clean_debug,       :test_recursive_clean_release,       :test_recursive_clean_coverage]
# multitask :test_link            => [:test_recursive_link_c_test_debug, :test_recursive_link_c_test_release, :test_recursive_link_c_test_coverage]
#task      :test_link            => [:test_recursive_link_c_test_debug, :test_recursive_link_c_test_release]

# task :test_compile_vendor do
#   _unity_source = 'vendor/Unity-master/src/unity.c'
#   _unity_name   = 'build/vendor/unity.o'
#   file _unity_name => _unity_source do
#     puts "b>" + _unity_source
#     puts "a>" + _unity_name
#     compile_c_vendor_object_without_warnings(_unity_source, _unity_name, $opt)
#   end
#   Rake::FileTask[_unity_name].invoke
# end

# file 'build/vendor/unity.o' => 'vendor/Unity-master/src/unity.c' do
# end


# task :test_clean_vendor do
#   delete_file_if_exists('build/vendor/unity.o', $opt)
# end

rule /^test_recursive/ do |t|
  _args = split_recursive_rake_arguments(t.name)
  recursive_rake_call(_args[:task], _args[:target], TEST_BUILD_DIR, $opt)
end

#task      :link_c_test              => [:compile_c_obj_list, :link_with_dependencies, :run_c_tests, :verify_all_tests_has_run]
#task      :link_c_test              => [:compile_c_obj_list, :link_with_dependencies, :run_c_tests_native, :run_c_tests_valgrind]
task      :link_c_test              => [:compile_c_obj_list, :link_with_dependencies, :run_c_tests_native]
# multitask :compile_c_obj_list       => c_unit_test_dep_job
# #multitask :run_c_tests_native       => c_unit_test_result_list_native
# task      :run_c_tests_native       => c_unit_test_result_list_native
#multitask :run_c_tests_valgrind     => c_unit_test_result_list_valgrind
#multitask :run_c_tests              =>
# multitask :verify_all_tests_has_run => c_unit_test_result_list
#   c_unit_test_result_list.each
# end


rule( /\.result_native$/   => [proc {|task_name| task_name.sub('.result_native',   '') }]) do |t|
  # _cmd = "#{t.source} 2>&1 > #{t.name}"
  # puts _cmd
  # run_sh_cmd_formatted(_cmd, 'TEST', t.name, 'no')

  _success = run_test_native(t.source, $opt)
  if _success
    verbose(false) do
      touch t.name
    end
  else
    raise 'Unit test failed.'
    #exit!(1)
    #abort('asd')
  end

  #puts "native"
  #touch t.name
end

rule( /\.result_valgrind$/ => [proc {|task_name| task_name.sub('.result_valgrind', '') }]) do |t|
  puts "valgrind"
  touch t.name
end

task :link_with_dependencies do
  c_unit_test_run_list.each do |test|
    _binary = test.sub('.o', '')
    #
    _dep_files = comp_test_dep_2_filelist(test.sub('.o', '.d'))
    _link_obj_files = comp_obj_filelist_by_dep_list(_dep_files, $opt).add(test)
    # puts _link_obj_files
    file _binary => _link_obj_files do |t|
      # puts _link_obj_files
      compile_c_test_binary(_binary, _link_obj_files, $opt)
    end
    Rake::FileTask[_binary].invoke
  end
end

# We do not use this rule to actually build '. deb' files.
rule /\.test_dep$/ do |t|
  _dep_filename = t.name.sub('.test_dep', '.d')
  _obj_filename = t.name.sub('.test_dep', '.o')
  _c_filename   = t.name.sub('.test_dep', '.c')
  # If the C source file is newer than the '.d' file
  # rebuild the '.d' file.
  file _dep_filename
  Rake::Task[_dep_filename].invoke
  _test_dep_file_list        = comp_test_dep_2_filelist(_dep_filename).add(build_to_test_src_file($opt['build_dir'], _c_filename))
  _test_dep_header_file_list = _test_dep_file_list.select { |c_file| c_file.include?('.c') }
  _test_dep_file_list.each do |t|
  end
  file _obj_filename => _test_dep_file_list do |t|
    _src_filename = build_to_test_src_file($opt['build_dir'], t.name).sub('.o', '.c')
    compile_c_object_file(_src_filename, t.name, $opt)
    # Mark the new compiled test as a test
    # we have to run afterwards.
    c_unit_test_run_list.add(t.name)
  end
  Rake::FileTask[_obj_filename].invoke
end

rule( /build\/var\/.*\.d$/ => [proc {|task_name| task_name.sub('.d', '.c').sub($opt['build_dir'] + '/', 'test/unit/').gsub('#', '/') }]) do |t|
# The source parameter
#rule /build\/var\/.*\.d$/, [:source] do |t, args|
  #_source_file = args[:source]
  _source_file = t.source
  # puts $obj
  # exit 1
  compile_c_dependency_file(_source_file, t.name, $opt)
  #puts "name: " + t.name + " source: " + _source_file
end

task :autotest do
  run_cmd_loop_on_inotify_event
end

task :unit_test_clean => :test_clean
