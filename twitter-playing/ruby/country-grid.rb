require "geocoder"

module Geocoder
  def self.search_by_coords(coords)
    search(coords)[0]
  end

  def self.country_to_grid(opts)
    c = Country.new(opts[:name], opts[:left], opts[:top], opts[:right], opts[:bottom])
    c.to_grid(opts[:x], opts[:y])
  end

  class Country
    Coord = Struct.new(:lat, :long) do
      def to_s
        lat.to_s + ',' + long.to_s
      end
    end

    Grid = Struct.new(:lines) do
      def to_s
        lines.to_s
      end

      def to_json
        lines.flatten.map {|l| l.to_s.split(',').map(&:to_f)}.to_json
      end
    end

    class Line
      attr_accessor :startc, :endc
      def initialize(*args)
        @startc, @endc = args[0] > args[1] ? [args[1], args[0]] : args
      end

      def length
        (@endc - @startc).abs
      end

      def divide_by(number)
        dx = length / number
        (@startc..@endc).step(dx).to_a
      end
    end

    attr_accessor :name, :left, :top, :right, :bottom

    def initialize(*args)
      @name = args.delete_at(0)
      set_coords *args
    end

    def within?(coords)
      @results ||= {}
      @results[coords] ||= Geocoder.search_by_coords(coords)
      @results[coords] && @results[coords].country.downcase == name.downcase
    end

    def top_left
      @top_left ||= Coord.new(top.lat, left.long)
    end

    def top_right
      @top_right ||= Coord.new(top.lat, right.long)
    end

    def bottom_left
      @bottom_left ||= Coord.new(bottom.lat, left.long)
    end

    def bottom_right
      @bottom_right ||= Coord.new(bottom.lat, right.long)
    end

    def to_grid(x,y)
      unfiltered_grid = to_unfiltered_grid_by(x,y)
      filter_grid(unfiltered_grid)
    end
    
    private

    def to_unfiltered_grid_by(x,y)
      vertical_divisions = Line.new(top.lat, bottom.lat).divide_by(y)
      horizontal_divisions = Line.new(right.long, left.long).divide_by(x)
      vertical_divisions.map! do |lat|
        horizontal_divisions.map do |long|
          Coord.new(lat, long)
        end
      end
      Grid.new(vertical_divisions)
    end

    def filter_grid(grid)
      grid.lines = grid.lines.dup.map do |line|
        line.select! do |coords|
          sleep(0.5)
          within?(coords.to_s)
        end
        line.uniq if line.any?
      end.reject(&:nil?)
      grid
    end

    def set_coords(*args)
      @left, @top, @right, @bottom = args.map { |arg| Coord.new(*arg.split(",").map(&:to_f)) }
    end
  end

end
