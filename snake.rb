require 'curses'

class View
    def render(buffer)
        # clear()
        Curses.setpos(0, 0)
        Curses.addstr(buffer)
        Curses.refresh()
    end
end

class Snake
    attr_writer :direction
    attr_reader :coords

    def initialize(name, field)
        @name = name
        @field = field
        @coords = Array.new(4) {|i| [0, i]}
        @direction = 'right'
        
    end

    def move()
        head = @coords.last.clone()
        case @direction
        when 'left'
            head[1] -= 1
            head[1] = @field.size - 1 if head[1] < 0
        when 'right'
            head[1] += 1
            head[1] = 0 if head[1] >= @field.size
        when 'down'
            head[0] += 1
            head[0] = 0 if head[0] >= @field.size
        when 'up'
            head[0] -= 1
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
    attr_reader :size, :snake
    Parts = [' . ', ' * ', ' # ', ' & ']
    def initialize(size)
        @size = size
        @data = Array.new(size){Array.new(size) { Parts[0] }}
        add_entity()
        @snake = Snake.new("Joe", self)
    end

    def has_entity?(point)
        return @data[point[0]][point[1]] == Parts[3]
    end

    def render()
        @snake.move()

        # Remove snake from field
        
        for i in 0...@size
            for j in 0...@size
                if @data[i][j] == Parts[1] or @data[i][j] == Parts[2]
                    @data[i][j] = Parts[0]
                end
            end
        end
        
        _render_snake()

        buffer = ''
        # Render data
        for i in 0...@size
            row = ''
            for j in 0...@size
                row += @data[i][j]
            end
            buffer += row + "\n"
        end
        View.new.render(buffer)
        
    end

    def add_entity()
        i, j = rand(@size), rand(@size)
        @data[i][j] = Parts[3]
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

Curses.init_screen()
begin
    Curses.stdscr.keypad = true
    Curses.nonl()
    Curses.cbreak()
    Curses.noecho()

    Curses.timeout=0
    
    field = Field.new(8)

    while true
        field.render()
        sleep(0.4)
        ch = Curses.getch()
        case ch
        when Curses::KEY_UP
            field.snake.direction = "up"
        when Curses::KEY_DOWN
            field.snake.direction = "down"
        when Curses::KEY_LEFT
            field.snake.direction = "left"
        when Curses::KEY_RIGHT
            field.snake.direction = "right"
        end
    end

    # getch()
ensure
    Curses.close_screen()
end
