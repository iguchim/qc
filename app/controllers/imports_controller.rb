class ImportsController < ApplicationController
  require 'roo'
  require 'date'

  include CommonMethods

  def select
  end

  def upload
    # display error log and modify
    @logs = [] # share errors among methods
    new_products = []
    pre_product_log_size = ProductLog.count
    pre_product_size = Product.count
    pre_inspect_size = InspectLog.count
    if !(params[:doc])
      @logs << "ファイルが選択されていません。"
    else
      params[:doc][:files].each do |file|
        import(file)
      end
      product_size = Product.count - pre_product_size
      product_log_size = ProductLog.count - pre_product_log_size
      inspect_size = InspectLog.count 

      new_products = Product.joins(:customer)
                        .select('products.*, customers.name as c_name')
                        .order('products.created_at DESC')
                        .limit(product_size)
                        .to_a

      # product_logs = ProductLog.joins(:product)
      #                   .select('product_logs.*, products.name as p_name')
      #                   .order('product_logs.created_at DESC')
      #                   .limit(product_log_size)
      #                   .to_a

      new_inspections = Inspection.joins(:product)
                        .select('inspections.*, products.name as p_name')
                        .order('inspections.created_at DESC')
                        .limit(inspect_size)
                        .to_a

    end

    render 'results', locals: { logs: @logs, new_products: new_products}
    # render 'results', locals: { errors: @logs, new_products: new_products, product_logs: product_logs}
    #redirect_to action: 'results'
  end

  def results
  end

  private #===============================================================

  #=== Main Methods ===================================================

  def import(file)
    spreadsheet = open_spreadsheet(file)
    if spreadsheet
      read_into_DB(spreadsheet, file.original_filename)
    end

  end

  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.xls' then Roo::Spreadsheet.open(file.path)
    else #raise "Unkown file type: #{file.original_filename}"
      @logs << "#{file.original_filename}は形式が違います。"
      return false
    end # case
  end

  def read_into_DB(spreadsheet, file_name)
    product = read_product_into_DB(spreadsheet, file_name)
    if product
      if !read_inspect_into_DB(spreadsheet, file_name, product.id) # true means some change in excel file
        if production = read_production_into_DB(spreadsheet, file_name, product.id)
          read_inspection_into_DB(spreadsheet, file_name, product.id, production.id)
        end
      end
    end
  end

  #=== Production Methods ===================================================
  def read_production_into_DB(spreadsheet, file_name, product_id)

    change = false

    lot = spreadsheet.cell(13, 'C')
    if numeric?(lot)
      lot = lot.to_i.to_s
    end
    
    if lot.blank?
      @logs << "#{file_name}：ロット番号がありません。"
      return nil # not go to next process
    end

    pcs = spreadsheet.cell(14, 'C')
    if pcs.blank?
      @logs << "#{file_name}：数量がありません。"
      return nil # not go to next process
    end

    inspect_date = excel_to_date(spreadsheet.cell(15, 'C'))
    if inspect_date.blank? # || !(Date.parse(inspect_date))
       @logs << "#{file_name}：検査日がありません。"
       return nil # not go to next process
    end

    if production = Production.find_by(lot: lot, product_id: product_id)
      if pcs != production.pcs
        @logs <<  "#{file_name}：数量が変更になっています。[#{production.pcs} -> #{pcs}]"
        change = nil
      end
      if inspect_date != production.inspect_date
        @logs <<  "#{file_name}：検査日が変更になっています。[#{production.inspect_date} -> #{inspect_date}]"
        change = nil
      end
    elsif !(production = Production.create(lot: lot, pcs: pcs, inspect_date: inspect_date, product_id: product_id))
      @logs << "#{file_name}：ロット(#{lot})が保存出来ませんでした。"
      return nil # not go to next process
    else
      return production # go to next process
    end

    if change
      return nil
    else
      return production
    end

  end

  # Read inspection data into DB
  def read_inspection_into_DB(spreadsheet, file_name, product_id, production_id)
    y ='A'
    offset = 10
    page_offset = 10
    last_col = spreadsheet.last_column
    page = 1
    no_more = false
    changed = false
    while !no_more do
      if read_one_page_inspection_into_DB(y, spreadsheet, file_name, product_id, production_id)
        changed = true
      end

      for i in 1..offset do
        y.next!
      end

      if col_num(y) > last_col - page_offset * (page - 1)
        no_more = true
        break
      end
      page += 1

    end # while

  end

  def read_one_page_inspection_into_DB(y, spreadsheet, file_name, product_id, production_id)
    y_synopsis = y.dup
    y_synopsis.next!
    x_synopsis = 20
    no_more_items = false

    got_no = false
    item_max = 0
    i = 1
    item_x = 26
    item_y ='A'
    while !got_no do
      # num = spreadsheet.cell(item_x, item_y).scan(/\d+/).first
      num = to_han_num(spreadsheet.cell(item_x, item_y))
      if num == i
        item_max = i
        i += 1
        item_x += 1
      else
        got_no = true
      end
    end

    no_more_items = false
    for i in 0..8 do
      if del_spaces(spreadsheet.cell(x_synopsis, y_synopsis)) == ""
        no_more_items = true
        break
      end
      inspect_num = spreadsheet.cell(x_synopsis-1, y_synopsis).to_i
      x = 26
      for item_num in 1..item_max do
        item = spreadsheet.cell(x, y_synopsis)
        add_or_change_inspection(item, item_num, inspect_num, file_name, product_id, production_id)
        x += 1
      end
      y_synopsis.next!
    end

    if no_more_items
      return
    end

    # get lower data
    while (del_spaces(spreadsheet.cell(x, y)) != "n=1") and (x < 50) do
      x += 1
    end
    if x >= 50
      return
    end

    y_synopsis = y.dup
    y_synopsis.next!
    x_synopsis = x-6 # offset to synopsis
    for inspect_num in 1..9 do
      x_data = x
      if del_spaces(spreadsheet.cell(x_synopsis, y_synopsis)) == ""
        no_more_items = true
        break
      end
      inspect_num = spreadsheet.cell(x_synopsis-1, y_synopsis).to_i
      for item_num in 1..item_max do
        item = spreadsheet.cell(x_data, y_synopsis)
        add_or_change_inspection(item, item_num, inspect_num, file_name, product_id, production_id)
        x_data += 1
      end
      y_synopsis.next!
    end

  end

  def add_or_change_inspection(item, item_num, inspect_num, file_name, product_id, production_id)
    # find existed inspection data, if changed, error
    inspection = Inspection.find_by(product_id: product_id, num: inspect_num)
    if !inspection
      @logs << "#{file_name}：検査項目番号(#{inspect_num})の登録がありません。"
      return
    end
    inspect_data = InspectDatum.find_by(production_id: production_id, inspection_id: inspection.id, num: item_num)
    if inspect_data # data exist
      if numeric?(item)
        if inspect_data.num_data != item.to_f
          @logs << "#{file_name}：検査項目番号(#{inspect_num})の数字データを変更しました。[#{inspect_data.num_data} -> #{item.to_f}]"
          inspect_data.num_data = item.to_f
          inspect_data.save
        end
      else # string data
        if inspect_data.str_data != item
          @logs << "#{file_name}：検査項目番号(#{inspect_num})の文字データを変更しました。[#{inspect_data.str_data} -> #{item}]"
          inspect_data.str_data = item
          inspect_data.save
        end
      end
    else # new data
      new_inspection = InspectDatum.new
      new_inspection.num = item_num
      new_inspection.inspection_id = inspection.id
      new_inspection.production_id = production_id
      if numeric?(item)
        new_inspection.num_data = item.to_f
      else
        new_inspection.str_data = item
      end
      new_inspection.save
    end
  end
  #=== Inspection Methods ===================================================

  def read_inspect_into_DB(spreadsheet, file_name, product_id)
    y ='A'
    offset = 10
    page_offset = 10
    last_col = spreadsheet.last_column
    page = 1
    no_more = false
    changed = false
    while !no_more do
      if read_one_page_inspect_into_DB(y, spreadsheet, file_name, product_id)
        changed = true
      end

      for i in 1..offset do
        y.next!
      end

      if col_num(y) > last_col - page_offset * (page - 1)
        no_more = true
        break
      end
      page += 1

    end # while

    return changed

  end

  def read_one_page_inspect_into_DB(y, spreadsheet, file_name, product_id)
    
    start_y = y.dup
    x = 19 # offset to 1 2 3 ...9
    # y = 'A'
    items =[]
    no_more_items = false

    changed = false

    for i in 0..8 do # !!! may be less than 8
      item = get_one_inspect(x, start_y.next!, spreadsheet)
      if del_spaces(item[:synopsis]) != ""
        items << item
      else
        no_more_items = true
        break
      end
    end

    # get lower data
    if !no_more_items
      # skip data section
      x = 20 # lower of 1 2 3...9
      start_y = y.dup
      while (del_spaces(spreadsheet.cell(x, start_y)) != "箇所") and (x < 50) do
        x += 1
      end
      if x >= 50 # not found second row
        no_more_items = true
      end

      if !no_more_items
        if del_spaces(spreadsheet.cell(x, start_y)) == "箇所"
          for i in 0..8 do # !!! may be less than 8
            item = get_one_inspect(x, start_y.next!, spreadsheet)
            if del_spaces(item[:synopsis]) != ""
              items << item
            else
              no_more_items = true
              break
            end
          end
        end
      end # if !no_more_items
    end # if !no_more_items

    items.each do |item|
      if change_or_add_inspect(item, product_id, file_name)
        changed = true
      end
    end

    return changed

  end

  def change_or_add_inspect(item, product_id, file_name)

    found = false
    inspects = Inspection.where(product_id: product_id)
    changed = false

    if inspects
      inspects.each do |inspect|
        if !found and (inspect.num == del_spaces(item[:num]).to_i)
          found = true
          changed = change_inspect(item, inspect.id, file_name)
          break
        end 
      end # do
    end 

    if !found
      add_inspect(item, product_id, file_name)
    end

    return changed

  end

  def add_inspect(item, product_id, file_name)
    inspection = Inspection.new
    inspection.synopsis = item[:synopsis]
    inspection.num = item[:num]
    inspection.standard =  item[:standard]
    inspection.min =  item[:min]
    inspection.max =  item[:max]
    inspection.tool =  item[:tool]
    inspection.unit =  item[:unit]
    inspection.product_id = product_id
    if inspection.save
      @logs << "検査項目：#{item[:synopsis]} を追加しました。"
    else
      @logs << "検査項目追加に失敗しました。"
    end
  end

  def change_inspect(item, inspect_id, file_name)
    inspection = Inspection.find(inspect_id)
    change = false

    # inspect_log = InspectLog.new

    if inspection.num != item[:num]
      change = true
      @logs << "[#{inspection.synopsis}] 箇所：#{inspection.num}->#{item[:num]}"
      # inspect_log.num = inspection.num
      # inspection.num = item[:num]
    end

    if inspection.synopsis != item[:synopsis]
      change = true
      @logs << "[#{inspection.synopsis}] 摘要：#{inspection.synopsis}->#{item[:synopsis]}"
      # inspect_log.synopsis = inspection.synopsis
      # inspection.synopsis = item[:synopsis]
    end
    
    if inspection.standard != item[:standard]
      change = true
      @logs << "[#{inspection.synopsis}] 規格：#{inspection.standard}->#{item[:standard]}"
      # inspect_log.standard = inspection.standard
      # inspection.standard = item[:standard]
    end

    if inspection.min != item[:min]
      change = true
      @logs << "[#{inspection.synopsis}] 下限：#{inspection.min}->#{item[:min]}"
      # inspect_log.min = inspection.min
      # inspection.min = item[:min]
    end

    if inspection.max != item[:max]
      change = true
      @logs << "[#{inspection.synopsis}] 上限：#{inspection.max}->#{item[:max]}"
      # inspect_log.max = inspection.max
      # inspection.max = item[:max]
    end    

    if inspection.tool != item[:tool]
      change = true
      @logs << "[#{inspection.synopsis}] 測定器：#{inspection.tool}->#{item[:tool]}"
      # inspect_log.tool = inspection.tool
      # inspection.tool = item[:tool]
    end     
    
    if inspection.unit != item[:unit]
      change = true
      @logs << "[#{inspection.synopsis}] 単位：#{inspection.unit}->#{item[:unit]}"
      # inspect_log.unit = inspection.unit
      # inspection.unit = item[:unit]
    end 

    # if change
    #   inspect_log.change_date = Time.now
    #   if !inspect_log.save
    #     @logs << "#{file_name}:検査項目変更ログ保存に失敗しました。"
    #   end
    #   if !inspection.save
    #     @logs << "#{file_name}:検査項目変更保存に失敗しました。"
    #   end
    # end
    if !change
      # @logs << "[#{inspection.synopsis}] 検査項目変更無し"
    end

    return change
    
  end

  def get_one_inspect(x, y, spreadsheet)

    item = {}
    item[:num] = spreadsheet.cell(x, y)
    item[:synopsis] = spreadsheet.cell(x+1, y)
    item[:standard] = spreadsheet.cell(x+2, y)
    item[:max] = spreadsheet.cell(x+3, y)
    item[:min] = spreadsheet.cell(x+4, y)
    item[:tool] = spreadsheet.cell(x+5, y)
    item[:unit] = spreadsheet.cell(x+6, y)

    return(item)

  end

  #=== Product Methods ================================================
  # 
  # Customer table should be created firt ---> if not find customer
  # ----> shoud be error reported

  # Search by 
  def read_product_into_DB(spreadsheet, file_name)
    # read customer
    # customer_name = spreadsheet.cell(4,'A')
    # customer = Customer.find_by(name: customer_name)
    # if !customer
    #   @logs << "#{file_name}:顧客名(#{customer_name})でエラーが発生しました。"
    #   return false
    # end

    # read m code
    code = spreadsheet.cell(51,'J')
    if !(code.blank?)
      buff = code.split('-')
      customer_num = buff[0].to_i
      customer = Customer.find_by(code: customer_num)
      if !customer
        @logs << "#{file_name}:商品コード(#{code})から顧客を検索出来ませんでした。"
        return false
      end
    else
      @logs << "#{file_name}:商品コードが無いか不正です。"
      return false
    end

    # read num
    num = spreadsheet.cell(7,'C')
    # read name
    name = spreadsheet.cell(8,'C')
    # read material
    material = spreadsheet.cell(9,'C')
    # read surface
    surface = spreadsheet.cell(10,'C')
    # read heat
    heat = spreadsheet.cell(11,'C')

    product = Product.find_by(code: code)

    @logs << "----- ファイル名：#{file_name} -----"

    if product # change product
      changed = false
      # product_log = ProductLog.new
      product_id = product.id
      @logs << "製品ID：#{product_id}"

      if num != product.num
        changed = true
        @logs << "品番：#{product.num}->#{num}"
        # product_log.num = product.num
        # product.num = num
      end

      if name != product.name
        changed = true
        @logs << "品名：#{product.name}->#{name}"
        # product_log.name = product.name
        # product.name = name
      end

      if material != product.material
        changed = true
        @logs << "材質：#{product.material}->#{material}"
        # product_log.material = product.material
        # product.material = material
      end

      if surface != product.surface
        changed = true
        @logs << "表面処理：#{product.surface}->#{surface}"
        # product_log.surface = product.surface
        # product.surface = surface
      end

      if heat != product.heat
        changed = true
        @logs << "熱処理：#{product.heat}->#{heat}"
        # product_log.heat = product.heat
        # product.heat = heat
      end

      # if changed
      #   product_log.product_id = product.id
      #   if !product_log.save
      #     @logs << "#{file_name}:変更ログ保存に失敗しました。"
      #   end
      #   if !product.save
      #     @logs << "#{file_name}:変更保存に失敗しました。"
      #   end
      # end
      if !changed
        @logs << "製品データ変更無し"
      end

    else # new product
      if !product = Product.create(code: code, num: num, name: name, material: material, surface: surface, heat: heat, customer_id: customer.id)
        @logs << "#{file_name}:新規製品保存に失敗しました。"
      end
    end

    return product
  end

  #=== Utility Methods =============================

  def del_spaces(str)
    str.to_s.gsub(/(\s|　)+/, '')
  end

  def trip_spaces(str)
    str
  end

  def col_num(str)
    col = str.upcase
    len = col.length
    offset = 'A'.ord - 1
    wt = 26
    sum = 0
    i = 0
    for i in 0..len-1 do
      num = (wt ** (len-1-i)) * (col[i].ord - offset)
      sum += num 
    end
    return sum
  end

  # move to lib/common
  # def numeric?(i)
  #   i.is_a? Numeric
  # end

  def excel_to_date(edate)
    #DateTime.new(1899, 12, 30) + edate.days
    edate
  end

  def to_han_num(str)
    if numeric?(str)
      str.to_i
    else
      str.tr("０-９", "0-9").scan(/\d+/).first.to_i
    end
  end

end