desc 'Print all interesting variables for debugging purposes.'
task      :print_variables do
  file_arrays = {:c_source_files => c_source_files, :c_concat_files => c_concat_files, :c_dep_job => c_dep_job, :c_obj => c_obj}
  puts
  puts 'argv:'
  puts ARGV
  puts
  puts 'global_variables:'
  puts global_variables
  puts
  puts 'Rake::Application:'
  puts Rake.application.options
  puts
  puts 'Number of allowed jobs:'
  puts jobs_param
  puts
  puts 'Options:'
  put_separator
  print_options($opt)
  puts
  puts 'Files:'
  put_separator
  file_arrays.each do |name, file_list|
    #puts 'Name:'
    puts "#{name}:"
    file_list.each do |file|
      #puts 'file:'
      puts "  #{file}"
    end
  end
end
