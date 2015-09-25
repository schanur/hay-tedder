vendor_install_dev_mingw = Proc.new do |vendor|
  puts_verbose('vendor_install_mingw')
  tar_archive_basename = vendor_download_link_2_basename(vendor[:download_link]).sub('release/', '')
  tar_archive_filename = File.join(vendor[:install_path], tar_archive_basename)
  directory_exists     = !vendor_path_directory_list(vendor[:install_path]).size.zero?

  if !directory_exists
    vendor_extract_tar_file(tar_archive_filename, vendor[:install_path])
  else
    puts_verbose("Extraction of tar file skipped. Directory already exists.")
  end

  extraction_path      = vendor_path_directory_list(vendor[:install_path])[0]
  puts_verbose("extraction_path: " + extraction_path.to_s)

  vendor_create_version_link(extraction_path, vendor[:install_path])


  # raise
  # vendor[:install_path]
end

vendor_install_dev_vc    = Proc.new do |vendor|
  raise 'Not implemented'
end

vendor_install_lib_win32 = Proc.new do |vendor|
  raise 'Not implemented'
end

vendor_install_lib_win64 = Proc.new do |vendor|
  raise 'Not implemented'
end

vendor_clean_dev_mingw   = Proc.new do |vendor|
  raise 'Not implemented'
end

task :vendor_clean_sdl2 do
  raise 'Not implemented'
end

$sdl2_vendor_item_list = {
  :dev_mingw => {
    :install_path      => 'vendor/sdl2_dev_mingw',
    :download_link     => 'https://www.libsdl.org/release/SDL2-devel-2.0.3-mingw.tar.gz',
    :install_func      => vendor_install_dev_mingw,
    :clean_func        => :vendor_default_clean_by_path_delete,
    :is_installed_func => :vendor_default_is_installed
    # :clean_func    => vendor_clean_dev_mingw
  },
  # :dev_vc    => {
  #   :install_path      => 'vendor/sdl2_dev_vc',
  #   :download_link     => 'https://www.libsdl.org/release/SDL2-devel-2.0.3-VC.zip',
  #   :install_func      => vendor_install_dev_vc
  # },
  # :lib_win32 => {
  #   :install_path      => 'vendor/sdl2_lib_win32',
  #   :download_link     => 'https://www.libsdl.org/release/SDL2-2.0.3-win32-x86.zip',
  #   :install_func      => vendor_install_lib_win32
  # },
  # :lib_win64 => {
  #   :install_path      => 'vendor/sdl2_lib_win64',
  #   :download_link     => 'https://www.libsdl.org/release/SDL2-2.0.3-win32-x64.zip',
  #   :install_func      => vendor_install_lib_win64
  # }
}

vendor_add_vendor_module_list($sdl2_vendor_item_list)
