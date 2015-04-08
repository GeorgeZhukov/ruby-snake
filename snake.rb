require 'curses'
include Curses

class Snake
    attr_reader :coords
    def initialize(name, field)
        @name = name
        @field = field
        @coords = Array.new(4) {|i| [0, i]}
        
    end

    def move()
        
        direction = 'down'

        case direction
        when 'left'
            head = [0, @coords.last[1] + 1]
            head.last = 0 if head.last > @field.size
        when 'right'
            head = [0, @coords.last[1] - 1]
            head.last = @field.size - 1 if head.last < 0
        when 'down'
            head = [@coords.last[0] + 1, 0]
            head[0] = 0 if head[0] >= @field.size
        when 'up'
            head = [@coords.last[0] - 1, 0]
            head[0] = @field.size - 1 if head[0] < 0
        end
        @coords << head

        if @field.has_entity?(head)
            @field.add_entity()
        else
            @coords.shift()
        end

    end
end

class Field
    attr_reader :size
    Parts = [' . ', ' * ', ' # ', ' & ']
    def initialize(size)
        @size = size
        @data = Array.new(size){Array.new(size) { Parts[0] }}
        @snake = Snake.new("Joe", self)
        add_entity()
    end

    def has_entity?(point)
        @data[point[0]][point[1]] == Parts.last
    end

    def render()
        @snake.move()

        # Remove snake from field
        
        for i in 0...@size
            for j in 0...@size
                @data[i][j] = Parts.first
            end
        end
        
        _render_snake()

        # Render data
        for i in 0...@size
            buffer = ''
            for j in 0...@size
                buffer += @data[i][j]
            end
            puts buffer
        end
        
    end

    def add_entity()
        @data[rand(0...@size)][rand(0...@size)] = Parts.last
    end

    private
    def _render_snake()
        for coord in @snake.coords
            @data[coord[0]][coord[1]] = Parts[1]
        end
        latest_coord = @snake.coords.last
        @data[latest_coord[0]][latest_coord[1]] = Parts[2]
    end

    
end


field = Field.new(8)

while true
    field.render()
    sleep(0.4)

end