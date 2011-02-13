require 'spec_helper'

describe Theman::Agency, "sed chomp" do
  before do
    conn  = ActiveRecord::Base.connection.raw_connection
    csv   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'fixtures', 'temp_two.csv'))
    
    agent = ::Theman::Agency.new conn, csv do |agent|
      agent.seds "-n -e :a -e '1,15!{P;N;D;};N;ba'"
    end

    @model = Theman::Object.new(agent.table_name, ActiveRecord::Base)
  end
  
  it "should have all the records from the csv" do
    @model.count.should == 5
  end
end

describe Theman::Agency, "data types" do
  before do
    conn  = ActiveRecord::Base.connection.raw_connection
    csv   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'fixtures', 'temp_one.csv'))
    @agent = ::Theman::Agency.new conn, csv do |agent|
      agent.nulls /"N"/, /"UNKNOWN"/, /""/
      agent.table do |t|
        t.date :col_date
        t.boolean :col_four
        t.float :col_five
      end
    end
    @model = Theman::Object.new(@agent.table_name, ActiveRecord::Base)
  end

  it "should create date col" do
    @model.first.col_date.class.should == Date
  end

  it "should create boolean col" do
    @model.where(:col_four => true).count.should == 2
  end

  it "should create float col" do
    @model.where("col_five > 10.0").count.should == 2
  end

  it "should have an array of nulls" do
    @agent.nulls_to_sed.should == ["-e 's/\"N\"//g'", "-e 's/\"UNKNOWN\"//g'", "-e 's/\"\"//g'"]
  end
  
  it "should have nulls not strings" do
    @model.where(:col_two => nil).count.should == 2
    @model.where(:col_three => nil).count.should == 2
  end
end

describe Theman::Agency, "european date styles" do
  before do
    conn  = ActiveRecord::Base.connection.raw_connection
    csv   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'fixtures', 'temp_three.csv'))
    agent = ::Theman::Agency.new conn, csv do |smith|
      smith.datestyle 'European'
      smith.table do |t|
        t.date :col_date
      end
    end
    @model = Theman::Object.new(agent.table_name, ActiveRecord::Base)
  end
  
  it "should have correct date" do
    date = @model.first.col_date
    date.day.should == 25
    date.month.should == 12
  end
end

describe Theman::Agency, "US date styles" do
  before do
    conn  = ActiveRecord::Base.connection.raw_connection
    csv   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'fixtures', 'temp_four.csv'))
    agent = ::Theman::Agency.new conn, csv do |smith|
      smith.datestyle 'US'
      smith.table do |t|
        t.date :col_date
      end
    end
    @model = Theman::Object.new(agent.table_name, ActiveRecord::Base)
  end
  
  it "should have correct date" do
    date = @model.first.col_date
    date.day.should == 25
    date.month.should == 12
  end
end

describe Theman::Agency, "ISO date styles" do
  before do
    conn  = ActiveRecord::Base.connection.raw_connection
    csv   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'fixtures', 'temp_five.csv'))
    agent = ::Theman::Agency.new conn, csv do |smith|
      smith.datestyle 'ISO'
      smith.table do |t|
        t.date :col_date
      end
    end
    @model = Theman::Object.new(agent.table_name, ActiveRecord::Base)
  end
  
  it "should have correct date" do
    date = @model.first.col_date
    date.day.should == 25
    date.month.should == 12
  end
end

describe Theman::Agency, "procedural" do
  before do
    @conn  = ActiveRecord::Base.connection.raw_connection
    @csv   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'fixtures', 'temp_two.csv'))
  end

  it "should be able to be called procedural" do
    smith = ::Theman::Agency.new @conn, @csv
    smith.datestyle "European"
    smith.seds "-n -e :a -e '1,15!{P;N;D;};N;ba'"
    smith.nulls /"XXXX"/
    
    smith.table do |t|
      t.date :date
    end

    smith.create!
    
    model = Theman::Object.new(smith.table_name, ActiveRecord::Base)
    model.first.date.class.should == Date
    model.first.org_code.class.should == NilClass
    model.count.should == 5
  end
end

describe Theman::Agency, "create table" do
  before do
    conn  = ActiveRecord::Base.connection.raw_connection
    csv   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'fixtures', 'temp_one.csv'))
    agent = ::Theman::Agency.new conn, csv do |agent|
      agent.nulls /"N"/, /"UNKNOWN"/, /""/
      agent.table do |t|
        t.string :col_two, :limit => 50
      end
    end
    @model = Theman::Object.new(agent.table_name, ActiveRecord::Base)
  end

  it "should have" do
    @model.first.col_two.should == "some \\text\\"
  end
end

describe Theman::Agency, "add primary key" do
  before do
    conn  = ActiveRecord::Base.connection.raw_connection
    csv   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'fixtures', 'temp_one.csv'))
    agent = ::Theman::Agency.new conn, csv
    agent.create!
    agent.add_primary_key!
    @model = Theman::Object.new(agent.table_name, ActiveRecord::Base)
  end

  it "should have serial primary key" do
    @model.first.agents_pkey.should == 1
  end
end

describe Theman::Agency, "delimiters" do
  before do
    conn  = ActiveRecord::Base.connection.raw_connection
    csv   = File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec', 'fixtures', 'temp_six.txt'))
    agent = ::Theman::Agency.new conn, csv do |agent|
      agent.delimiter "|"
    end
    @model = Theman::Object.new(agent.table_name, ActiveRecord::Base)
  end

  it "should have imported pipe delimited txt file" do
    @model.count.should == 4
  end
end