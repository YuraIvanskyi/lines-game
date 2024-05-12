from dataclasses import dataclass
from src.models.core.node import Connection, Node, Connectivity, Point


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
            node
            for node in [
                Point(node.x - 1, node.y - 1),
                Point(node.x, node.y - 1),
                Point(node.x + 1, node.y - 1),
                Point(node.x - 1, node.y),
                Point(node.x + 1, node.y),
                Point(node.x - 1, node.y + 1),
                Point(node.x, node.y + 1),
                Point(node.x + 1, node.y + 1),
            ]
            if node.x < self.width and node.y < self.height
        ]

        def _crossing(p: Point) -> bool:
            if abs(node.x - p.x) > 0 or abs(node.y - p.y) > 0:
                return (self.nodes[p.y][node.x].connected and self.nodes[node.y][p.x].connected) and bool(
                    len(
                        [
                            link
                            for link in self.connections
                            if (
                                link.end.coords == self.nodes[p.y][node.x].coords
                                and link.start.coords == self.nodes[node.y][p.x].coords
                            )
                            or (
                                link.start.coords == self.nodes[p.y][node.x].coords
                                and link.end.coords == self.nodes[node.y][p.x].coords
                            )
                        ]
                    )
                )
            else:
                return False

        return [
            connectivity
            for connectivity in [node.can_connect(self.nodes[p.y][p.x]) for p in surrounding_nodes if not _crossing(p)]
            if connectivity.possible
        ]

    def connect_head(self, connectivity: Connectivity) -> None:
        connection = self.head.connect(self.nodes[connectivity.end.y][connectivity.end.x])
        if connection:
            self.connections.append(connection)
            self.head.is_head = False
            self.head = self.nodes[connectivity.end.y][connectivity.end.x]
            self.head.is_head = True

    def display_as_text(self):
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
