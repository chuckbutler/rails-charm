actions :reverse_merge, :export

attribute :procfile, kind_of: String
attribute :entries, required: true, kind_of: Hash
attribute :user, kind_of: String
attribute :group, kind_of: String
attribute :mode, kind_of: String
attribute :app, kind_of: String
attribute :cwd, kind_of: String

attr_accessor :current_procfile