@print_lock = Mutex.new

MAX_LOG_TYPE_STR_LEN=17

$bash_color_table = {
  :light_red     => 91,
  :light_green   => 92,
  :light_yellow  => 93,
  :light_blue    => 94,
  :light_magenta => 95,
  :light_cyan    => 96,
  :white         => 97,
  :reset         => 0
}

def bash_color_str(color_symbol)
  raise "Color code does not exists." unless $bash_color_table.include?(color_symbol)
  color_str = "\033[" + $bash_color_table[color_symbol].to_s + "m"

  return color_str
end

# Thread safe puts version.
def puts_r(print_str)
  @print_lock.synchronize do
    puts print_str
    STDOUT.flush
  end
end

def puts_verbose(str)
  if $opt['verbose_cmd'] == 'yes'
    puts_r(str)
  end
end

def put_filelist(file_list)
  file_list.each do |file|
    puts "#{file}"
  end
end

# Print the string "str" embedded in the bash color tags to represent
# the color "color".
def put_color_str(str, color)
  puts_r(bash_color_str(color) + str + bash_color_str(:reset))
end

def put_log_str(log_type, log_str, color)
  put_color_str('[' + log_type + [' '].cycle(MAX_LOG_TYPE_STR_LEN - log_type.length).to_a.join('') + '] ' + log_str, color)
end

def put_native_test_result(test_result, assert_failures)
  _log_color   = :light_green
  _check_align = 2
  # puts test_summary[:suite]
  #return
  if test_result[:success] == false
    _log_color = :light_red
  end
  _log_str = str_target(test_result[:target]) + '[Checks: ' + int_left_aligned(test_result[:check], _check_align) + ' Failures: ' + int_left_aligned(test_result[:failure], _check_align) + ' Errors: ' + int_left_aligned(test_result[:error], _check_align) + '] [' + str_test_time(test_result[:time]) + '] ' + test_result[:suite]
  put_log_str('RUN TEST NATIVE', _log_str, _log_color)
  assert_failures.each do |assert_line|
    puts_r assert_line
  end
end

def put_separator
  puts '------------------------------------------------------------------------'
end

# def int_right_aligned(num, str_len)
#   return  [' '].cycle(str_len - num.to_s.length).to_a.join('') + num.to_s
# end

def int_left_aligned(num, str_len)
  return  num.to_s + [' '].cycle(str_len - num.to_s.length).to_a.join('')
end

def str_left_align(str, str_len)
  return  str + [' '].cycle(str_len - str.length).to_a.join('')
end

def str_cut_or_fill(str, fix_len, fill_chr)
  if str.length > fix_len
    fix_str = str[0..(fix_len - 1)]
  else
    raise 'Invalid value for parameter "fill_chr"' if fill_chr.length != 1
    fix_str = str + [fill_chr].cycle(fix_len - str.length).to_a.join('')
  end
end

def str_test_time(tms)
  return str_cut_or_fill(tms.real.to_s, 6, '0')
end

def str_target(target_str)
  return '[' + str_left_align(target_str, 'RELEASE'.length).upcase + '] '
end

