class AuthorizeNetCimGatewayTest < ActiveMerchant::Billing::AuthorizeNetCimGateway

  def initialize(options = {})
    @options = {:login => "X", :password => "Y"}
    @test_amount = 100
    @test_customer_profile_id = '3187'
    @test_customer_payment_profile_id = '7813'
    @test_customer_address_id = '4321'
    @test_payment = {
      :credit_card => test_credit_card
    }
    @test_profile = {
      :merchant_customer_id => 'Up to 20 chars', # Optional
      :description => 'Up to 255 Characters', # Optional
      :email => 'Up to 255 Characters', # Optional
      :payment_profiles => { # Optional
        :customer_type => 'individual or business', # Optional
        :bill_to => test_address,
        :payment => @test_payment
      },
      :ship_to_list => {
        :first_name => 'John',
        :last_name => 'Doe',
        :company => 'Widgets, Inc',
        :address1 => '1234 Fake Street',
        :city => 'Anytown',
        :state => 'MD',
        :zip => '12345',
        :country => 'USA',
        :phone_number => '(123)123-1234', # Optional - Up to 25 digits (no letters)
        :fax_number => '(123)123-1234' # Optional - Up to 25 digits (no letters)
      }
    }
    @test_options = {
      :ref_id => '1234', # Optional
      :profile => @test_profile
    }

  end

  def commit(action, request)
    url = test? ? test_url : live_url
    #xml = ssl_post(url, request, "Content-Type" => "text/xml")
    xml = eval("successful_#{action}_response_xml")

    response_params = parse(action, xml)

    message = response_params['messages']['message']['text']
    test_mode = test? || message =~ /Test Mode/
    success = response_params['messages']['result_code'] == 'Ok'

    response = ActiveMerchant::Billing::Response.new(success, message, response_params,
      :test => test_mode,
      :authorization => response_params['customer_profile_id'] || (response_params['profile'] ? response_params['profile']['customer_profile_id'] : nil)
    )

    response.params['direct_response'] = parse_direct_response(response) if response.params['direct_response']
    response
  end

  private

  def test_credit_card(number = '4242424242424242', options = {})
    defaults = {
      :number => number,
      :month => 9,
      :year => Time.now.year + 1,
      :first_name => 'Longbob',
      :last_name => 'Longsen',
      :verification_value => '123',
      :type => 'visa'
    }.update(options)

    ActiveMerchant::Billing::CreditCard.new(defaults)
  end

  def test_address(options = {})
    {
      :name => 'Jim Smith',
      :address1 => '1234 My Street',
      :address2 => 'Apt 1',
      :company => 'Widgets Inc',
      :city => 'Ottawa',
      :state => 'ON',
      :zip => 'K1C2N6',
      :country => 'CA',
      :phone => '(555)555-5555'
    }.update(options)
  end

  def successful_create_customer_profile_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <createCustomerProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <customerProfileId>#{@test_customer_profile_id}</customerProfileId>
      </createCustomerProfileResponse>
    XML
  end

  def successful_create_customer_payment_profile_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <createCustomerPaymentProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <customerPaymentProfileId>#{@test_customer_payment_profile_id}</customerPaymentProfileId>
        <validationDirectResponse>This output is only present if the ValidationMode input parameter is passed with a value of testMode or liveMode</validationDirectResponse>
      </createCustomerPaymentProfileResponse>
    XML
  end

  def successful_create_customer_shipping_address_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <createCustomerShippingAddressResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <customerAddressId>customerAddressId</customerAddressId>
      </createCustomerShippingAddressResponse>
    XML
  end

  def successful_delete_customer_profile_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <deleteCustomerProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <customerProfileId>#{@test_customer_profile_id}</customerProfileId>
      </deleteCustomerProfileResponse>
    XML
  end

  def successful_delete_customer_payment_profile_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <deleteCustomerPaymentProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
      </deleteCustomerPaymentProfileResponse>
    XML
  end

  def successful_delete_customer_shipping_address_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <deleteCustomerShippingAddressResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
      </deleteCustomerShippingAddressResponse>
    XML
  end

  def successful_get_customer_profile_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <getCustomerProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <customerProfileId>#{@test_customer_profile_id}</customerProfileId>
        <profile>
          <paymentProfiles>
            <customerPaymentProfileId>123456</customerPaymentProfileId>
            <payment>
              <creditCard>
                  <cardNumber>#{test_credit_card.number}</cardNumber>
                  <expirationDate>#{CIMGATEWAY.send(:expdate, test_credit_card)}</expirationDate>
              </creditCard>
            </payment>
          </paymentProfiles>
        </profile>
      </getCustomerProfileResponse>
    XML
  end

  def successful_get_customer_profile_response_with_multiple_payment_profiles_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8"?>
      <getCustomerProfileResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <profile>
          <merchantCustomerId>Up to 20 chars</merchantCustomerId>
          <description>Up to 255 Characters</description>
          <email>Up to 255 Characters</email>
          <customerProfileId>#{@test_customer_profile_id}</customerProfileId>
          <paymentProfiles>
            <customerPaymentProfileId>1000</customerPaymentProfileId>
            <payment>
              <creditCard>
                <cardNumber>#{test_credit_card.number}</cardNumber>
                <expirationDate>#{CIMGATEWAY.send(:expdate, test_credit_card)}</expirationDate>
              </creditCard>
            </payment>
          </paymentProfiles>
          <paymentProfiles>
            <customerType>individual</customerType>
            <customerPaymentProfileId>1001</customerPaymentProfileId>
            <payment>
              <creditCard>
                <cardNumber>XXXX1234</cardNumber>
                <expirationDate>XXXX</expirationDate>
              </creditCard>
            </payment>
          </paymentProfiles>
        </profile>
      </getCustomerProfileResponse>
    XML
  end

  def successful_get_customer_payment_profile_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <getCustomerPaymentProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <profile>
          <paymentProfiles>
            <customerPaymentProfileId>#{@test_customer_payment_profile_id}</customerPaymentProfileId>
            <payment>
              <creditCard>
                  <cardNumber>#{test_credit_card.number}</cardNumber>
                  <expirationDate>#{CIMGATEWAY.send(:expdate, test_credit_card)}</expirationDate>
              </creditCard>
            </payment>
          </paymentProfiles>
        </profile>
      </getCustomerPaymentProfileResponse>
    XML
  end

  def successful_get_customer_shipping_address_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <getCustomerShippingAddressResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <address>
          <customerAddressId>#{@test_customer_address_id}</customerAddressId>
        </address>
      </getCustomerShippingAddressResponse>
    XML
  end

  def successful_update_customer_profile_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <updateCustomerProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <customerProfileId>#{@test_customer_profile_id}</customerProfileId>
      </updateCustomerProfileResponse>
    XML
  end

  def successful_update_customer_payment_profile_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <updateCustomerPaymentProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
      </updateCustomerPaymentProfileResponse>
    XML
  end

  def successful_update_customer_shipping_address_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <updateCustomerShippingAddressResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
      </updateCustomerShippingAddressResponse>
    XML
  end

  SUCCESSFUL_DIRECT_RESPONSE = {
    :auth_only => '1,1,1,This transaction has been approved.,Gw4NGI,Y,508223659,,,100.00,CC,auth_only,Up to 20 chars,,,,,,,,,,,Up to 255 Characters,,,,,,,,,,,,,,6E5334C13C78EA078173565FD67318E4,,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,',
    :capture_only => '1,1,1,This transaction has been approved.,,Y,508223660,,,100.00,CC,capture_only,Up to 20 chars,,,,,,,,,,,Up to 255 Characters,,,,,,,,,,,,,,6E5334C13C78EA078173565FD67318E4,,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,',
    :auth_capture => '1,1,1,This transaction has been approved.,d1GENk,Y,508223661,32968c18334f16525227,Store purchase,1.00,CC,auth_capture,,Longbob,Longsen,,,,,,,,,,,,,,,,,,,,,,,269862C030129C1173727CC10B1935ED,P,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,'
  }

  def successful_create_customer_profile_transaction_response_xml #()
    transaction_type = :auth_capture
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <createCustomerProfileTransactionResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <directResponse>#{SUCCESSFUL_DIRECT_RESPONSE[transaction_type]}</directResponse>
      </createCustomerProfileTransactionResponse>
    XML
  end

  def unsuccessful_create_customer_profile_transaction_response_xml(transaction_type = :auth_capture)
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <createCustomerProfileTransactionResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Error</resultCode>
          <message>
            <code>E00027</code>
            <text>The transaction was unsuccessful.</text>
          </message>
        </messages>
        <directResponse>#{UNSUCCESSUL_DIRECT_RESPONSE[:refund]}</directResponse>
      </createCustomerProfileTransactionResponse>
    XML
  end

  def successful_validate_customer_payment_profile_response_xml
    <<-XML
      <?xml version="1.0" encoding="utf-8" ?>
      <validateCustomerPaymentProfileResponse
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsd="http://www.w3.org/2001/XMLSchema"
        xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
        <refId>refid1</refId>
        <messages>
          <resultCode>Ok</resultCode>
          <message>
            <code>I00001</code>
            <text>Successful.</text>
          </message>
        </messages>
        <directResponse>1,1,1,This transaction has been approved.,DEsVh8,Y,508276300,none,Test transaction for ValidateCustomerPaymentProfile.,0.01,CC,auth_only,Up to 20 chars,,,,,,,,,,,Up to 255 Characters,John,Doe,Widgets, Inc,1234 Fake Street,Anytown,MD,12345,USA,0.0000,0.0000,0.0000,TRUE,none,7EB3A44624C0C10FAAE47E276B48BF17,,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,</directResponse>
      </validateCustomerPaymentProfileResponse>
    XML
  end

end
