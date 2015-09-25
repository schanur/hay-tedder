vendor_install_check = Proc.new do |vendor|
  puts_verbose('vendor_install_mingw')
  download_basename = vendor_download_link_2_basename(vendor[:download_link]).sub('projects/check/files/latest/', '')
  download_filename = File.join(vendor[:install_path], download_basename)
  directory_exists     = !vendor_path_directory_list(vendor[:install_path]).size.zero?

  if !directory_exists
    vendor_extract_tar_file(download_filename, vendor[:install_path])
  else
    puts_verbose("Extraction of tar file skipped. Directory already exists.")
  end

  extraction_path      = vendor_path_directory_list(vendor[:install_path])[0]
  puts_verbose("extraction_path: " + extraction_path.to_s)
  raise "Invalid extraction path: #{extraction_path}" if ! extraction_path.match(/check-\d+\.\d+\.\d+$/)
  # vendor_create_version_link(extraction_path, vendor[:install_path])


  check_version        = extraction_path.sub(/.+\/check-/, '')
  puts_verbose("check version: " + check_version)
  install_path         = File.expand_path(File.join(vendor[:install_path], 'installed-' + check_version))
  puts_verbose("install path:  " + install_path)
  Dir.chdir(extraction_path) do
    # sh "./configure --prefix=#{install_path}"
    sh "./configure --prefix=#{install_path} --host=i686-w64-mingw32"
    sh "make"
    # sh make check /* Is painfully slow on Cygwin. */
    sh "make install"
  end
  # configure_cmd  = "#{File.join(extraction_path, 'configure')} -srcdir=#{extraction_path}"
  # make_cmd       = "make -C #{extraction_path}"
  # sh configure_cmd
  # sh make_cmd

  puts_verbose("Create version link.")
  vendor_create_version_link(install_path, vendor[:install_path])

end

task :vendor_install_check do
end

def vendor_installed_check?(vendor_item)
  install_start_file  = File.join(vendor_item[:install_path], $vendor_install_start_filename)
  install_succ_file   = File.join(vendor_item[:install_path], $vendor_install_success_filename)

  File.directory?(vendor_item[:install_path]) and File.file?(install_start_file) and File.file?(install_succ_file)
end

task :vendor_installed_check do
  puts_verbose(vendor_installed?($check_vendor_item_list[:check]).to_s)

end

#task :vendor_update_check  => []

task :vendor_clean_check do
  raise 'Not implemented'
end

$check_vendor_item_list = {
  :check => {
    :install_path      => 'vendor/check',
    :download_link     => 'http://sourceforge.net/projects/check/files/latest/download',
    :install_func      => vendor_install_check,
    :clean_func        => :vendor_default_clean_by_path_delete,
    :is_installed_func => :vendor_default_is_installed
  }
}

vendor_add_vendor_module_list($check_vendor_item_list)
