class InspectDatum < ActiveRecord::Base
  belongs_to :production
  belongs_to :inspection

  validates :num_data, presence: true, if: -> { str_data.blank? }
  validates :str_data, presence: true, if: -> { num_data.blank? }
  validates :production_id, presence: true
  validates :inspection_id, presence: true
  validates :num, presence: true

end
