require 'pry'

load File.expand_path('./griddable.rb')

def cached(fname)
  res = File.exists?(fname) ? Marshal.load(IO.read(fname)) : yield
  File.open(fname, "w") { |f| f.write(res) }
  res
end

griddable = cached "griddable-builgaria.marshal" do
  GriddableMap.new(top_left: '44.370987,22.313232', 
  bottom_right: "40.763901,29.53125",
  rule: "country",
  name: "bulgaria")
end
grid = griddable.to_grid(30)

File.open("grid-bulgaria#{Time.now.to_i}.marshal", "w") { |f| f.write(Marshal.dump(grid)) }
File.open("../grid-bulgaria.marshal", "w") { |f| f.write(Marshal.dump(grid)) }
