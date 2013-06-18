require 'spec_helper'


describe "log_excerpts/show" do
  
  before :all do
    assign(:from, 0)
    assign(:to, 1000000)
    assign(:entries, ["ajshdfjhadjad", "akjhsdfjkhasdjkhgfa", "lskjdfhkljahsldkjhf"])
  end

  before :each do
    render
    @json = JSON.parse(rendered)
    @u = @json['log_excerpt']
    @links = @u['_links'] rescue {}
  end
  

  it "has a named root" do
    @u.should_not == nil
  end


  it "should have one hyperlink" do
    @links.size.should == 1
  end

  it "should have a self hyperlink" do
    @links.should be_hyperlinked('self', /log_excerpts/)
  end


  it "should have a from attribute" do
    @u['from'].should be_an Integer
  end

  it "should have a to attribute" do
    @u['to'].should be_an Integer
  end

  it "should have an entries attribute consisting of strings" do
    @u['entries'].should be_an Array
    @u['entries'][0].should be_a String
    @u['entries'].length.should == 3
  end

end
