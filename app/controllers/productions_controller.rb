class ProductionsController < ApplicationController

  before_action :set_production, only: [:show, :edit, :update]

  def select
  end

  def upload
    Production.import(params[:doc][:files][0])
  end

  def show
    @product = Product.find(params[:product_id])

    @production = Production.find(params[:id])

    @inspections = Inspection.select('inspections.*')
                              .where('product_id = ?', @product.id)
                              .order('num')

    @inspect_data = InspectDatum.joins(:inspection)
                                  .select('inspect_data.*, inspections.num as i_num')
                                  .where('production_id = ?', @production.id)
                                  .order('inspect_data.num, inspections.num')
  end

  def new
    @production = Production.new
    @production.product_id = params[:product_id]
  end

  def create
    @production = Production.new(production_params)
    @production.product_id  = params[:product_id]

    if @production.save
      flash[:success] = "新しいロットが追加されました。"
      redirect_to @production.product
    else
      flash[:error] = "新しいロットが追加出来ませんでした。"
      render 'new'
    end

  end

  def edit
    @production = Production.find(params[:id])

  end

  def update
    if @production.update(production_params)
      flash[:success] = "更新しました。"
      redirect_to [@production.product, @production]
    else
      flash[:error] = "更新に失敗しました。"
      render 'edit'
    end
  end

  private

  def production_params
    params.require(:production).permit(:lot, :inspect_date, :pcs, :product_id)
  end
                                
  def set_production
    @production = Production.find(params[:id])
  end

end