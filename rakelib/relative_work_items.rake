$project_base_name = 'ort'

$binary            = $project_base_name + '.bin'
$static_lib        = $project_base_name + '.a'
$shared_lib        = $project_base_name + '.so'

def c_source_file_list()
  return FileList['src/**/*.c'].exclude('**/unittest/**').exclude('**/vendor/**')
end

def c_concat_file_list()
  return c_source_file_list().gsub(/\//, '#').sub(/src\#/, '')
end

def c_dep_job_file_list()
  return c_source_file_list().gsub(/\//, '#').sub(/src\#/, '/c_dep/').sub(/\.c$/, '.dep')
end

def c_obj_file_list()
  return c_dep_job_file_list().sub('.dep', '.o').sub('c_dep', 'c_obj')
end
