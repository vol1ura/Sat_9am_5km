RSpec.describe 'activities/show', type: :view do
  before do
    @activity = assign(:activity, create(:activity, description: 'test'))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/test/)
  end
end
