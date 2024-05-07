from dataclasses import dataclass
from src.const.context import DrawCtx
from src.const.symbols import BoardSymbol
from src.models.node import Connection, Node, Connectivity, Point


@dataclass
class Board:
    height: int
    width: int
    start_anchor: Point
    head: Node | None = None
    # tail: Node | None = None

    def __post_init__(self):
        self.nodes: list[Node] = [
            [Node(x, y, anchor=self.start_anchor == Point(x, y)) for x in range(self.width)] for y in range(self.height)
        ]
        self.head = self.tail = self.nodes[self.start_anchor.y][self.start_anchor.x]
        self.connections: list[Connection] = []

    def possible_connections(self, node: Node = None) -> list[Connectivity]:
        if not node:
            node = self.head
        surrounding_nodes = [
            Point(node.x - 1, node.y - 1),
            Point(node.x, node.y - 1),
            Point(node.x + 1, node.y - 1),
            Point(node.x - 1, node.y),
            Point(node.x + 1, node.y),
            Point(node.x - 1, node.y + 1),
            Point(node.x, node.y + 1),
            Point(node.x + 1, node.y + 1),
        ]

        def _no_crossing(p: Point) -> bool:
            if abs(node.x - p.x) > 1 and abs(node.y - p.y) > 1:
                return not self.nodes[p.y][node.x].connected and not self.nodes[node.y][p.x].connected
            else:
                return True

        return [
            connectivity
            for connectivity in [
                node.can_connect(self.nodes[p.y][p.x] if p.x < self.width and p.y < self.height else None)
                for p in surrounding_nodes
                if _no_crossing(p)
            ]
            if connectivity.possible
        ]

    def connect_head(self, connectivity: Connectivity) -> None:
        connection = self.head.connect(self.nodes[connectivity.end.y][connectivity.end.x])
        if connection:
            self.head = self.nodes[connectivity.end.y][connectivity.end.x]

    def connect_cords(self, n1: tuple[int, int], n2: tuple[int, int]) -> None:
        self.nodes[n1[1]][n1[0]].connect(self.nodes[n2[1]][n2[0]])

    def display(self):
        print("  ", end="")
        for i in range(self.width):
            print(i, end=" ")
        print()
        for ri, row in enumerate(self.nodes):
            print(ri, end=" ")
            for node in row:
                print(node if not node.connections else node.connections[-1], end=" ")
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
