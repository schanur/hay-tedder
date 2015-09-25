def dep_file_valid(filename)
  _file_ending = filename[-2]
end

# Parse the dependency file created by the compiler and return
# a FileList containing the files of the dependency file.
def comp_dep_2_filelist(dep_file)
  raise ArgumentError, "Dependency file \"#{dep_file}\" is missing." unless File.file?(dep_file)
  _tokens = File.read(dep_file).scan(/'[^']*'|"[^"]*"|[(:)]|[^(:)\s]+/)
  return FileList.new(_tokens.find_all{|item| item =~ /src\// })
end

# Similar to "comp_dep_2_filelist" but if the header file in
# the parsed dependency file have a corresponding C source
# file in the same directory, the source file is also included
# in the returned FileList.
def comp_test_dep_2_filelist(dep_file)
  _all_code_deps = comp_dep_2_filelist(dep_file)
  _all_code_deps.add(_all_code_deps.map { |header_file| header_file.sub('.h', '.c') }.select { |src_file| File.file?(src_file) })
  _all_code_deps_uniq = FileList.new()
  _all_code_deps.each { |file| \
                          if !_all_code_deps_uniq.include?(file)
                            _all_code_deps_uniq.add(file)
                          end
  }
  return _all_code_deps_uniq
end

# Find all C source files and return an array of the source files
# with the file extension replaced by '.o' and th directory replaced
# by the test build directory.
def comp_obj_filelist_by_dep_list(dep_filelist, opt)
  return dep_filelist.select { |src_file| src_file.include?('.c') }.map { |src_file|
    src_file = opt['build_dir'] + '/' + src_file.sub('.c', '.o').sub('src/', '').gsub('/', '#')
  }
end

# def src_to_build_file(build_dir, src_file)
#   return build_dir + '/' + src_file.sub('src/', '').gsub('/', '#')
# end

def build_to_src_file(build_dir, build_file)
  return build_file.sub(build_dir + '/', 'src/').sub('c_obj', '').gsub('#', '/')
end

def build_to_test_src_file(build_dir, build_file)
  return build_file.sub(build_dir + '/', 'test/unit/').gsub('#', '/')
end

def to_abs_module_name(build_dir, file_desc)
  return file_desc.sub(build_dir + '/', '').sub('src/', '').gsub('#', '/').sub('.d', '').sub('.c', '').sub('.o', '')
end

# Run command but omit all output to stdout and stderr.
def run_sh_cmd_quiet(cmd, dry_run)
  verbose(false) do
    run_sh_cmd_verbose(cmd, dry_run)
  end
end

def run_sh_cmd_verbose(cmd, dry_run)
  if (dry_run == 'no')
    sh cmd
  else
    puts_r(cmd)
  end
end

def run_sh_cmd_short_output(cmd, log_type, log_str, dry_run)
  put_log_str(log_type, log_str, :light_yellow)
  run_sh_cmd_quiet(cmd, dry_run)
end

def run_sh_cmd_formatted(cmd, log_type, log_str, verbose, dry_run)
  if verbose == 'yes'
    run_sh_cmd_verbose(cmd, dry_run)
  elsif verbose == 'no'
    run_sh_cmd_short_output(cmd, log_type, log_str, dry_run)
  else
    raise 'Invalid \"verbose_cmd\" value'
  end
end

def run_sh_cmd_formatted_with_target(cmd, log_type, log_str, target, verbose, dry_run)
  run_sh_cmd_formatted(cmd, log_type, str_target(target) + log_str, verbose, dry_run)
end

def create_directory_if_missing(directory)
  if !File.directory?(directory)
    Dir.mkdir(directory)
  end
end

def create_directory_of_file_if_missing(filename)
  create_directory_if_missing(File.dirname(filename))
end


# FIXME: Is part of recursive rake task execution.
def recursive_rake_call(task, target, build_root, opt)
  # MinGW needs a lot of RAM while compiling duo to parsing windows.h.
  # To reduce swapping reduce number of threads.
  # FIXME: Find a better way to determine the best number of threads.
  if get_target_platform_by_c_compiler($opt['c_compiler']) == :windows
    # thread_cnt = jobs_param()
    jobs_param = '--jobs=1'
  else
    jobs_param = ''
  end
  _cmd_str = "rake #{jobs_param} #{task} build_root=#{build_root} target=#{target} c_compiler=#{opt['c_compiler']} verbose_cmd=#{opt['verbose_cmd']}"

  rake_system(_cmd_str)
end

# FIXME: Is part of recursive rake task execution.
def split_recursive_rake_arguments(task_name)
  task_name = task_name.sub('test_recursive_', '')
  _args = Hash.new
  _args[:target] = task_name.split('_')[-1]
  _args[:task]   = task_name.sub('_' + _args[:target], '')
  return _args
end

def run_cmd_loop_on_inotify_event()
  # $(AUTO_BUILD_PRIORITY_CMD)
  sh '(which inotifywait > /dev/null || (echo "inotifywait missing"; exit 1))'
  sh "while [ 1 ]; do inotifywait -q -r -e modify --exclude '.*flymake.*' src/ test/ && clear && time rake test; done"
end
