# frozen_string_literal: true

RSpec.describe '/admin/events' do
  let(:user) { create(:user) }
  let(:permission) { create(:permission) }

  before { sign_in user }

  describe 'GET /admin/users/1/permissions' do
    it 'redirects non-admin users' do
      get admin_user_permissions_url(permission.user)
      expect(response).to have_http_status :found
      expect(response).to redirect_to(root_url)
    end
  end

  describe 'GET /admin/users/1/permissions/1/edit' do
    context 'when user is not authorized' do
      it 'redirects to root url' do
        get edit_admin_user_permission_url(permission.user, permission)
        expect(response).to have_http_status :found
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when user is admin' do
      before { user.admin! }

      it 'renders a form' do
        get edit_admin_user_permission_url(permission.user, permission)
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /admin/events' do
    let(:valid_attributes) do
      {
        permission: {
          action: Permission::ACTIONS.sample,
          subject_class: Permission::CLASSES.sample,
        },
      }
    end

    before { user.admin! }

    it 'creates a new permission' do
      some_user = permission.user
      expect do
        post admin_user_permissions_url(some_user), params: valid_attributes
      end.to change(Permission, :count).by(1)
    end
  end
end
