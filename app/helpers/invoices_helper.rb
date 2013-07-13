module InvoicesHelper

  # check for buyer
  def get_buyer
    @invoice.buyer.name if @invoice.buyer_id 
  end

  # set default quantity
  def set_quantity
    @invoice.quantity || 1
  end

  # set default sales tax
  def get_sales_tax
    @invoice.sales_tax || 0.0
  end

  # check if user has bank account to determine correct routing
  def get_invoice_path
    @user.has_bank_account? ? new_invoice_path : new_bank_account_path(target: 'shared/invoice_form')
  end
end