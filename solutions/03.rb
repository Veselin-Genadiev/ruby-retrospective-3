module Graphics
  class Renderers
    class Ascii
    end
    class Html
    end
  end

  class Canvas
    @content
    @html_header
    @html_footer

    attr_reader :width
    attr_reader :height

    def initialize width, height
      @width = width
      @height = height
      @content = Array.new(@width) { Array.new(@height, '-') }
      set_html_header
      set_html_footer
    end

    def set_pixel x, y
      @content[y][x] = '@'
    end

    def pixel_at? x, y
      @content[y][x].eql? '@'
    end

    def draw figure
      figure.draw self if figure.respond_to? :draw
    end

    def render_as renderer
      return render_as_ascii if renderer.equal? Graphics::Renderers::Ascii
      return render_as_html if renderer.equal? Graphics::Renderers::Html
    end

    private
    def render_as_ascii
      @content.map { |row| row.join }.join("\n")
    end

    def render_as_html
      @html_header + @content.map { |row| row.join }.join('<br>').
          gsub('@', '<b></b>').gsub('-', '<i></i>') + @html_footer
    end

    def set_html_header
      @html_header = '<!DOCTYPE html><html><head><title>Rendered Canvas</title>
<style type="text/css">.canvas {font-size: 1px;line-height: 1px;}.canvas * {
display: inline-block;width: 10px;height: 10px;border-radius: 5px;}.canvas i {
background-color: #eee; }.canvas b {background-color: #333;}</style></head><body>
<div class="canvas">'
    end

    def set_html_footer
      @html_footer = '</div></body></html>'
    end
  end

  class Point
    attr_reader :x
    attr_reader :y

    def initialize x, y
      @x = x
      @y = y
    end

    def draw canvas
      canvas.set_pixel x, y
    end

    def eql? other
      @x == other.x && @y == other.y
    end

    def ==(other)
      self.eql? other
    end

    def <(other)
      if @x == other.x
        @y < other.y
      else
        @x < other.x
      end
    end

    def hash
      @x << @y
    end
  end

  class Line
    @error
    @step_x
    @step_y
    @delta_x
    @delta_y
    @points

    attr_reader :from
    attr_reader :to

    def initialize from, to
      @from = from < to ? from : to
      @to = from < to ? to : from
      initialize_rasterization_details
    end

    def draw canvas
      rasterize_points(@from.x, @from.y).each { |point| point.draw canvas }
    end

    def eql? other
      @from == other.from && @to == other.to
    end

    def ==(other)
      self.eql? other
    end

    def hash
      @from.hash << @to.hash
    end

    private
    def initialize_rasterization_details
      @delta_x = (@to.x - @from.x).abs
      @delta_y = (@to.y - @from.y).abs
      @step_x = @from.x < @to.x ? 1 : -1
      @step_y = @from.y < @to.y ? 1 : -1
      @error = @delta_x - @delta_y
      @points = [@from]
    end

    def rasterize_points column, row
      while column != @to.x || row != @to.y
        error_doubled = @error << 1
        @error, column = @error - @delta_y, column + @step_x if error_doubled >= -@delta_y
        @error, row = @error + @delta_x, row + @step_y if error_doubled <= @delta_x
        @points << Point.new(column, row)
      end
      @points
    end
  end

  class Rectangle
    attr_reader :left
    attr_reader :right
    attr_reader :top_left
    attr_reader :top_right
    attr_reader :bottom_left
    attr_reader :bottom_right

    def initialize left, right
      @left = left < right ? left : right
      @right = left < right ? right : left
      @top_left = Point.new [@left.x, @right.x].min, [@left.y, @right.y].min
      @top_right = Point.new [@left.x, @right.x].max, [@left.y, @right.y].min
      @bottom_left = Point.new [@left.x, @right.x].min, [@left.y, @right.y].max
      @bottom_right = Point.new [@left.x, @right.x].max, [@left.y, @right.y].max
    end

    def draw canvas
      Line.new(@top_left, @top_right).draw canvas
      Line.new(@top_right, @bottom_right).draw canvas
      Line.new(@bottom_right, @bottom_left).draw canvas
      Line.new(@bottom_left, @top_left).draw canvas
    end

    def eql? other
      @top_left == other.top_left && @top_right == other.top_right &&
          @bottom_left == other.bottom_left && @bottom_right == other.bottom_right
    end

    def ==(other)
      self.eql? other
    end

    def hash
      @top_left.hash << @top_right.hash + @bottom_left.hash << @bottom_right.hash
    end
  end
end