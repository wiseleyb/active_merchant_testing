class PaypalExpressGatewayTest < ActiveMerchant::Billing::PaypalExpressGateway

  attr_accessor :purchase_options
  
  def initialize(options = {})
    
  end
  
  def setup_purchase(amount, options = {})
    requires!(options, :return_url, :cancel_return_url)
    self.purchase_options = options

    response = {
      :payment_status => "Completed",
      :tax_amount_currency_id => "USD",
      :correlation_id => get_hex_code,  #???
      :timestamp => DateTime.now.to_s,
      :token => "EC-#{get_hex_code}",
      :pending_reason => "none",
      :transaction_id => get_hex_code,
      :fee_amount_currency_id => "USD",
      :transaction_type => "express-checkout",
      :build => "767689",
      :tax_amount => "0.00",
      :version => "2.0",
      :receipt_id => "",
      :gross_amount_currency_id => "USD",
      :fee_amount => "0.00",
      :exchange_rate => "",
      :gross_amount => amount,
      :parent_transaction_id => "",
      :ack => "Success",
      :payment_date => DateTime.now.to_s,
      :reason_code => "none",
      :payment_type => "instant"}
    
    
    build_response(true, "Success", response,
	    :test => true,
	    :authorization => get_hex_code,
	    :fraud_review => false,
	    :avs_result => { :code => "" },
	    :cvv_result => ""
    )
  end
  
  def redirect_url_for(token)
    "#{self.purchase_options[:return_url]}?token=#{token}&payer_id=#{self.purchase_options[:payer_id]}"
  end
  
  private
  def get_hex_code
    arr = Time.now.to_f.to_s.split(".")
    x = arr[0].to_i + arr[1].to_i
    x.to_s(16).upcase
  end
  
end
