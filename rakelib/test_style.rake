# style_test_sub_dir               = $opt['build_dir'] + '/' + 'var/style'
# # c_source
# style_test_script_list           = FileList['test/style/*']
# style_test_symbol_list           = style_test_script_list.sub('.sh', '').sub('test/style/', '').map{ |script_name| script_name.to_sym() }



# rule /\.$/ do |t|
#   defines_have_prefix
# end


# multitask :test_style => style_test_symbol_list


# rule( /\.defines_have_prefix$/ => [proc {|task_name| task_name.sub('.defines_have_prefix', '.c').sub($opt['build_dir'] + '/', 'src/').gsub('#', '/') }]) do |t|

# task      :test_style => c_source_files




task      :print_style_tests do
  style_test_script_list.each do |style_test_script|
    puts(style_test_script)
  end
  puts('');
  style_test_symbol_list.each do |style_test_symbol|
    puts(style_test_symbol)
  end
end

task      :test_style_clean do
  del_files = FileList["#{$opt['build_dir']}/#{$style_test_sub_dir}/"]
  delete_filelist_dry_run(del_files, $opt)
end
