module CommonMethods
  extend ActiveSupport::Concern

  # module ClassMethods

    def numeric?(i)
      i.is_a? Numeric
    end

  # end # ClassMethods

end