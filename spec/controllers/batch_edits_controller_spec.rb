require 'spec_helper'

describe BatchEditsController do
  before do
    controller.stub(:has_access?).and_return(true)
    @user = FactoryGirl.create(:user)
    sign_in @user
    User.any_instance.stub(:groups).and_return([])
    controller.stub(:clear_session_user) ## Don't clear out the authenticated session
  end

  describe "edit" do
    before do
      @one = GenericFile.new(creator_attributes:{name: "Fred"}, :language=>'en')
      @one.apply_depositor_metadata('mjg36')
      @two = GenericFile.new(creator_attributes:{name: "Wilma"}, publisher_attributes:{name:'Rand McNally'}, :language=>'en')
      @two.apply_depositor_metadata('mjg36')
      @one.save!
      @two.save!
      controller.batch = [@one.pid, @two.pid]
      controller.should_receive(:can?).with(:edit, @one.pid).and_return(true)
      controller.should_receive(:can?).with(:edit, @two.pid).and_return(true)
    end
    it "should be successful" do
      get :edit
      response.should be_successful
      assigns[:terms].should == [ :contributor, :creator, :description, 
          :publisher, :date_created, :subject, :language, :rights, 
          :identifier, :has_location, :tag, :related_url]
    end
  end
  
  describe "update" do
    before do
      @one = GenericFile.new(creator_attributes:{name: "Fred"}, :language=>'en')
      @one.apply_depositor_metadata('mjg36')
      @two = GenericFile.new(creator_attributes:{name: "Wilma"}, publisher_attributes:{name:'Rand McNally'}, :language=>'en')
      @two.apply_depositor_metadata('mjg36')
      @one.save!
      @two.save!
      controller.batch = [@one.pid, @two.pid]
      controller.should_receive(:can?).with(:edit, @one.pid).and_return(true)
      controller.should_receive(:can?).with(:edit, @two.pid).and_return(true)
    end
    it "should be successful" do
      put :update , update_type:"delete_all"
      response.should be_redirect
      expect {GenericFIle.find(@one.id)}.to raise_error
      expect {GenericFIle.find(@two.id)}.to raise_error
    end
  end

end