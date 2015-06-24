require 'test_helper'

describe "assert_exists" do
  let(:root_dir) { Pathname.new(Dir.mktmpdir("minitestfs")) }
  let(:a_path) { root_dir + "a_file" }

  it "fails when the given path is not found" do
    l = lambda { assert_exists(a_path) }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(/expected `#{a_path}` to exist/im)
  end

  it "allows to print custom error messages" do
    failure_msg = "I really miss this path a lot"

    l = lambda { assert_exists(a_path, failure_msg) }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_equal(failure_msg)
  end
end
