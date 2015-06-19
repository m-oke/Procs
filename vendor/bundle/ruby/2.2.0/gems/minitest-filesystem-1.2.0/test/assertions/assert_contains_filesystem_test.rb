require 'test_helper'

describe "assert_contains_filesystem" do
  let(:root_dir) { Pathname.new(Dir.mktmpdir('minitestfs')) }
  before do
    (root_dir + 'a_directory').mkdir
    (root_dir + 'a_subdirectory').mkdir
    (root_dir + 'a_subdirectory' + 'deeper_subdirectory').mkdir
    (root_dir + 'not_a_file').mkdir
    (root_dir + 'unchecked_dir').mkdir
  
    touch root_dir + 'a_file'
    touch root_dir + 'actual_file'
    symlink root_dir + 'doesnt_matter', root_dir + 'a_link'
    symlink root_dir + 'actual_file', root_dir + 'link_to'
    touch root_dir + 'not_a_dir'
    touch root_dir + 'not_a_link'
    touch root_dir + 'a_subdirectory' + 'deeper_subdirectory' + 'another_file'
    touch root_dir + 'unchecked_file'
  end
  
  after do
    rm root_dir
  end

  it "passes with empty expected tree" do
    assert_contains_filesystem(root_dir) {}
  end

  it "passes when single file found" do
    assert_contains_filesystem(root_dir) do
      file "a_file"
    end
  end

  it "passes when single link found" do
    assert_contains_filesystem(root_dir) do
      link "a_link"
    end
  end

  it "passes when a link points to the correct target" do
    assert_contains_filesystem(root_dir) do
      link "link_to", "actual_file"
    end
  end

  it "passes when single directory found" do
    assert_contains_filesystem(root_dir) do
      dir "a_directory"
    end
  end

  it "passes when a file within a nested subtree is found" do
    assert_contains_filesystem(root_dir) do
      dir "a_subdirectory" do
        dir "deeper_subdirectory" do
          file "another_file"
        end
      end
    end
  end

  it "fails when an expected file isn't found" do
    l = lambda { assert_contains_filesystem(root_dir) do
      file "foo"
    end }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(/expected `#{root_dir}` to contain file `foo`/im)
  end

  it "fails when an expected symlink isn't found" do
    l = lambda { assert_contains_filesystem(root_dir) do
      link "foo"
    end }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(/expected `#{root_dir}` to contain symlink `foo`/im)
  end

  it "fails when a symlink points to the wrong file" do
    l = lambda { assert_contains_filesystem(root_dir) do
      link "link_to", "nonexistent_target"
    end }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(/expected `link_to` to point to `nonexistent_target`/im)
  end

  it "fails when an expected directory isn't found" do
    l = lambda { assert_contains_filesystem(root_dir) do
      dir "bar"
    end }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(/expected `#{root_dir}` to contain directory `bar`/im)
  end

  it "fails when an expected file within a subdirectory isn't found" do
    l = lambda { assert_contains_filesystem(root_dir) do
      dir "a_subdirectory" do
        file "missing_file"
      end
    end }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(
      /expected `#{root_dir + 'a_subdirectory'}` to contain file `missing_file`/im)
  end

  it "fails when a directory is expected to be a file" do
    l = lambda { assert_contains_filesystem(root_dir) do
      file "not_a_file"
    end }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(/expected `not_a_file` to be a file/im)
  end

  it "fails when a file is expected to be a directory" do
    l = lambda { assert_contains_filesystem(root_dir) do
      dir "not_a_dir"
    end }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(/expected `not_a_dir` to be a directory/im)
  end

  it "fails when a file is expected to be a symlink" do
    l = lambda { assert_contains_filesystem(root_dir) do
      link "not_a_link"
    end }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(/expected `not_a_link` to be a symlink/im)
  end

  it "allows to print custom error messages" do
    failure_msg = "I really miss this file a lot"

    l = lambda { assert_contains_filesystem(root_dir, failure_msg) do
      file "baz"
    end }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_equal(failure_msg)
  end
end
