require 'uri'
require 'pathname'
require 'fileutils'

$vendor_module_path = 'rakelib'

# Filenames of files which get created on packet
# installation. "vendor_install_start_filename"
# is created before the packet specific install_func
# gets called. "vendor_install_success_filename"
# is created afterwards. It indicates a successful
# packet installation.
$vendor_install_start_filename      = 'install_start'
$vendor_install_success_filename    = 'install_success'

$vendor_module_data_list            = Hash.new
$vendor_module_clean_func_list      = []

vendor_default_clean_by_path_delete = Proc.new do |vendor|
  raise 'Not implamanted'
end

# Can be used by vendor modules as default method
# to check if a module was installed successfully.
# It checks if the directory was created and
# the 2 installation state files exist.
vendor_default_is_installed         = Proc.new do |vendor|
  install_start_file = File.join(vendor_item[:install_path], $vendor_install_start_filename)
  install_succ_file  = File.join(vendor_item[:install_path], $vendor_install_success_filename)
  File.directory?(vendor_item[:install_path]) and File.file?(install_start_file) and File.file?(install_succ_file)
end


def vendor_register_module_tasks(module_name, vendor)
  require 'pp'
  # pp vendor
  install_task_name = "vendor_install_" + module_name.to_s
  # clean_task_name   = "vendor_clean_"   + vendor[:name]
  # puts_r("vendor_register_module_tasks: #{install_task_name} #{clean_task_name}")
  # puts_r("vendor_register_module_tasks: #{install_task_name}")
  task install_task_name.to_sym do
    puts_verbose("block: #{install_task_name}")
    vendor_install_enclosure(vendor)
  end
  # task clean_task_name.to_sym do
  #   puts "block: #{install_task_name}"
  # end
end

# Each module has to regitser itself by calling
# "vendor_add_vendor_module()" with module_data
# containing the following items:
# :name => Name of the vendor module.
#
def vendor_add_vendor_module(module_name, module_data)
  # Check if all fields exist and have valid data.
  # raise if !module_data.key?(:name)

  # Check if modules was added earlier.
  raise "Module \"#{module_name}\" was added earlier." if $vendor_module_data_list.key?(module_name)

  # Add to global vendor module_list.
  $vendor_module_data_list[module_name] = module_data

  # Create install and clean tasks.
  vendor_register_module_tasks(module_name, module_data)
end

# Allow a module to register multible modules at once.
# The parameter "module_data_list" jas to be a hash
# of the following structure:
# {$name1 => module1, ...}
def vendor_add_vendor_module_list(module_data_list)
  module_data_list.each do |module_name, module_data|
    vendor_add_vendor_module(module_name, module_data)
  end
end

# Returns an array of all subdirectories in the
# in the directory "base_path".
def vendor_path_directory_list(base_path)
#  Dir.glob('*').select {|f| File.directory? f}
  Pathname.new(base_path).children.select { |c| c.directory? }.collect { |p| p.to_s }
end

#def vendor_path_dirty?(path)

#end

# Download a resource from the network with wget.
def vendor_download(download_link, out_path)
  cmd = "wget -q -P #{out_path} #{download_link}"
  puts_verbose('Downloading command: ' + cmd)
  sh cmd
end


def vendor_download_link_2_basename(download_link)
  uri = URI.parse(download_link).path
  #File.basename(URI.parse(download_link).path)
end

#
def vendor_extract_tar_file(tar_file, out_path)
  cmd = "tar -xf #{tar_file} -C #{out_path}"
  puts_verbose('Tar file extraction command: ' + cmd)
  sh cmd
end

def vendor_create_link_in_install_dir(target, link)
  target_basename = File.basename(target);
  cmd             = "ln -s #{target_basename} #{link}"
  puts_verbose('Version link command: ' + cmd)
  sh cmd
end

#
def vendor_create_version_link(target, out_path)
  link = File.join(out_path, 'version')
  vendor_create_link_in_install_dir(target, link)
end

def vendor_create_installation_state_file(filename)
  raise "Installation state file \"#{filename}\" already exists. Abort." if File.file?(filename)
  FileUtils.touch(filename)
end

# def vendor_set_installation_state(path)

# end

# def vendor_get_installation_state(path)

# end

# def vendor_submodule_status()

# Calls the installation routine of a vendor module but is
# also responsible fo preparation and cleanup oprations
# before and after the installation routine
def vendor_install_enclosure(vendor)
  install_start_file = File.join(vendor[:install_path], $vendor_install_start_filename)
  install_succ_file  = File.join(vendor[:install_path], $vendor_install_success_filename)
  download_basename  = vendor_download_link_2_basename(vendor[:download_link]).sub('release/', '')
  download_filename  = File.join(vendor[:install_path], download_basename)

  # Should never happen because the empty 'vendor' directory
  # is added to the repository.
  if !File.directory?('vendor')
    Dir.mkdir('vendor')
  end

  if !File.directory?(vendor[:install_path])
    Dir.mkdir(vendor[:install_path])
    puts_verbose('Create vendor directory.')
  else
    raise 'Last installation attempt failed. Install start file exists but install success file does not exist.' if (File.file?(install_start_file) and !File.file?(install_succ_file))
    puts_verbose('Empty vendor directory found.')
  end

  if !File.file?(download_filename)
    vendor_download(vendor[:download_link], vendor[:install_path])
  else
    puts_verbose("Download of file '#{download_filename}' skipped. File already exists.")
  end
  vendor_create_installation_state_file(install_start_file)
  vendor[:install_func].call(vendor)
  # If things have not failed until here, we
  # can also create the "success file" which
  # indicates that there is nothing to do
  # next time.
  vendor_create_installation_state_file(install_succ_file)
end

multitask :vendor_install => [:vendor_install_sdl2]
multitask :vendor_update  => [:vendor_update_sdl2]

multitask :vendor_clean   => [:vendor_clean_sdl2, :vendor_clean_check]

desc 'List all available extenal dependencies which can be installed by vendor module.'
task      :vendor_list_modules do
  $vendor_module_data_list.each do |name, data|
    puts_r(name)
  end
  # puts_r($vendor_module_data_list)
end

# task      :vendor_status do
#   raise
# end

# # Check that each vendor module which exist as file in the directory
# # "$vendor_module_path" has registered itself on load by calling
# # "vendor_add_vendor_module()" with valid parameters.
# task      :vendor_check_modules do
#   filter_prefix        = "#{$vendor_module_path}/vendor_"
#   filter_postfix       = ".rake"
#   file_filter_str      = "#{filter_prefix}*#{filter_postfix}"
#   #module_list_by_files =
#   FileList[file_filter_str].sub(filter_prefix, '').sub(filter_postfix, '').each do |module_name|
#     raise "Module #{module_name} has not registered itself." if !$vendor_module_data_list.key?(module_name.to_sym)
#   end
#   # TODO: Check for registered modules that does not exist as file.
# end
