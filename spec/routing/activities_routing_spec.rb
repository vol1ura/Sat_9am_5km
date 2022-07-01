RSpec.describe ActivitiesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/activities').to route_to('activities#index')
    end

    it 'routes to #show' do
      expect(get: '/activities/1').to route_to('activities#show', id: '1')
    end
  end
end
