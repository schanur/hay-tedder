
desc 'Run static code analysing tools on the source.'
task :analyze do
  # sh 'cppcheck --enable=all --inconclusive -f -q -Isrc -Isrc/extern/platform/src --suppress=missingIncludeSystem $(find src/ -name "*.c" |grep -v unittest) 2>&1'
  filter_string = %{
    cppcheck \
    --enable=all --inconclusive -f -q #{$c_compiler_include} --suppress=missingIncludeSystem \
    \
    $(find src/ -name "*.c" | grep -v unittest) 2>&1 \
    \
    | grep -v "is never used" \
    | grep -v "can be reduced" \
    | grep -v "is reassigned a value before the old one has been used" \
    \
    || true
}
  sh filter_string
end
