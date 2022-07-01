RSpec.describe 'activities/index', type: :view do
  before do
    assign(:activities, create_list(:activity, 2, description: 'test'))
  end

  xit 'renders a list of activities' do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
    assert_select cell_selector, text: Regexp.new('Index'.to_s), count: 2
  end
end
