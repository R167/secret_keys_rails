require "rails/railtie"

module SecretKeysRails
  class Railtie < ::Rails::Railtie
    # Load the secret keys as early as possible, so it can be used in other
    # parts of the Rails configuration, like database.yml files.
    config.before_configuration do
      # Load the optional initializer manually (since this before_configuration
      # phase is before when initializers are usually loaded), so that any
      # customizations can be read in.
      initializer = ::Rails.root.join("config", "initializers", "secret_keys_rails.rb")
      require initializer if File.exist?(initializer)

      SecretKeysRails.load
    end

    # Try to ensure our own "before_configuration" hook gets loaded before any
    # others that have already been loaded, so that these secrets can be used
    # as part of other gem's own before_configuration hooks (eg, in the
    # "config" gem's settings.yml files).
    load_hooks = ActiveSupport.instance_variable_get(:@load_hooks)
    if load_hooks && load_hooks[:before_configuration]
      load_hooks[:before_configuration] = load_hooks[:before_configuration].rotate(-1)
    end

    # Load our custom rake tasks.
    rake_tasks do
      load "secret_keys_rails/railtie/secret_keys.rake"
    end

    # Load our custom generators.
    generators do
      require "secret_keys_rails/railtie/generators/install_generator"
    end
  end
end