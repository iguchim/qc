class InspectionPdf < Prawn::Document

  DATA_PER_PAGE = 18
  DATA_PER_LINE = DATA_PER_PAGE / 2
  DATA_MAX_CLOUMN = 9


  def initialize(inspector, customer, product, production, inspections, inspect_data)

    super()

    @inspector = inspector
    @customer = customer
    @product = product
    @production = production
    @inspections = inspections
    @inspect_data = inspect_data

    font_size(8)
    #font_size(6)
    font "vendor/fonts/ipaexg.ttf"

    @page_num = (inspections.size / DATA_PER_PAGE).to_i
    if inspections.size % DATA_PER_PAGE then
      @page_num = @page_num + 1
    end

    for page_num in 1..@page_num do
      header(@product, page_num)
      body(@inspections, @inspect_data, page_num)
      if page_num < @page_num
        start_new_page
      end
    end

  end

  def header(product, page_num)
    text "検 　査　 成　 績　 表", :align => :center, :size => 12
    #stroke_color "f0ffc1"
    #line_width(5)
    line [190, cursor-3], [355, cursor-3]

    move_down 40
    text @customer.name + "  御中", :align => :left, :size => 10
    len_x = @customer.name.length
    line [0, cursor-3], [(len_x+2)*10, cursor-3]

    draw_text "No. #{page_num} ", :at => [bounds.width - 86, bounds.height - 46]
    bounding_box([bounds.width - 150, bounds.height - 50], width: 150, height: 50) do
      stroke_bounds
      
      %w(検印 検印 測定者).each_with_index do |pos, i|
        text_box(pos, at: [50 * i, 50], width: 50, height: 10, align: :center, valign: :center)
      end

      vertical_line(0, 50, at: 50) 
      vertical_line(0, 50, at: 100) 
    end
    stroke

    product_data = [  ["品　　　番", "#{product.num}"], 
                      ["品　　　名", "#{product.name}"], 
                      ["材　　　質", "#{product.material}"],
                      ["表 面 処 理", "#{product.surface}"],
                      ["熱   処   理", "#{product.heat}"] ]
    table(product_data) do
      style(column(0), :align => :center)
    end

    move_down 20

  end

  def body(inspections, inspect_data, page_num)

    inspect_size = inspections.size
    offset = (page_num - 1) * DATA_MAX_CLOUMN * 2
    head_width = 36 # has to be data_width is whole number
    data_width = ((bounds.width - head_width) / DATA_MAX_CLOUMN).to_i
    column_widths = [head_width, data_width, data_width, data_width, data_width, data_width, data_width, data_width, data_width, data_width]
    data_is = false
    header_num = ["箇　所"]
    synopsis = ["摘　要"]
    standard = ["規　格"]
    max = ["上　限"]
    min = ["下　限"]
    tool = ["測定器"]
    unit = ["単　位"]
    for index in 0..DATA_MAX_CLOUMN - 1 do
      header_num << offset + index + 1
      if inspect_size > offset + index
        synopsis << inspections[offset + index].synopsis.to_s
        standard << inspections[offset + index].standard.to_s
        max << inspections[offset + index].max.to_s
        min << inspections[offset + index].min.to_s
        tool << inspections[offset + index].tool.to_s
        unit << inspections[offset + index].unit.to_s
        data_is = true
      else
        synopsis << " "
        standard << " "
        max << " "
        min << " "
        tool << " "
        unit << " "
      end
    end

    if data_is
      table([header_num, synopsis, standard, max, min, tool, unit], :width => bounds.width, :column_widths => column_widths, :cell_style => {:align => :center, :height => 16, :overflow => :shrink_to_fit})
    end

    # The second section

    offset = (page_num - 1) * DATA_MAX_CLOUMN * 2 + DATA_MAX_CLOUMN
    data_is = false
    header_num = ["箇　所"]
    synopsis = ["摘　要"]
    standard = ["規　格"]
    max = ["上　限"]
    min = ["下　限"]
    tool = ["測定器"]
    unit = ["単　位"]
    for index in 0..DATA_MAX_CLOUMN - 1 do
      header_num << offset + index + 1
      if inspect_size > offset + index
        
        synopsis << inspections[offset + index].synopsis.to_s
        standard << inspections[offset + index].standard.to_s
        max << inspections[offset + index].max.to_s
        min << inspections[offset + index].min.to_s
        tool << inspections[offset + index].tool.to_s
        unit << inspections[offset + index].unit.to_s
        data_is = true
      else
        synopsis << " "
        standard << " "
        max << " "
        min << " "
        tool << " "
        unit << " "
      end
    end
    if data_is
      table([header_num, synopsis, standard, max, min, tool, unit], :width => bounds.width, :column_widths => column_widths, :cell_style => {:align => :center})
    end
  end

end