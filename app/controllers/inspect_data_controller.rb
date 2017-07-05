class InspectDataController < ApplicationController
  include CommonMethods

  def show
  end

  def edit
    @product = Product.find(params[:product_id])
    @production = Production.find(params[:production_id])
    @inspection = Inspection.find(params[:inspection_id])
    @inspect_data = InspectDatum.joins(:production)
                                  .select('inspect_data.*')
                                  .where('inspection_id = ? AND production_id = ?', @inspection.id, @production.id)
                                  .order('inspect_data.num')

    # @inspection = @inspect_data.nspection

    @inspection.inspect_data = @inspect_data

  end
  
end