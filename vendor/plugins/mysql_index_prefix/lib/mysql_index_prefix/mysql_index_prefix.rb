# Adds a new index to the table.  +column_name+ can be a single Symbol,
# a single Hash, or an array of Symbols / Hashes.
#
# The index will be named after the table and the first column names,
# unless you pass +:name+ as an option.
#
# When creating an index on multiple columns, the first column is used as a name
# for the index. For example, when you specify an index on two columns
# [+:first+, +:last+], the DBMS creates an index for both columns as well as an
# index for the first colum +:first+. Using just the first name for this index
# makes sense, because you will never have to create a singular index with this
# name.
#
# ===== Examples
# ====== Creating a simple index
#  add_index(:suppliers, :name)
# generates
#  CREATE INDEX suppliers_name_index ON suppliers(`name`)
# ====== Creating a unique index
#  add_index(:accounts, [:branch_id, :party_id], :unique => true)
# generates
#  CREATE UNIQUE INDEX accounts_branch_id_index ON accounts(`branch_id`, `party_id`)
# ====== Creating a named index
#  add_index(:accounts, [:branch_id, :party_id], :unique => true, :name => 'by_branch_party')
# generates
#  CREATE UNIQUE INDEX by_branch_party ON accounts(`branch_id`, `party_id`)
# ====== Creating an index with a prefix
#  add_index(:comments, {:name => :body, :length => 200})
# generates
#  CREATE  INDEX comments_body_index ON comments(`body`(200))
# ====== Creating a multi-column index with mixed prefixed and non-prefixed fields
#  add_index(:comments, [{:name => :body, :length => 200}, :type], :name => 'body_type_idx'
# generates
#  CREATE  INDEX body_type_idx ON comments(`body`(200), `length`)
module MysqlIndexPrefix
module MysqlIndexPrefix
	def add_index(table_name, column_name, options = {})
		column_names = column_name.kind_of?(Hash) ? [column_name] : Array(column_name)
		index_name   = index_name(table_name, :column => column_names.first.to_s)
		
		if Hash === options # legacy support, since this param was a string
			index_type = options[:unique] ? "UNIQUE" : ""
			index_name = options[:name] || index_name
		else
			index_type = options
		end
		quoted_column_names = column_names.map { |e|
			if Hash === e
				quote_column_name(e[:name]) + (e[:length] ? "(#{e[:length]})" : "")
			else
				quote_column_name(e)
			end
		}.join(", ")
		execute "CREATE #{index_type} INDEX #{quote_column_name(index_name)} ON #{table_name} (#{quoted_column_names})"
	end
	def remove_index(table_name, column_name, options = {})
		column_names = column_name.kind_of?(Hash) ? [column_name] : Array(column_name)
		index_name   = index_name(table_name, :column => column_names.first.to_s)
		
		if Hash === options # legacy support, since this param was a string
			index_name = options[:name] || index_name
		end
		quoted_column_names = column_names.map { |e|
			if Hash === e
				quote_column_name(e[:name]) + (e[:length] ? "(#{e[:length]})" : "")
			else
				quote_column_name(e)
			end
		}.join(", ")
		execute "DROP INDEX #{quote_column_name(index_name)} ON #{table_name}"
	end
end
end
