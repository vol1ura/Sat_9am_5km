RSpec.describe "activities/index", type: :view do
  before(:each) do
    assign(:activities, [
      Activity.create!(
        index: "Index",
        show: "Show"
      ),
      Activity.create!(
        index: "Index",
        show: "Show"
      )
    ])
  end

  it "renders a list of activities" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new("Index".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Show".to_s), count: 2
  end
end
