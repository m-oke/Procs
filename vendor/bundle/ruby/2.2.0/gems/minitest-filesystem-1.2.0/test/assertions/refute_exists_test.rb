require 'test_helper'

describe "refute_exists" do
  let(:root_dir) { Pathname.new(Dir.mktmpdir("minitestfs")) }

  it "fails when the given path is found" do
    l = lambda { refute_exists(root_dir) }

    error = assert_raises(Minitest::Assertion, &l)
    error.message.must_match(/expected `#{root_dir}` not to exist/im)
  end
end

