module CommonModule
  extend ActiveSupport::Concern

  # module ClassMethods

  #   def import(file)

  #     spreadsheet = open_spreadsheet(file)
  #     header = spreadsheet.row(1)

  #   end

  #   def open_spreadsheet(file)

  #     case File.extname(file.original_filename)
  #     when '.xls' then Roo::Spreadsheet.open(file.path)
  #     else raise "Unkown file type: #{file.original_filename}"
  #     end # case

  #   end

  # end # ClassMethods

end