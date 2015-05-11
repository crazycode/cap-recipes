# Run me with:
#
# $ watchr specs.watchr
 
# --------------------------------------------------
# Helpers
# --------------------------------------------------
def run(cmd)
  puts(cmd)
  system(cmd)
end
 
def run_all_tests
  # see Rakefile for the definition of the test:all task
  system( "rake spec VERBOSE=true" )
end
 
# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch("^lib/(.*)\.rb") { |m| run("spec spec/cap_recipes_spec.rb -c") }
watch("spec.*/spec_helper\.rb") { run_all_tests }
watch('^spec.*/(.*)_spec\.rb') { |m|  run("spec spec/#{m[1]}_spec.rb -c")}
 
# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all tests ---\n\n"
  run_all_tests
end
 
# Ctrl-C
Signal.trap('INT') { abort("\n") }