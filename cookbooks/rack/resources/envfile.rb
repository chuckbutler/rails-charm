actions :merge, :delete_variables

attribute :name, kind_of: String, required: true, name_attribute: true
attribute :variables, required: true, kind_of: Hash
attribute :delete_variables, required: true, kind_of: Array
attribute :user, kind_of: String
attribute :group, kind_of: String
attribute :mode, kind_of: String