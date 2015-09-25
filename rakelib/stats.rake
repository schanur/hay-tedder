task :stat do
  # Valuable options found so far: cloc cccc ohcount sloccount
  sh "cloc ."
end
