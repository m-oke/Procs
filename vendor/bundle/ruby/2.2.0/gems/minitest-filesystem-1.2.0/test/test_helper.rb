require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'
require 'minitest/spec'

require 'minitest/filesystem'

require 'tmpdir'
require 'fileutils'

def touch(path)
  FileUtils.touch(path)
end

def rm(path)
  FileUtils.rm_rf(path)
end

def symlink(path, link)
  FileUtils.ln_s(path, link)
end
