def delete_file(file, opt)
  run_sh_cmd_formatted("rm #{file}", 'DELETE FILE', to_abs_module_name(opt['build_dir'], file), opt['verbose_cmd'], opt['dry_run'])
end

def delete_file_if_exists(file, opt)
  if File.file?(file)
    delete_file(file, opt)
  end
end

def delete_filelist(filelist, opt)
  dependency_list = []
  filelist.each do |file|
    taskname = "delete_file_task_#{file}".to_sym
    task taskname do
      delete_file(file, opt)
    end
    dependency_list.push(taskname)
  end
  multitask :run_all_delete_operations_parallel => dependency_list
  Rake::Task[:run_all_delete_operations_parallel].invoke
  Rake::Task[:run_all_delete_operations_parallel].reenable
end

# # Delete files recursive but let directory structure intact.
# def delete_filelist(filelist, opt)
#   dependency_list = []
#   filelist.each do |file|
#     taskname = "delete_file_task_#{file}".to_sym
#     task taskname do
#       delete_file(file, opt)
#     end
#     dependency_list.push(taskname)
#   end
#   multitask :run_all_delete_operations_parallel => dependency_list
#   Rake::Task[:run_all_delete_operations_parallel].invoke
# end

def delete_file_dry_run(file, opt)
  run_sh_cmd_formatted("true", 'DELETE FILE', to_abs_module_name(opt['build_dir'], file), opt['verbose_cmd'], opt['dry_run'])
end

def delete_filelist_dry_run(filelist, opt)
  filelist.each do |file|
    delete_file_dry_run(file, opt)
  end
end

def delete_directory(directory, opt)
  run_sh_cmd_formatted("rm -r #{directory}", 'DELETE DIR', directory, opt['verbose_cmd'], opt['dry_run'])
end

# def delete_directory_recursive(directory)
#   # FileList["#{directory}/**/*"].each do |file|
#   #   delete_filelist_dry_run()
#   # end
# end

multitask :clean_all,                  [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  Rake::Task[:clean_build                ].invoke(args[:opt])
  Rake::Task[:clean_test_unit            ].invoke(args[:opt])
  Rake::Task[:clean_valgrind_suppression ].invoke(args[:opt])
end

desc 'Clean build/target directory'
multitask :clean_build,                [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  Rake::Task[:clean_c_dep                ].invoke(args[:opt])
  Rake::Task[:clean_c_obj                ].invoke(args[:opt])
  Rake::Task[:clean_static_lib           ].invoke(args[:opt])
  Rake::Task[:clean_shared_lib           ].invoke(args[:opt])
  Rake::Task[:clean_binary               ].invoke(args[:opt])
end

task      :clean_test_unit,            [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  Rake::Task[:unit_test_clean            ].invoke(args[:opt])
end

task      :clean_test_style,           [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  Rake::Task[:style_test_clean           ].invoke(args[:opt])
end

task      :clean_valgrind_suppression, [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  Rake::Task[:valgrind_suppression_clean ].invoke(args[:opt])
end

task      :clean,                      [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  # puts args.opt
  Rake::Task[:clean_build                ].invoke(args.opt)
end

task      :clean_c_obj,                [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  del_files = FileList["#{args[:opt]['build_dir']}/c_obj/*"]
  delete_filelist(del_files, args[:opt])
end

task      :clean_c_dep,                [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  del_files = FileList["#{args.opt['build_dir']}/c_dep/*"]
  delete_filelist(del_files, args.opt)
end

task      :clean_static_lib,           [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  delete_file_if_exists(File.join(args.opt['build_dir'], 'ort.a'),   args.opt)
end

task      :clean_shared_lib,           [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  delete_file_if_exists(File.join(args.opt['build_dir'], 'ort.so'),  args.opt)
end

task      :clean_binary,               [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  delete_file_if_exists(File.join(args.opt['build_dir'], 'ort.bin'), args.opt)
end
