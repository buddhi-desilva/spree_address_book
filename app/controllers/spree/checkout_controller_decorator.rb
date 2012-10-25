Spree::CheckoutController.class_eval do
  helper Spree::AddressesHelper

  after_filter :normalize_addresses, :only => :update
  before_filter :set_addresses, :only => :update

  protected

  def set_addresses
    return unless params[:order] && params[:state] == "address"

    if params[:order][:ship_address_id].to_i > 0
      params[:order].delete(:ship_address_attributes)

      if ship_address = Spree::Address.find_by_id(params[:order][:ship_address_id])
        if spree_current_user == ship_address.user
          @order.ship_address = ship_address
          params[:order].delete(:ship_address_id)
        end
      end


    else
      params[:order].delete(:ship_address_id)
    end

    if params[:order][:bill_address_id].to_i > 0
      params[:order].delete(:bill_address_attributes)

      if bill_address = Spree::Address.find_by_id(params[:order][:bill_address_id])
        if spree_current_user == bill_address.user
          @order.bill_address = bill_address
          params[:order].delete(:bill_address_id)
        end
      end

    else
      params[:order].delete(:bill_address_id)
    end
  end

  def normalize_addresses
    return unless params[:state] == "address" && @order.bill_address_id && @order.ship_address_id
    return if (@order.bill_address.id.nil? || @order.ship_address.nil?)

    @order.bill_address.reload
    @order.ship_address.reload

    # ensure that there is no validation errors and addresses was saved
    return unless @order.bill_address && @order.ship_address

    if @order.bill_address_id != @order.ship_address_id && @order.bill_address.same_as?(@order.ship_address)
      @order.bill_address.destroy
      @order.update_attribute(:bill_address_id, @order.ship_address.id)
    else
      @order.bill_address.update_attribute(:user_id, current_user.try(:id))
    end
    @order.ship_address.update_attribute(:user_id, current_user.try(:id))
  end
end
