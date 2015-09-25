
# Build C dependency files.
rule( /\.d$/ => [proc {|task_name| task_name.sub('.d', '.c').sub($opt['build_dir'] + '/c_dep/', 'src/').gsub('#', '/') }]) do |t|
  compile_c_dependency_file(t.source, t.name, $opt)
  #compile_c_dependency_file(t.source, t.name, $obj)
end

# # Build binaries.
# rule( /\.bin$/ => [proc {|task_name| task_name.sub('.d', '.c').sub($opt['build_dir'] + '/c_dep/', 'src/').gsub('#', '/') }]) do |t|
rule /\.bin$/ do |t|
  compile_c_binary(t.name, $opt)
end
# file $binary => c_obj do
#   compile_c_binary($binary, $opt)
# end

# # Build static library.
rule /\.a$/, [:c_obj, :opt] do |t, args|
  raise ArgumentError.new('Empty object list') if args[:c_obj].empty? || args[:opt].empty?
  link_c_static_library(t.name, args.c_obj, $opt)
end
# file static_lib => c_obj do
#   link_c_static_library(static_lib, c_obj, $opt)
# end

# # Build shared library.
rule /\.so$/, [:c_obj, :opt] do |t, args|
  raise ArgumentError.new('Empty object list') if args[:c_obj].empty? || args[:opt].empty?
  link_c_shared_library(t.name, args.c_obj, $opt)
end

def compile_c_dependency_file(src_file, dep_file, opt)
  create_directory_of_file_if_missing(dep_file)
  run_sh_cmd_formatted_with_target("#{$opt['c_compiler']} -MM #{$opt['c_include_path']} #{src_file} -o #{dep_file}",
                                   'DEP', to_abs_module_name($opt['build_dir'], src_file), opt['target'], opt['verbose_cmd'], opt['dry_run'])
end

def compile_c_object_file(src_file, obj_file, opt)
  create_directory_of_file_if_missing(obj_file)
  run_sh_cmd_formatted_with_target("#{$opt['c_compiler']} #{opt['c_code_gen'][:compile]} #{opt['c_code_gen'][:optimization]} #{opt['c_warnings']} #{$opt['c_include_path']} -c " + src_file + " -o #{obj_file}",
                                   'CC', to_abs_module_name($opt['build_dir'], obj_file), opt['target'], opt['verbose_cmd'], opt['dry_run'])
end

def compile_c_binary(binary, opt)
  create_directory_of_file_if_missing(binary)
  #obj_files = FileList["build/#{opt['target']}/*.o"]
  run_sh_cmd_formatted_with_target("#{opt['c_compiler']} build/#{opt['target']}/c_obj/*.o #{opt['c_link']} #{opt['c_warnings']} -o #{binary}",
                                   'LINK BIN', binary, opt['target'], opt['verbose_cmd'], opt['dry_run'])
end

def compile_c_vendor_object_without_warnings(source, object, opt)
  create_directory_of_file_if_missing(object)
  run_sh_cmd_formatted("#{opt['c_compiler']} -c #{source} -o #{object}",
                       'CC VENDOR', object, opt['verbose_cmd'], opt['dry_run'])
end

def link_c_binary(binary, obj_list, opt)
  create_directory_of_file_if_missing(binary)
  run_sh_cmd_formatted_with_target("#{opt['c_compiler']}         #{obj_list} #{opt['c_include_path']} #{opt['c_warnings']} #{opt['c_code_gen'][:link]} -o #{binary}                      #{opt['c_link']}",
                       'LINK TEST', binary, opt['target'], opt['verbose_cmd'], opt['dry_run'])
end

def link_c_static_library(library, obj_list, opt)
  raise ArgumentError.new('Empty object list') if obj_list.empty?
  create_directory_of_file_if_missing(library)
  run_sh_cmd_formatted_with_target("ar crs #{library} #{obj_list}",
                       'LINK STATIC LIB', library, opt['target'], opt['verbose_cmd'], opt['dry_run'])
end

def link_c_shared_library(library, obj_list, opt)
  raise ArgumentError.new('Empty object list') if obj_list.empty?
  create_directory_of_file_if_missing(library)
  run_sh_cmd_formatted_with_target("#{opt['c_compiler']} -shared #{obj_list}                          #{opt['c_warnings']} #{opt['c_code_gen'][:link]} -o #{library}                     #{opt['c_link']}",
                       'LINK SHARED LIB', library, opt['target'], opt['verbose_cmd'], opt['dry_run'])
  end


def link_c_binary_with_check_framework(binary, obj_list, opt)
  create_directory_of_file_if_missing(binary)
  # run_sh_cmd_formatted_with_target("#{opt['c_compiler']} #{obj_list} #{opt['c_include_path']} #{opt['c_warnings']} #{opt['c_code_gen'][:link]} -o #{binary} -lcheck -lm -pthread -lrt #{opt['c_link']}",
  #                      'LINK TEST', binary, opt['target'], opt['verbose_cmd'], opt['dry_run'])
  run_sh_cmd_formatted_with_target("#{opt['c_compiler']} #{obj_list} #{opt['c_include_path']} #{opt['c_warnings']} #{opt['c_code_gen'][:link]} -o #{binary} -lcheck -lm -pthread #{opt['c_link']}",
                       'LINK TEST', binary, opt['target'], opt['verbose_cmd'], opt['dry_run'])
end

# Alias for "link_c_binary_with_check_framework()"
def compile_c_test_binary(binary, obj_list, opt)
  create_directory_of_file_if_missing(binary)
  link_c_binary_with_check_framework(binary, obj_list, opt)
end
