class Dog

  attr_accessor :name, :breed, :id

  def initialize (name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
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

  # the question marks act as placeholders so that when we pass
  # the values in as arguments, they will assign them to the places
  # currently held by the question marks

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?) 
    SQL

    # sends the new instance of the dog to the database
    DB[:conn].execute(sql,self.name, self.breed)

    # assigns the ID value that is given to the instance in the DB
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    # return the instance of dog
    self
  end

  # creating a new instance of 
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  # we define this method to use in our methods which extract data from
  # a DB and create Ruby instances with it. 
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.all
    # first we query the database and pull ALL records
    sql = <<-SQL
      SELECT *
      FROM dogs
    SQL

    # this returns an ARRAY of the values in our DB, We then MAP over
    # that array and create instances of each 
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)

    # here we are again querying the database and pulling out any record
    # that matches our name parameter that is passed into the method
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    # we pass in our name argument so that our SQL knows to return 
    # the data with the corresponding name. 

    # we have to map over the returned data as it comes back in the
    # form of an array 
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row) # we are calling the class method to assign 
      # each return values and assign them to their appropate attributes
    end.first
  end

  def self.find(id)

    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
      # Dog.new(name: row[1], breed: row[2])
    end.first
  end

end
