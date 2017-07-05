class User < ActiveRecord::Base
  has_secure_password

  validates :name, presence: true, uniqueness: true
  validates :password, presence: true, on: :create, length: { minimum: 3 }
  
end
