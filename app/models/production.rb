class Production < ActiveRecord::Base
  include CommonModule
  belongs_to :product
  has_many :inspect_data

  validates :lot, presence: true
  validates :inspect_date, presence: true
  validates :pcs, presence: true
  validates :product_id, presence: true
  #has_many :inspections, through: :inspect_data
  #has_many :inspections

  # def self.import(file)
  #   spreadsheet = open_spreadsheet(file)
  #   header = spreadsheet.row(1)

  #   # binding.pry
  # end

  # def self.open_spreadsheet(file)
  #   # binding.pry
  #   case File.extname(file.original_filename)
  #   when '.xls' then Roo::Spreadsheet.open(file.path)
  #   else raise "Unkown file type: #{file.original_filename}"
  #   end # case
  # end
end
