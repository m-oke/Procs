require 'test_helper'

describe "filesystem must_exist_within" do
  let(:root_dir) { Pathname.new(Dir.mktmpdir('minitestfs')) }

  before do
    (root_dir + 'a_directory').mkdir
    (root_dir + 'a_subdirectory').mkdir
    (root_dir + 'a_subdirectory' + 'deeper_subdirectory').mkdir
    (root_dir + 'not_a_file').mkdir
    (root_dir + 'unchecked_dir').mkdir
  
    touch root_dir + 'a_file'
    touch root_dir + 'not_a_dir'
    touch root_dir + 'a_subdirectory' + 'deeper_subdirectory' + 'another_file'
    touch root_dir + 'unchecked_file'
  end
  
  after do
    rm root_dir
  end

  it "passes when the expected tree is found" do
    filesystem {
      file "a_file"
      dir "a_subdirectory" do
        dir "deeper_subdirectory" do
          file "another_file"
        end
      end
    }.must_exist_within(root_dir)
  end

  it "fails when the expected tree is not found" do
    l = lambda { filesystem {
      file "a_file"
      dir "a_subdirectory"
      file "missing_file"
    }.must_exist_within(root_dir) }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(
      /expected `#{root_dir}` to contain file `missing_file`/im)
  end
end
