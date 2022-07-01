RSpec.describe "activities/show", type: :view do
  before(:each) do
    @activity = assign(:activity, Activity.create!(
      index: "Index",
      show: "Show"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Index/)
    expect(rendered).to match(/Show/)
  end
end
