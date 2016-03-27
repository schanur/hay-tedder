
task :swig_include_header do
end


task :swig_generate_wrapper_source_file do
end

desc 'Generate shared library which can imported in scripting language.'
# task :swig => [:link_static_lib, :swig_include_header, :swig_generate_wrapper_source_file, :swig_compile_wrapper_source_file, :swig_link_wrapper_module]

task :swig,                  [:opt] do |t, args|
  args.with_defaults(:opt => default_options()) if args[:opt].nil?
  :link_shared_lib
  swig_create_library(:python, args[:opt])
end

# desc 'Create foreign language calling interface for the whole library.'
# task :swig do
#   swig_create_library(:python, $opt)
# end

def swig_compile_python_wrapper(out_file, wrapper_source_file, opt)
  # TODO: remove with link flags from cmd_param.rake. ??
  # sh "gcc -c -fPIC #{wrapper_source_file} -I/usr/include/python3.4 -I/usr/include/tcl -I. -Isrc -Isrc/extern/platform/src -ltcl -lm -lSDL2 -lSDL2main -o #{out_file}"
  sh "gcc -c -fPIC #{wrapper_source_file} -I/usr/include/python3.4 -I/usr/include/tcl -I. -Isrc -Isrc/extern/platform/src -o #{out_file}"
  # sh "gcc -shared #{wrapper_source_file} -I/usr/include/python3.4 -I/usr/include/tcl -I. -Isrc -Isrc/extern/platform/src -o #{out_file}"
end

def swig_gen_interface(out_file, opt)
  c_header_files = FileList['src/**/*.h'] \
                   .exclude('src/vector/**') \
                   .exclude('src/extern/platform/src/platform/*.h') \
                   .exclude('src/debug.h')

  # puts c_source_files
  File.open(out_file, 'w') do |file|
    file.write    ("%module ort\n"    )
    file.write    ("    %{\n"         )
    file.write    ("        #define SWIG_FILE_WITH_INIT\n")
    c_header_files.each do |header_file|
      file.write  ("        #include \"#{header_file}\"\n")
    end
    file.write    ("    %}\n"         )
    # file.write    ("        #define SWIG_FILE_WITH_INIT\n")
    c_header_files.each do |header_file|
      file.write  ("    %include     \"#{header_file}\"\n")
    end
  end
end

def swig_gen_wrapper(out_file, interface_file, language, opt)
  # out_file = "swig_wrap.python.c"
  sh "swig3.0 -python -o #{out_file} #{interface_file}"
end

def swig_link_wrapper_module(out_file, wrapper_obj_file, lib_obj_file, opt)
  # sh "ld -shared swig_wrap.o build/release/ort.a -o build/release/_ort.so"
  # sh "clang -shared #{wrapper_obj_file} #{lib_obj_file} -ltcl -lm -lSDL2 -lSDL2main -o #{out_file}"
  # sh "gcc -c -fPIC #{wrapper_obj_file} #{lib_obj_file} -ltcl -lm -lSDL2 -lSDL2main -o #{out_file}"
  sh "gcc -shared #{wrapper_obj_file} #{lib_obj_file} -ltcl -lm -lSDL2 -lSDL2main -o #{out_file}"
  # sh "gcc -shared #{wrapper_obj_file} #{lib_obj_file} -ltcl -lm -lSDL2 -lSDL2main -Xlinker -rpath . -o #{out_file}"
end

def swig_create_library(language, opt)
  out_dir = File.join(opt['build_dir'], language.to_s)
  create_directory_if_missing(out_dir)

  swig_interface_file          = File.join(out_dir, 'swig.i')
  swig_wrapper_src_file        = File.join(out_dir, 'swig_wrap.python.c')
  swig_wrapper_obj_file        = File.join(out_dir, 'swig_wrap.python.o')
  swig_wrapper_shared_lib_file = File.join(out_dir, 'swig_wrap.python.so')
  library_obj_file             = File.join(opt['build_dir'], 'ort.a')
  final_shared_library         = File.join(out_dir, 'ort.so')
  swig_gen_interface(            swig_interface_file,                                            opt)
  swig_gen_wrapper(              swig_wrapper_src_file, swig_interface_file,   language.to_s,    opt)
  swig_compile_python_wrapper(   swig_wrapper_obj_file, swig_wrapper_src_file,                   opt)
  swig_link_wrapper_module(      final_shared_library,  swig_wrapper_obj_file, library_obj_file, opt)
end

# def compile_c_binary(binary, opt)
#   #obj_files = FileList["build/#{opt['target']}/*.o"]
#   run_sh_cmd_formatted_with_target("#{opt['c_compiler']} build/#{opt['target']}/*.o #{opt['c_link']} #{opt['c_warnings']} -o #{binary}",
#                        'LINK BIN', binary, opt['target'], opt['verbose_cmd'], opt['dry_run'])
# end


# rule( /\.python.c$/ => [proc {|task_name| task_name.sub('.d', '.c').sub($opt['build_dir'] + '/', 'src/').gsub('#', '/') }]) do |t|
#   compile_c_dependency_file(t.source, t.name, $opt)
#   #compile_c_dependency_file(t.source, t.name, $obj)
# end
