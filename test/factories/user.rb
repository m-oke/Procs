FactoryGirl.define do
  factory :user do
    name "root"
    nickname "root_nick"
    email "root@test.com"
    password "testtest"
    roles [:root, :admin, :teacher, :student]
  end
end
