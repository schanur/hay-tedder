task :help do
  puts ''
  puts 'Tasks:'
  put_separator
  verbose(false) do
    sh 'rake -T'
  end

  puts ''
  puts 'Options:'
  put_separator
  print_available_options
  # verbose(false) do

  # end
end

# task :help do
#   run_sh_cmd_quiet("rake -T", 'no')
# end
