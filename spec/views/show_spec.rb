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
    expect(@u).not_to eq(nil)
  end


  it "should have one hyperlink" do
    expect(@links.size).to eq(1)
  end

  it "should have a self hyperlink" do
    expect(@links).to be_hyperlinked('self', /log_excerpts/)
  end


  it "should have a from attribute" do
    expect(@u['from']).to be_an Integer
  end

  it "should have a to attribute" do
    expect(@u['to']).to be_an Integer
  end

  it "should have an entries attribute consisting of strings" do
    expect(@u['entries']).to be_an Array
    expect(@u['entries'][0]).to be_a String
    expect(@u['entries'].length).to eq(3)
  end

end
