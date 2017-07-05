class Inspection < ActiveRecord::Base
  belongs_to :product
  # has_many :productions, through: :inspect_data
  # has_many :productions
  has_many :inspect_data

  validates :num, presence: true
  validates :synopsis, presence: true
  #validates :standard, presence: true
  #validates :min, presence: true
  #validates :max, presence: true
  validates :tool, presence: true
  #validates :unit, presence: true
  validates :product_id, presence: true

  accepts_nested_attributes_for :inspect_data, allow_destroy: true
  
end
