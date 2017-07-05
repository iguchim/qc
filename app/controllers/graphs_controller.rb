class GraphsController < ApplicationController

  def draw
    # {lot1:,{inspect1: [data1, data2,...], inspect2: [data1, data2,...]}}
    @product = Product.find(params[:product_id])

    if (!params[:inspects].nil?)
      inspections_ids = num_to_inspection_id(params[:inspects], params[:product_id])

      @inspect_data = InspectDatum.joins(:production)
                                  .select('inspect_data.inspection_id, productions.inspect_date, productions.lot, inspect_data.num_data')
                                  .where('(inspect_data.num_data IS NOT NULL) ' + 
                                         'AND (inspect_data.inspection_id IN (' + inspections_ids + ')) ' +
                                         'AND (productions.inspect_date BETWEEN ? AND ? )', params[:start], params[:end] )
                                  .order('productions.lot, inspect_data.inspection_id')

      @inspect_names = to_inspection_name(inspections_ids.split(","))

      g_data = graph_data(@inspect_data)

      @graph = make_graph(g_data.to_a, @inspect_names)

    end

  end

  private

  def num_to_inspection_id(nums, product_id)

    ids = []
    nums.each do |num|
      ids << Inspection.find_by(num: num, product_id: product_id).id
    end

    ids.join(',')

  end

  def to_inspection_name(inspection_ids)
    names =[]
    inspection_ids.each do |id|
      names << Inspection.find(id).synopsis
    end
    names
  end

  def graph_data(inspect_data)

    gdata = Hash.new
    idata = Hash.new
    ndata = []
    icount = 0
    lot = inspect_data[0].lot
    inspection_id = inspect_data[0].inspection_id
    dsize = inspect_data.size
    count = 0

    d = inspect_data[count]
    while count < dsize do
      ndata << d.num_data
      count += 1
      if count < dsize then
        d = inspect_data[count]
      end
        
      if lot != d.lot then
        idata[@inspect_names[icount]] = ndata
        ndata = []
        gdata[lot] = idata
        idata = Hash.new
        icount = 0
        lot = d.lot
        inspection_id = d.inspection_id
      end
      if inspection_id != d.inspection_id then
        idata[@inspect_names[icount]] = ndata
        ndata = []
        icount += 1
        inspection_id = d.inspection_id
      end
    end # while
    
    idata[@inspect_names[icount]] = ndata
    gdata[lot] = idata

    gdata
  end

  def make_graph(data, names)
    g_data = []
    inspects = Hash.new

    names.each do |name|
      inspects[name] = Hash.new
    end

    data.each do |i|
      lot = i[0].to_s
      ihash = i[1]
      names.each do |name|
        inspects[name].store(lot, ihash[name].reduce(:+).to_f/ihash[name].size)
      end

    end

    inspects.each do |inspect|
      i = Hash.new
      i[:name] = inspect[0]
      i[:data] = inspect[1]
      g_data << i
    end
    g_data
  end

end