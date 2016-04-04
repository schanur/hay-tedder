#require 'optparse'
#require 'pp'

########################################################################
# cmd_params.rake begin
########################################################################

# All allowed values for all options
$allowed_options  = {
  'target'           => ['release', 'debug', 'coverage', 'profile'],
  'c_compiler'       => ['clang',   'gcc',   'colorgcc', 'x86_64-w64-mingw32-gcc', 'i686-w64-mingw32-gcc', 'x86_64-w64-mingw32-gcc-win32', 'i686-w64-mingw32-gcc-win32', 'avr-gcc'],
  'verbose_cmd'      => ['no',      'yes'],
  'dry_run'          => ['no',      'yes'],
  # 'break_on_warning' => ['no',      'yes'],
  'build_root'       => ['build',   :all_values_allowed],
  '-j'               => ['1', '8', '32']
}

$allowed_tasks = ['default', 'build', 'c_modules', 'link' , 'autotest', 'rsync']

$warnings = {
  'clang'                        => ' -Weverything -Wno-padded -Wno-missing-noreturn -Wno-disabled-macro-expansion -Wno-empty-translation-unit -Wno-format-security -Wno-format-nonliteral',
  'gcc'                          => ' -Wall -std=c11',
  'colorgcc'                     => ' -Wall -std=c11',
  'x86_64-w64-mingw32-gcc'       => ' -Wall -std=c11',
  'i686-w64-mingw32-gcc'         => ' -Wall -std=c11',
  'x86_64-w64-mingw32-gcc-win32' => ' -Wall -std=c11',
  'i686-w64-mingw32-gcc-win32'   => ' -Wall -std=c11',
  'avr-gcc'                      => ' -Wall -std=c11',
  #  'gcc'   => '-Wall -Werror'
}

def get_target_platform_by_c_compiler(compiler)
  target_platform = nil
  compiler_by_platform = {
    :posix   => ['clang', 'gcc', 'colorgcc'],
    :windows => ['x86_64-w64-mingw32-gcc', 'i686-w64-mingw32-gcc', 'x86_64-w64-mingw32-gcc-win32', 'i686-w64-mingw32-gcc-win32'],
    :avr     => ['avr-gcc']
  }
  compiler_by_platform.each do |platform, compiler_list|
    if compiler_list.include?(compiler)
      raise "compiler was found in multible platform lists." if target_platform
      target_platform = platform
    end
  end
  raise "Compiler was not found in a platform list." if !target_platform
  return target_platform
end

def generate_c_code_gen_options(target, compiler)
  code_gen_opt = Hash.new

  case target.to_sym
  when :embedded
    code_gen_opt[:optimization]     = '-Os -DNDEBUG'
    code_gen_opt[:optimization_hot] = '-O3 -DNDEBUG'
    code_gen_opt[:compile]          = ''
    code_gen_opt[:link]             = ''
  when :release
    # -ffast-math -fno-math-errno -funsafe-math-optimizations -fassociative-math -freciprocal-math -ffinite-math-only -fno-signed-zeros -fno-trapping-math
    code_gen_opt[:optimization]     = '-Os -DNDEBUG'
    code_gen_opt[:optimization_hot] = '-O3 -DNDEBUG'
    code_gen_opt[:compile]          = '-fPIC'
    code_gen_opt[:link]             = ''
    #code_gen_opt[:link]             = '-flto'
  when :debug
    code_gen_opt[:optimization]     = '-O0 -g'
    code_gen_opt[:optimization_hot] = '-O0 -g'
    code_gen_opt[:compile]          = '-fPIC -D_FORTIFY_SOURCE=2'
    # code_gen_opt[:compile]          = '-fPIC -D_FORTIFY_SOURCE=2 -fsanitize=address' /* clang address sanitizer does not work with shared library (-fPIC). */
    code_gen_opt[:link]             = ''
  when :coverage
    code_gen_opt[:optimization]     = '-O0 -g'
    code_gen_opt[:optimization_hot] = '-O0 -g'
    # code_gen_opt[:compile]          = '-fprofile-arcs -ftest-coverage'
    # code_gen_opt[:link]             = '-lgcov'
    code_gen_opt[:compile]          = '-fPIC --coverage'
    code_gen_opt[:link]             = '--coverage'
  when :profile
    code_gen_opt[:optimization]     = '-O0 -g -pg'
    code_gen_opt[:optimization_hot] = '-O0'
    code_gen_opt[:compile]          = '-fPIC'
    code_gen_opt[:link]             = '-pg'
  else
    raise 'Unknown target'
  end
  # code_gen_opt[:compile] += ' -std=c11 '
  return code_gen_opt
end

def parse_task()
  task = ARGV.select {|arg| arg.include?("=") == false}
  case task.size
  when 1
    # Check if task is valid.
    task = task[0]
  when 0
    # Use default target.
    task = ''
  else
    raise 'Multible targets found.'
  end
  return task
end

# Check if an option is available in the global allowed_options hash.
def is_allowed_option(key)
  return $allowed_options.key?(key)
end

# Check if the option parameter "key" allowes the value "value".
def is_allowed_option_value(key, value)
  raise 'Invalid key' + key unless $allowed_options.key?(key)
  return false unless $allowed_options[key].include?(value) or $allowed_options[key].include?(:all_values_allowed)

  return true
end

def parse_options(opt)
  opts = ARGV.select {|arg| arg.include?("=") == true}
  opts.each do |option|
    raise 'Invalid option sytax: '       + option if     option.count('=') != 1 # Argument is of form "$string1=$string2=$string3"
    key, value = option.split('=')
    raise 'Option or value is empty string.'      if     key == nil or value == nil # Check for the invalid strings '=$STRING' '$STRING=' and '='
    raise 'Invalid option found: '       + key    unless is_allowed_option(key)
    raise 'Invalid option value found: ' + value  unless is_allowed_option_value(key, value)
    opt[key] = value
  end
end

#
def set_empty_to_user_default(opt)
  $default_options.each do |key, value|
    raise 'invalid option found in configuration file: $default_options: option: ' + key   unless is_allowed_option(key)
    raise 'invalid option found in configuration file: $default_options: value: '  + value unless is_allowed_option_value(key, value)

    if not opt.include?(key)
      # Use first value in the list of allowed
      # values as default value.
      opt[key] = $allowed_options[key][0]
    end
  end
end

def set_empty_to_rake_default(opt)
  $allowed_options.keys.each do |option|
    if not opt.include?(option)
      # Use first value in the list of allowed
      # values as default value.
      opt[option] = $allowed_options[option][0]
    end
  end
end

def set_depending_options(opt)
  opt['c_flags'] = get_c_flags_by_compiler
end

def post_validate_values(opt)
  # If build directory has trailing '/' character, remove it.
  if opt['build_root'][-1] == '/'
    opt['build_root'] = opt['build_root'][0..-2]
  end
  opt['build_dir'] = File.join(opt['build_root'], opt['target'])

  # Set the optimizing options/debug options depending on the
  # target and compiler.
  opt['c_code_gen']           = generate_c_code_gen_options(opt['target'], opt['compiler'])
  # Set the C compiler warning flags based on the compiler.
  opt['c_warnings']           = $warnings[opt['c_compiler']]
  # Set the C compiler include paths.
  opt['c_include_path']       = '-Isrc -Isrc/extern/platform/src'
  # Set the C compiler libraries to link.
  #opt['c_link'] = '-lm -lGL -lglfw -OpenCL'
  # opt['c_link']          = '-lpthread -lm -lGL -lOpenCL -L/usr/local/lib -lSDL2'
  #opt['c_link_opt']      = ' -Wl,-rpath=/usr/local/lib'
  opt['c_link_opt']           = ' '
  # TODO: Windows hack
  opt['c_link_path']          = '' #' -L/usr/local/lib'
  # TODO: Windows hack
  # opt['c_link_lib']           = '' '  -lSDL2main -lSDL2'
  # opt['c_link_lib_check']     = ''

  # opt['c_include_path']    += ' -Ivendor/sdl2_dev_mingw/version/x86_64-w64-mingw32/include'
  # # opt['c_link_path']     += ' -Lvendor/sdl2_dev_mingw/version/lib/x64'
  # opt['c_link_path']       += ' -Lvendor/sdl2_dev_mingw/version/x86_64-w64-mingw32/lib'


  # opt['c_include_path']    += ' -I/usr/include/SDL2 -D_REENTRANT'
  # opt['c_link_path']       += ' -L/usr/lib'

  target_platform = get_target_platform_by_c_compiler(opt['c_compiler'])
  if    target_platform == :posix
    opt['c_link_lib']         = ' -lm -lpthread -lSDL2main -lSDL2 -lrt -lX11'
    opt['c_link_lib_check']   = ''

  elsif target_platform == :windows
    # opt['c_link_lib']      += ' -lwsock32 -lpthread -lSDL2main'
    opt['c_link_lib']         = ' -lwsock32 -lpthread -mwindows -lmingw32 -lSDL2main -lSDL2 -lopengl32'
    # opt['c_link_lib']      += ' -lwsock32 -lpthread -lSDL2main -lSDL2 -lopengl32'

    # Windows check unit testing framework.
    opt['c_include_path']    += ' -Ivendor/check/version/include'
    opt['c_link_path']       += ' -Lvendor/check/version/lib'
    opt['c_link_lib_check']  += ' '

    # Windows SDL2
    opt['c_include_path']    += ' -Ivendor/sdl2_dev_mingw/version/i686-w64-mingw32/include'
    opt['c_link_path']       += ' -Lvendor/sdl2_dev_mingw/version/i686-w64-mingw32/lib'

  elsif target_platform == :avr
    opt['c_link_lib']         = ''
    opt['c_link_lib_check']   = ''


  else
    raise 'Target platform not handled properly.'
  end

  opt['c_link']          = " #{opt['c_link_path']} #{opt['c_link_lib']} #{opt['c_link_opt']}"
end

def parse_cmd_params(opt)
  parse_task()
  parse_options(opt)
  set_empty_to_user_default(opt)
  set_empty_to_rake_default(opt)
  post_validate_values(opt)
end


def print_options(opt)
  opt.each { |key, value|
    puts "#{key} => #{value}"
  }
end

# Print a list of available command line options
# followed by all valid arguments.
def print_available_options()
  $allowed_options.each { |key, value|
    printf "%-11s => %s\n", key, value.join(' ')
  }
end


def is_default_option(opt, option)
  return opt[option] == $allowed_options[option][0]
end

task :show_target_platform do
  puts_r("Compiler: " + $opt['c_compiler'])
  puts_r("Platform: " + get_target_platform_by_c_compiler($opt['c_compiler']).to_s)
end

def jobs_param()
  if Rake.application.options[:thread_pool_size]
    return Rake.application.options[:thread_pool_size] + 1
  else
    raise 'Rake.application.options[:thread_pool_size] was not available.'
  end
  # return 1
end

# All options passed on the command line
def default_options()
  puts "Default options were loaded."
  return $opt
end

########################################################################
# cmd_param.rake end
########################################################################
