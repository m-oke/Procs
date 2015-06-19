require 'test_helper'

describe "wont_exist" do
  let(:a_path) { Pathname.new(Dir.mktmpdir('minitestfs')) }

  it "fails when the expected path exists" do
    l = lambda { a_path.wont_exist }
    assert_raises(Minitest::Assertion, &l)
  end
end

