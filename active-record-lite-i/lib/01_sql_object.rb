require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns_names if !@columns_names.nil?
    @columns_names = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @columns_names = @columns_names[0].map{|el| el.to_sym}

  end

  def self.finalize!
    # @attributes ||= {}
    self.columns.each do |name|
      define_method(name) do
        # instance_variable_get("@#{name}")
        attributes[name.to_sym]
      end
      # @attributes = {}
      define_method("#{name}=") do |value|
        # instance_variable_set("@#{name}", value)
        attributes[name.to_sym] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
    # @table_name = self.to_s
    # @table_name.tableize
    # return self.table_name=(table_name)
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    self.parse_all(rows)
  end

  def self.parse_all(results)
    results.map{|el| self.new(el)}
  end

  def self.find(id)
    answer = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
      WHERE id = #{id}
    SQL
    return nil if answer.empty?
    return self.new(answer[0])
  end

  def initialize(params = {})
    params.each do |attr_name,value|
      attr_name = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" if !self.class.columns.include?(attr_name)
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
