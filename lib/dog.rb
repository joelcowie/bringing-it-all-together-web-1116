require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      self.insert
      self
    end
  end

  def insert
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * from dogs
    WHERE id = ?
    SQL
    output = DB[:conn].execute(sql, id)[0]
    new_from_db(output)
  end

  def self.new_from_db(row)
    doggy = Dog.new(id:row[0], name:row[1], breed:row[2])
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed)
    if !dog.empty?
      doggy_data = dog[0]
      dog = Dog.new(id: doggy_data[0], name: doggy_data[1], breed: doggy_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * from dogs
    WHERE name = ?
    SQL
    output = DB[:conn].execute(sql, name)[0]
    new_from_db(output)
  end


end
