require File.dirname(__FILE__) + "/../spec_helper"

describe "basic notification", :shared => true do

  it "should get serial number" do
    @notification.serial_number.should == 'bea6bc1b-e1e2-44fe-80ff-0180e33a2614'
  end

  it "should get google order number" do
    @notification.google_order_number.should == '841171949013218'
  end

  it "should generate acknowledgment XML" do
    @notification.acknowledgment_xml.should match(/notification-acknowledgment/)
  end

end

describe GoogleCheckout, "New Order Notification" do

  before(:each) do
    @notification = GoogleCheckout::Notification.parse(read_xml_fixture('notifications/new-order-notification'))
  end

  it "should identify type of notification" do
    @notification.should be_kind_of(GoogleCheckout::NewOrderNotification)
  end

  it_should_behave_like "basic notification"

  it "should find fulfillment order state" do
    @notification.fulfillment_order_state.should == 'NEW'
  end

  it "should find financial order state" do
    @notification.financial_order_state.should == 'REVIEWING'
  end

  it "should use financial state shortcut" do
    @notification.state.should == "REVIEWING"
  end

  it "should create Money object from order total" do
    @notification.order_total.should be_kind_of(Money)
    @notification.order_total.cents.should == 19098
    @notification.order_total.currency.should == 'USD'
  end

  it "should throw error when accessing non-existent value" do
    lambda { @notification.there_is_no_field_with_this_name }.should raise_error(NoMethodError)
  end

  it "should find sub-keys of merchant-private-data as if they were at the root" do
    @notification.peepcode_order_number.should == '1234-5678-9012'
  end

  it "should find total tax" do
    @notification.total_tax.should be_kind_of(Money)
    @notification.total_tax.cents.should == 0
  end

  it "should find email marketing allowed" do
    @notification.email_allowed.should be_false
  end

  it "should get email or buyer-shipping-address/email" do 
    @notification.buyer_shipping_address_first_name.should == 'John'
    @notification.buyer_shipping_address_last_name.should == 'Smith'
    @notification.buyer_shipping_address_address1.should == '10 Example Road'
    @notification.buyer_shipping_address_city.should == 'Sampleville'
    @notification.buyer_shipping_address_region.should == 'CA'
    @notification.buyer_shipping_address_postal_code.should == '94141'
    @notification.buyer_shipping_address_country_code.should == 'US'
  end
  
  it  "should get buyer-billing-address/email" do
    @notification.buyer_billing_address_first_name.should == 'Bill'
    @notification.buyer_billing_address_last_name.should == 'Hu'
    @notification.buyer_billing_address_address1.should == '99 Credit Lane'
    @notification.buyer_billing_address_city.should == 'Mountain View'
    @notification.buyer_billing_address_region.should == 'CA'
    @notification.buyer_billing_address_postal_code.should == '94043'
    @notification.buyer_billing_address_country_code.should == 'US'
  end
  
  it "should have correct products" do 
    @notification.items.length.should == 2
    @notification.items[0][:item_name].should == 'Dry Food Pack'
    @notification.items[0][:item_description].should == 'One pack of nutritious dried food for emergencies.'
    @notification.items[0][:quantity].should == "1"
    @notification.items[0][:unit_price].should be_kind_of(Money)
    @notification.items[0][:unit_price].cents.should == 499
    @notification.items[0][:unit_price].currency.should == 'USD'
    @notification.items[0][:item_id].should == 'GGLAA1453'    
    @notification.items[1][:item_name].should == 'Megasound 2GB MP3 Player'
    @notification.items[1][:item_description].should == 'This portable MP3 player stores 500 songs.'
    @notification.items[1][:quantity].should == "1"
    @notification.items[1][:unit_price].should be_kind_of(Money)
    @notification.items[1][:unit_price].cents.should == 17999
    @notification.items[1][:unit_price].currency.should == 'USD'
    @notification.items[1][:item_id].should == 'MGS2GBMP3'
  end

end


describe GoogleCheckout, "Order State Change Notification" do

  before(:each) do
    @notification = GoogleCheckout::Notification.parse(read_xml_fixture('notifications/order-state-change-notification'))
  end

  it_should_behave_like "basic notification"

  it "should identify type of notification" do
    @notification.should be_kind_of(GoogleCheckout::OrderStateChangeNotification)
  end

  it "should find new financial state" do
    @notification.new_financial_order_state.should == 'CHARGING'
  end

  it "should find new fulfillment state" do
    @notification.new_fulfillment_order_state.should == 'NEW'
  end

  it "should use financial state shortcut" do
    @notification.state.should == 'CHARGING'
  end

end

describe GoogleCheckout, "Risk Information Notification" do

  before(:each) do
    @notification = GoogleCheckout::Notification.parse(read_xml_fixture('notifications/risk-information-notification'))
  end

  it "should identify type of notification" do
    @notification.should be_kind_of(GoogleCheckout::RiskInformationNotification)
  end

  it_should_behave_like "basic notification"

end

describe GoogleCheckout, "Charge Amount Notification" do

  before(:each) do
    @notification = GoogleCheckout::Notification.parse(read_xml_fixture('notifications/charge-amount-notification'))
  end

  it_should_behave_like "basic notification"

  it "should identify type of notification" do
    @notification.should be_kind_of(GoogleCheckout::ChargeAmountNotification)
  end

  it "should get latest charge amount" do
    @notification.latest_charge_amount.should be_kind_of(Money)
  end

  it "should get total charge amount" do
    @notification.total_charge_amount.should be_kind_of(Money)
    @notification.total_charge_amount.cents.should == 22606
  end

end

describe GoogleCheckout, "Authorization Amount Notification" do

  before(:each) do
    @notification = GoogleCheckout::Notification.parse(read_xml_fixture('notifications/authorization-amount-notification'))
  end

  it_should_behave_like "basic notification"

  it "should identify type of notification" do
    @notification.should be_kind_of(GoogleCheckout::AuthorizationAmountNotification)
  end

end

describe GoogleCheckout, "Chargeback Amount Notification" do

  before(:each) do
    @notification = GoogleCheckout::Notification.parse(read_xml_fixture('notifications/chargeback-amount-notification'))
  end

  it_should_behave_like "basic notification"

  it "should identify type of notification" do
    @notification.should be_kind_of(GoogleCheckout::ChargebackAmountNotification)
  end

end

describe GoogleCheckout, "Refund Amount Notification" do

  before(:each) do
    @notification = GoogleCheckout::Notification.parse(read_xml_fixture('notifications/refund-amount-notification'))
  end

  it_should_behave_like "basic notification"

  it "should identify type of notification" do
    @notification.should be_kind_of(GoogleCheckout::RefundAmountNotification)
  end

end

