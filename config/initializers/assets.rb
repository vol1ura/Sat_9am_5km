# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[application.scss bootstrap.min.js popper.js active_admin.js active_admin.css active_admin.scss]


begin
	if Gem.loaded_specs.key?('arctic_admin')
		Rails.application.config.assets.paths << File.join(Gem.loaded_specs['arctic_admin'].full_gem_path, 'app', 'assets', 'fonts')
	end
rescue => e
	Rails.logger.warn "Could not add arctic_admin fonts to assets paths: "+ e.message if defined?(Rails)
end

# Ensure common font formats are available to the asset pipeline 
Rails.application.config.assets.precompile += %w[*.svg *.eot *.woff *.ttf]

Rails.application.config.assets.precompile += %w[active_admin.js active_admin.css]
