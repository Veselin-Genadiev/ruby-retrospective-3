module Graphics
  module Renderers
    class Base
      attr_reader :canvas

      def initialize(canvas)
        @canvas = canvas
      end

      def render
        raise NotImplementedError
      end
    end

    class Ascii < Base
      def render
        pixels = 0.upto(canvas.height.pred).map do |y|
          0.upto(canvas.width.pred).map { |x| pixel_at(x, y) }
        end

        join_lines pixels.map { |line| join_pixels_in line }
      end

      private

      def pixel_at(x, y)
        canvas.pixel_at?(x, y) ? full_pixel : blank_pixel
      end

      def full_pixel
        '@'
      end

      def blank_pixel
        '-'
      end

      def join_pixels_in(line)
        line.join('')
      end

      def join_lines(lines)
        lines.join("\n")
      end
    end

    class Html < Ascii
      TEMPLATE = '<!DOCTYPE html>
        <html>
        <head>
          <title>Rendered Canvas</title>
          <style type="text/css">
            .canvas {
              font-size: 1px;
              line-height: 1px;
            }
            .canvas * {
              display: inline-block;
              width: 10px;
              height: 10px;
              border-radius: 5px;
            }
            .canvas i {
              background-color: #eee;
            }
            .canvas b {
              background-color: #333;
            }
          </style>
        </head>
        <body>
          <div class="canvas">
            %s
          </div>
        </body>
        </html>
      '.freeze

      def render
        TEMPLATE % super
      end

      private

      def full_pixel
        '<b></b>'
      end

      def blank_pixel
        '<i></i>'
      end

      def join_lines(lines)
        lines.join('<br>')
      end
    end
  end

  class Canvas
    attr_reader :width, :height

    def initialize(width, height)
      @width  = width
      @height = height
      @content = {}
    end

    def set_pixel(x, y)
      @content[[x, y]] = true
    end

    def draw(shape)
      shape.draw(self)
    end

    def render_as(renderer)
      renderer.new(self).render
    end

    def pixel_at?(x, y)
      @content[[x, y]]
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
      x == other.x && y == other.y
    end

    alias == eql?

    def <(other)
      if x == other.x
        y < other.y
      else
        x < other.x
      end
    end

    def hash
      [x, y].hash
    end
  end

  class Line
    attr_reader :from, :to

    def initialize from, to
      @from = from < to ? from : to
      @to = from < to ? to : from
    end

    def draw(canvas)
      BresenhamRasterization.new(from.x, from.y, to.x, to.y).rasterize_on(canvas)
    end

    def eql? other
      from == other.from && to == other.to
    end

    alias == eql?

    def hash
      [from, to].hash
    end

    class BresenhamRasterization
      def initialize(from_x, from_y, to_x, to_y)
        @from_x, @from_y = from_x, from_y
        @to_x, @to_y     = to_x, to_y
      end

      def rasterize_on(canvas)
        initialize_from_and_to_coordinates
        rotate_coordinates_by_ninety_degrees if steep_slope?
        swap_from_and_to if @drawing_from_x > @drawing_to_x

        draw_line_pixels_on canvas
      end

      def steep_slope?
        (@to_y - @from_y).abs > (@to_x - @from_x).abs
      end

      def initialize_from_and_to_coordinates
        @drawing_from_x, @drawing_from_y = @from_x, @from_y
        @drawing_to_x, @drawing_to_y     = @to_x, @to_y
      end

      def rotate_coordinates_by_ninety_degrees
        @drawing_from_x, @drawing_from_y = @drawing_from_y, @drawing_from_x
        @drawing_to_x, @drawing_to_y     = @drawing_to_y, @drawing_to_x
      end

      def swap_from_and_to
        @drawing_from_x, @drawing_to_x = @drawing_to_x, @drawing_from_x
        @drawing_from_y, @drawing_to_y = @drawing_to_y, @drawing_from_y
      end

      def error_delta
        delta_x = @drawing_to_x - @drawing_from_x
        delta_y = (@drawing_to_y - @drawing_from_y).abs

        delta_y.to_f / delta_x
      end

      def vertical_drawing_direction
        @drawing_from_y < @drawing_to_y ? 1 : -1
      end

      def draw_line_pixels_on(canvas)
        @error = 0.0
        @y     = @drawing_from_y

        @drawing_from_x.upto(@drawing_to_x).each do |x|
          set_pixel_on canvas, x, @y
          calculate_next_y_approximation
        end
      end

      def calculate_next_y_approximation
        @error += error_delta

        if @error >= 0.5
          @error -= 1.0
          @y += vertical_drawing_direction
        end
      end

      def set_pixel_on(canvas, x, y)
        if steep_slope?
          canvas.set_pixel y, x
        else
          canvas.set_pixel x, y
        end
      end
    end
  end

  class Rectangle
    attr_reader :left, :right, :top_left, :top_right
    attr_reader :bottom_left, :bottom_right

    def initialize left, right
      @left, @right = left < right ? [left, right] : [right, left]
      initialize_corner_points
    end

    def draw canvas
      Line.new(top_left, top_right).draw canvas
      Line.new(top_right, bottom_right).draw canvas
      Line.new(bottom_right, bottom_left).draw canvas
      Line.new(bottom_left, top_left).draw canvas
    end

    def eql? other
      top_left == other.top_left && top_right == other.top_right &&
          bottom_left == other.bottom_left && bottom_right == other.bottom_right
    end

    alias == eql?

    def hash
      [top_left, bottom_right].hash
    end

    private
    def initialize_corner_points
      @top_left = Point.new [@left.x, @right.x].min, [@left.y, @right.y].min
      @top_right = Point.new [@left.x, @right.x].max, [@left.y, @right.y].min
      @bottom_left = Point.new [@left.x, @right.x].min, [@left.y, @right.y].max
      @bottom_right = Point.new [@left.x, @right.x].max, [@left.y, @right.y].max
    end
  end
end