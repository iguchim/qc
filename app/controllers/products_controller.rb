class ProductsController < ApplicationController

  before_action :set_product, only: [:show, :edit, :update]
  before_action :require_login, only: [:new, :create, :edit, :update]

  def new
    @product = Product.new
    @customer = Customer.find(params[:customer_id])
  end

  def index
    @products = Product.joins(:customer)
                        .select('products.*, customers.name as c_name')
                        .order('products.created_at DESC')
                        .to_a
  end

  def show
    @product = (Product.joins(:customer)
                      .select('products.*, customers.name as c_name')
                      .where('products.id = ?', params[:id])
                      .to_a)[0] # array better way???

    @inspects = Inspection.select('inspections.*')
                          .where('product_id = ?', @product.id)
                          .order('inspections.num')

    @productions = Production.select('productions.*')
                              .where('product_id = ?', @product.id)
  end

  def edit
    
  end

  def update
    if @product.update(product_params)
      flash[:success] = "更新しました。"
      redirect_to @product
    else
      flash[:error] = "更新に失敗しました。"
      render 'edit'
    end
  end

  def create
    @customer = Customer.find(params[:customer_id])
    #@product = @customer.products.build(product_params)
    @product = Product.new(product_params)
    @product.customer_id = @customer.id

    if @product.save
      flash[:success] = "製品を追加しました。"
      redirect_to @customer
    else
      flash[:error] = "製品を追加出来ませんでした。"
      render :new
      #render new_product_path @product
    end
  end

  private

  def product_params
    params.require(:product).permit(:code, :name, :num, :material, :heat, :surface)
  end

  def set_product
    @product = Product.find(params[:id])
  end

end
