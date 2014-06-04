require 'yaml'

module PVersion
  class MigrationsYaml
    def self.build(root_path, to_version=nil)
      migration_file_paths = Dir.glob(File.expand_path(File.join(root_path, 'content_migrations', '*.yml')))
      fail "I can't figure out which content_migrations YAML file to use!" unless migration_file_paths.size == 1

      migrations_yaml_path = migration_file_paths.first
      migrations_yaml = YAML.load_file(migrations_yaml_path)
      new(migrations_yaml, migrations_yaml_path, to_version)
    end

    def initialize(migrations_hash, migrations_yaml_path, to_version=nil)
      @migrations_hash = migrations_hash
      @migrations_yaml_path = migrations_yaml_path
      @to_version = to_version
    end

    def old_version
      migrations_hash.fetch('to_version')
    end

    def new_version
      number = old_version.match(/([0-9]+)$/)[-1]
      next_number = @to_version || (number.to_i + 1)
      old_version.gsub(/[0-9]+$/, next_number.to_s)
    end

    def bump_version_and_save
      save(hash_with_bumped_version.to_yaml)
    end

    private

    attr_reader :migrations_hash, :migrations_yaml_path

    def hash_with_bumped_version
      updated_migrations_hash = migrations_hash.dup
      updated_migrations_hash['to_version'] = new_version

      migrations = updated_migrations_hash.fetch('migrations')
      migrations.each do |migration|
        rules = migration.fetch('rules')
        rules.each do |rule|
          next unless rule.fetch('type') == 'update' && rule.fetch('selector') == 'product_version'
          rule['to'] = new_version
        end
      end

      updated_migrations_hash
    end

    def save(contents)
      File.open(migrations_yaml_path, 'w') do |f|
        f.write(contents)
      end
    end

    def product_name
      migrations_hash.fetch('name')
    end
  end
end
