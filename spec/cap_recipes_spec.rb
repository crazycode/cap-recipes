require File.expand_path("spec_helper", File.dirname(__FILE__))
require File.dirname(__FILE__) + '/../lib/capify'

describe 'loading everything' do
  def run_cap(folder,task)
    folder = File.join(File.dirname(__FILE__),'cap',folder)
    `cd #{folder} && #{task}`
  end

  it "finds all tasks" do
    tasks = run_cap 'all', 'cap -T'
    tasks.split("\n").size.should >= 20
  end
end

describe "cap-recipes command" do
  
  before(:all) do
    @test_path = 'test/'
    @cap_recipes = CapRecipes.dup
    @cap_file = File.join @test_path, 'Capfile'
    @deploy_file = File.join @test_path, 'config/deploy.rb'
  end
  
  after(:each) do
    `rm -rf #{@test_path}`
  end
  
  it "should show the description on --help" do
    capture(:stdout) { @cap_recipes.start(['--help']) }.should match(/Usage/)
  end
  
  it "should show the list of recipes" do
    capture(:stdout) { @cap_recipes.start(['--list']) }.should match(/Available Recipes/)
  end
  
  it "should generate Capfile and config/deploy.rb" do
    capture(:stdout) { @cap_recipes.start([@test_path]) }.should match(/create/)
    File.exists?(@cap_file).should be_true
    File.exists?(@deploy_file).should be_true
  end
  
  it "should generate deploy.rb with apache" do
    capture(:stdout) { @cap_recipes.start([@test_path,'apache']) }.should match(/create/)
    File.open(@deploy_file).read.should match(/require \'cap_recipes\/tasks\/apache\'/)
  end
  
  it "should generate deploy.rb with passenger and gitosis" do
    capture(:stdout) { @cap_recipes.start([@test_path,"passenger","gitosis"]) }.should match(/create/)
    response = File.open(@deploy_file).read
    response.should match(/require \'cap_recipes\/tasks\/passenger\'/)
    response.should match(/require \'cap_recipes\/tasks\/gitosis\'/)
  end
  
  
end