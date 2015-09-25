require 'open3'
require 'benchmark'

def parse_test_result(suite, test_summary)
  _suite_name = suite.sub('Running suite(s): ', '')
  _summary_status = {:percent => test_summary.sub('Test summary: ', '').split('%')[0].to_i}
  test_summary.split('%')[1].sub(': ', '').split(', ').each do |res|
    _summary_status[res.split('s: ')[0].downcase.to_sym] = res.split(': ')[1].to_i
  end
  return _summary_status
end

# Parse the output of a test binary which uses a summary
# similar to that of the check framework.
def run_test_native(binary, opt)
  _suite           = nil
  _test_summary    = nil
  _stdout_backup   = Array.new
  _stderr_backup   = Array.new

  begin
    _test_time = Benchmark.measure {
      Open3.popen3(binary) do |stdin, stdout, stderr|
        # begin
        stdout.readlines.each do |line|
          _stdout_backup.push(line)
          if line.include?('Running suite(s): ')
            raise 'Multible suite lines.' unless _suite.nil?
            _suite = line.sub('Running suite(s): ', '').sub("\n", '')
          elsif line.include?('Checks') and line.include?('Failures') and line.include?('Errors')
            raise 'Multible test summary lines.' unless _test_summary.nil?
            _test_summary = line
          else
            _stderr_backup.push(line)
          end
        end
        stderr.readlines.each do |line|
          _stderr_backup.push(line)
        end
      end
    }

    raise 'No suite line.'        if _suite.nil?
    raise 'No test summary line.' if _test_summary.nil?

  rescue => e
    puts 'Test summary parse error:'
    puts "reason: "
    puts e
    puts "Test output to stdout:"
    _stdout_backup.each do |line|
      puts line
    end
    puts "Test output to stderr:"
    _stderr_backup.each do |line|
      puts line
    end

    raise
  end

  _test_result         = parse_test_result(_suite, _test_summary)
  _test_result[:suite] = _suite
  _test_result[:time]  = _test_time
  if binary.include?('release')
    _target = 'RELEASE'
  else
    _target = 'DEBUG'
  end
  _test_result[:target]   = _target
  _test_result[:success]  = (_test_result[:percent] == 100 and _test_result[:failure] == 0 and _test_result[:error] == 0)
  #_test_result[:success]  = (_test_result[:percent] == 100 and _test_result[:failure] == 0 and _test_result[:error] == 0 and _test_result[:check] != 0)
  put_native_test_result(_test_result, _stderr_backup)
  return _test_result[:success]
end

def run_test_valgrind()

end
