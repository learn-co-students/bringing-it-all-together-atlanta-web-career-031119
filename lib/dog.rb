require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  @@all = []

  def initialize(hiya)
    @name = hiya[:name]
    @breed = hiya[:breed]
    @id = hiya[:id]
    @@all << self
  end

  def self.all
    @@all
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
    DB[:conn].execute(sql)
  end

  def save
    if id.nil?
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      self.update
    end
    self
  end

  def update
   sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hiya)
    dog = Dog.new(hiya)
    dog.save
    dog
  end

  def self.new_from_db(hiya)
    hiya1 = {name: hiya[1], breed: hiya[2], id: hiya[0]}
    dog = Dog.new(hiya1)
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_by_id(number)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = #{number} LIMIT 1
    SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(hiya1)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hiya1[:name], hiya1[:breed])
    if !dog.empty?
      dogs_data = dog[0]
      hiya = {name: dogs_data[1], breed: dogs_data[2], id: dogs_data[0]}
      dog = Dog.new(hiya)
    else
      dog = self.create(hiya1)
    end
    dog
  end

end
