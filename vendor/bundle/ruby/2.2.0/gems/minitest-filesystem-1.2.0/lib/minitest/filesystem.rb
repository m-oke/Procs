require "minitest/filesystem/version"
require "minitest/filesystem/matcher"

module Minitest::Assertions
  def assert_contains_filesystem(dir, msg = nil, &block)
    matcher = Minitest::Filesystem::Matcher.new(dir, &block)
    assert matcher.match_found?, msg || matcher.message
  end

  def assert_exists(path, msg = nil, &block)
    assert File.exists?(path), msg || "expected `#{path}` to exist, but it doesn't"
  end

  def refute_exists(path, msg = nil, &block)
    refute File.exists?(path), msg || "expected `#{path}` not to exist, but it does"
  end

  def filesystem(&block)
    block
  end
end

module Minitest::Expectations
  infect_an_assertion :assert_contains_filesystem, :must_exist_within
  infect_an_assertion :assert_exists, :must_exist, :unary
  infect_an_assertion :refute_exists, :wont_exist, :unary
end
