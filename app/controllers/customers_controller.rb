class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update]

  def index
    # @customers = Customer.all
    @customers = Customer.joins(:recent_customer)
                        .select('customers.*')
                        .where('customers.id = recent_customers.customer_id')
                        .order('recent_customers.access_date DESC')
                        .to_a
  end

  def show
    update_recent_customer(params[:id])
  end


  private

  def customer_params
    params.require(:customer).permit(:name, :code)
  end

  def set_customer
    @customer = Customer.find(params[:id])
  end


end