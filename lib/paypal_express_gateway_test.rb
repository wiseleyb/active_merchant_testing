# TODO  THIS IS QUITE A HACK - when I have time I need to really clean this up with some mocks or something

class PaypalExpressGatewayTest < ActiveMerchant::Billing::PaypalExpressGateway

  attr_accessor :purchase_options
  
  def initialize(options = {})
    
  end
  
  def setup_purchase(amount, options = {})
    requires!(options, :return_url, :cancel_return_url)
    self.purchase_options = options

    response = response_data(amount)    
    
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
  
  def details_for(token)
    response = parse("GetExpressCheckoutDetails", successful_get_express_details_response(:token => token))
   
    res = build_response(successful?(response), message_from(response), response,
	    :test => test?,
	    :authorization => authorization_from(response),
	    :fraud_review => fraud_review?(response),
	    :avs_result => { :code => response[:avs_code] },
	    :cvv_result => response[:cvv2_code]
    )
    res.params[:payer] = User.last.email
    return res
  end
  
  def purchase(amount, options = {})
    # request = build_setup_express_sale_or_authorization_request('Sale', money, options)
    # commit(request)
    res = build_response(true, "Success", {},
	    :test => true,
	    :authorization => get_hex_code,
	    :fraud_review => false,
	    :avs_result => { :code => "" },
	    :cvv_result => ""
    )
    res.params[:transaction_id] = get_hex_code
    return res
  end
  
  def test?
    true
  end
  
  def successful?(response)
    true
  end
  
  private
  def get_hex_code
    arr = Time.now.to_f.to_s.split(".")
    x = arr[0].to_i + arr[1].to_i
    x.to_s(16).upcase
  end

  def response_data(amount, options = {})
    {
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
      :payment_type => "instant"
    }
  end
  
  def successful_get_express_details_response(options = {})
    options[:token] ||= "EC-2OPN7UJGFWK9OYFV"
    options[:payer_id] ||= "12345678901234567"
    <<-RESPONSE
<XMLPayResponse xmlns='http://www.verisign.com/XMLPay'>
  <ResponseData>
    <Vendor>TEST</Vendor>
    <Partner>verisign</Partner>
    <TransactionResults>
      <TransactionResult>
        <Result>0</Result>
        <Message>Approved</Message>
        <PayPalResult>
          <EMail>Buyer1@paypal.com</EMail>
          <PayerID>#{options[:payer_id]}</PayerID>
          <Token>#{options[:token]}</Token>
          <FeeAmount>0</FeeAmount>
          <PayerStatus>verified</PayerStatus>
          <Name>Joe</Name>
          <ShipTo>
            <Address>
              <Street>111 Main St.</Street>
              <City>San Jose</City>
              <State>CA</State>
              <Zip>95100</Zip>
              <Country>US</Country>
            </Address>
          </ShipTo>
          <CorrelationID>9c3706997455e</CorrelationID>
        </PayPalResult>
        <ExtData Name='LASTNAME' Value='Smith'/>
      </TransactionResult>
    </TransactionResults>
  </ResponseData>
  </XMLPayResponse>
    RESPONSE
  end
  
end
