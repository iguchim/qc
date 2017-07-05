class PdfFormatsController < ApplicationController

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.pdf do
        inspector = current_user() # currently just for place-holder
        product = Product.find(params[:product_id])
        customer = Customer.find(product.customer_id)
        production = Production.find(params[:production_id])
        inspections = Inspection.select('inspections.*')
                              .where('product_id = ?', params[:product_id])
                              .order('num')
        inspect_data = InspectDatum.joins(:inspection)
                                  .select('inspect_data.*, inspections.num as i_num')
                                  .where('production_id = ?', params[:production_id])
                                  .order('inspect_data.num, inspections.num')

        pdf = InspectionPdf.new(inspector, customer, product, production, inspections, inspect_data)
        send_data pdf.render,
          filename:    "inspection.pdf",
          type:        "application/pdf",
          disposition: "inline"
      end
    end
  end
end