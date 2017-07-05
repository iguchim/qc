class Customer < ActiveRecord::Base
  has_many :products
  has_one :recent_customer

end
