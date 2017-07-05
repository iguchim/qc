class InspectionsController < ApplicationController
  before_action :set_inspection, only: [:show, :edit, :update]

  def new
    @inspection = Inspection.new
    @product = Product.find(params[:product_id])
  end

  def create
    @product = Product.find(params[:product_id])
    @inspection = @product.inspections.build(inspection_params)
    if @inspection.save
      flash[:success] = "検査項目が追加されました。"
      redirect_to @product
    else
      flash[:error] = "検査項目が追加出来ませんでした。"
      redirect_to :back # OK?
    end
    
  end

  def edit
    #@product = Product.find(params[:product_id])
    @inspection = Inspection.find(params[:id])
    @product = @inspection.product
  end

  # There are two places come from;
  # 1. product-show
  # 2. production-show

  def update
    @inspection = Inspection.find(params[:id])
    @product = @inspection.product
    if params[:production_id]
      @production = Production.find(params[:production_id])
      update_params
      if @inspection.update(inspection_params)
        flash[:success] = "検査データが変更/追加されました。"
        #redirect_to @product
        redirect_to product_production_path(@product, @production)
      else
        flash[:error] = "検査データが変更/追加出来ませんでした。"
        #render template: "productions/show"
        #redirect_to :back
        render 'edit'
        #@product = Product.find(params[:product_id])
        #@production = Production.find(params[:production_id])
        #render template: "inspect_data/edit"
      end
    else
      if @inspection.update(inspection_params)
        flash[:success] = "検査項目が変更されました。"
        redirect_to @product
      else
        flash[:error] = "検査項目が変更出来ませんでした。"
        render 'edit'
      end
    end

  end

  private

  def inspection_params
    params.require(:inspection).permit(:num, :synopsis, :standard, :min, :max, :tool, :unit, :remark, inspect_data_attributes: [ :id, :num_data, :str_data, :num, :production_id, :inspection_id, :_destroy ])
  end

  def set_inspection
    @inspection = Inspection.find(params[:id])
  end

  def update_params

    if !params[:inspection]
      return
    end

    data = params[:inspection][:inspect_data_attributes]

    if !data 
      return
    end

    index = 0

    # while data[:"#{index}"] && data[:"#{index}"][:id] do
    #   index += 1
    # end
    num = index
    change = false
    while data[:"#{index}"] do
      if data[:"#{index}"][:_destroy] != "1" && (!data[:"#{index}"][:num_data].blank? || !data[:"#{index}"][:str_data].blank?)
        num += 1
        if !data[:"#{index}"][:id]
          data[:"#{index}"][:num] = (num).to_s
          data[:"#{index}"][:production_id] = params[:production_id]
          data[:"#{index}"][:inspection_id] = params[:inspection_id]
        elsif change
          data[:"#{index}"][:num] = (num).to_s
        end
      else
        if data[:"#{index}"][:_destroy] != "1"
          data[:"#{index}"][:_destroy] = "1"
        else
          # num -= 1
          change = true
        end

      end
      index += 1
    end
  end


end