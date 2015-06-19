require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "root user create" do
    assert(create(:user))
  end
end
