from dataclasses import dataclass, field
from src.const.context import DrawCtx
from src.const.symbols import BoardSymbol
from src.models.node import Connection
from src.models.node import Node
from turtle import Turtle


@dataclass
class Board:
    height: int
    width: int
    anchor: tuple[int, int] | None = None
    # t: Turtle | None = field(default=Turtle())

    def __post_init__(self):
        self.nodes: list[Node] = [
            [Node(x, y, anchor=self.anchor == (x, y)) for x in range(self.width)] for y in range(self.height)
        ]
        self.connections: list[Connection] = []

    def connect_cords(self, n1: tuple[int, int], n2: tuple[int, int]) -> Connection:
        self.nodes[n1[0]][n1[1]].connect(self.nodes[n2[0]][n2[1]])

    def display(self):
        for row in self.nodes:
            for node in row:
                print(node if not node.connections else node.connections[-1], end="  ")
            print()
        print()

    def draw_board(self):
        junction = 5
        line_buffer = 10

        self.t.screen.tracer(False)
        self.t.screen.setworldcoordinates(-10, -110, 110, 10)
        self.t.pen(pensize=3)
        for ri in range(self.height):
            self.t.teleport(-1 * junction, -1 * ri * line_buffer)
            self.t.forward(self.height * line_buffer)

        self.t.right(90)

        for ri in range(self.width):
            self.t.teleport(ri * line_buffer, junction)
            self.t.forward(self.width * line_buffer)

        self.t.screen.update()

    def state(self):
        radius = 2.5
        line_buffer = 10

        for row in self.nodes:
            for node in row:
                self.t.color("black", "red" if node.connected else "grey")
                self.t.begin_fill()

                circle_start_x = (line_buffer * node.x) - radius
                circle_start_y = -1 * (line_buffer * node.y)

                node.draw_context[DrawCtx.CIRCLE_C_X] = circle_start_x + radius
                node.draw_context[DrawCtx.CIRCLE_C_Y] = circle_start_y

                self.t.teleport(circle_start_x, circle_start_y)
                self.t.circle(radius)
                self.t.write(node.draw_center, align="center", font=("Arial", 8, "normal"))
                self.t.end_fill()

        self.t.pen(pencolor="green", pensize=5)
        self.t.screen.tracer(True)
        for row in self.nodes:
            for node in row:
                for connection in node.connections:
                    if not connection.draw_context.get(DrawCtx.DRAWN):

                        self.t.teleport(
                            connection.start.draw_context[DrawCtx.CIRCLE_C_X],
                            connection.start.draw_context[DrawCtx.CIRCLE_C_Y],
                        )
                        self.t.setheading(BoardSymbol.Connection.DEGREE_MAP[connection.ctype])
                        self.t.forward(connection.start.distance(connection.end))
                        connection.draw_context[DrawCtx.DRAWN] = True

        # self.t.screen.update()
