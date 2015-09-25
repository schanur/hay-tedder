
multitask :doc       => [:doxygen]
multitask :doc_clean => [:doxygen_clean]

$doxygen_config_path = 'doc'
$doxygen_output_path = 'doc/generated'

desc 'Build Doxygen documentation'
task :doxygen do
  config_file = File.join($doxygen_config_path, 'Doxyfile')
  run_sh_cmd_formatted("doxygen #{config_file} > /dev/null", 'DOCUMENTATION', 'Doxygen source code documentation', $opt['verbose_cmd'], $opt['dry_run'])
end

task :doxygen_clean do
  del_item_list = ['html', 'latex', 'doxygen_sqlite3.db']

  del_item_list.each do |del_item|
    abs_del_item = File.join($doxygen_output_path, del_item)
    if File.exists?(abs_del_item)
      delete_directory(abs_del_item, $opt)
    end
  end

  # The only file allowed to remain after deletion
  # is the ".gitignore" file.
  allowed_entries = ['.', '..', '.gitignore']
  Dir.foreach($doxygen_output_path) do |entry|
    raise 'Doxygen directory not empty after cleaning up.' if !allowed_entries.include?(entry)
  end
end
