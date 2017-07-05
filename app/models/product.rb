class Product < ActiveRecord::Base
  has_many :productions
  has_many :product_logs
  has_many :inspections
  belongs_to :customer

  validates :code, presence: true
  validates :num, presence: true
  validates :name, presence: true
  validates :material, presence: true
  validates :surface, presence: true
  validates :heat, presence: true
  validates :customer_id, presence: true
end
