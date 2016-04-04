$project_base_name = 'ort'

$binary            = $project_base_name + '.bin'
$static_lib        = $project_base_name + '.a'
$shared_lib        = $project_base_name + '.so'

# Returns a FileList containing all C source files (no header).
# Example list item transformation: src/octree/iterator.c
def c_source_file_list()
  puts FileList['src/**/*.c'].exclude('**/unittest/**').exclude('**/vendor/**')
  return FileList['src/**/*.c'].exclude('**/unittest/**').exclude('**/vendor/**')
end

# Transform a list of C source file names to a list of FIXME.  Example
# list item transformation: "src/octree/iterator.c" =>
def c_concat_file_list()
  return c_source_file_list().gsub(/\//, '#').sub(/src\#/, '')
end

# Transform a list of C source file names to a list of dependency file
# names.  Example list item transformation: "src/octree/iterator.c" =>
# "/c_dep/octree#iterator.dep"
def c_dep_job_file_list()
  return c_source_file_list().gsub(/\//, '#').sub(/src\#/, '/c_dep/').sub(/\.c$/, '.dep').sub('/', '')
end


# Transform a list of C "dep" file names in the "c_dep directory "to a
# list of .  Example list item transformation:
# "/c_dep/octree#iterator.dep" => "/c_obj/octree#iterator.o"
def c_obj_file_list()
  return c_dep_job_file_list().sub('.dep', '.o').sub('c_dep', 'c_obj').sub('/', '')
end
