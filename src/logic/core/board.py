from dataclasses import dataclass
from itertools import cycle
import math
import random

import pygame
from src.const.colors import GameColors
from src.logic.core.objects import Connection, Node, Connectivity, Point


@dataclass
class PlayerVisual:
    name: str
    connection_color: tuple
    turn: bool = False
    lost: bool = False

    def __repr__(self) -> str:
        return f"{self.name}"


class Board:

    def __init__(
        self, height: int, width: int, start_anchor: Point, surface: pygame.Surface, players: list[PlayerVisual] = None
    ):
        self.height = height
        self.width = width
        self.start_anchor = start_anchor

        self.nodes: list[Node] = [
            [Node(x, y, anchor=self.start_anchor == Point(x, y), surface=surface) for x in range(self.width)]
            for y in range(self.height)
        ]
        self.head: Node = self.nodes[self.start_anchor.y][self.start_anchor.x]
        self.connections: list[Connection] = []

        self.surface = surface
        self.players = cycle(
            players
            or [
                PlayerVisual(name="Ya", connection_color=GameColors.CYAN),
                PlayerVisual(name="Ne Ya", connection_color=GameColors.YELLOW),
            ]
        )
        self.current_player = next(self.players)

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
        connection = self.head.connect(self.nodes[connectivity.end.y][connectivity.end.x], self.current_player)
        if connection:
            self.connections.append(connection)
            self.head.is_head = False
            self.head = self.nodes[connectivity.end.y][connectivity.end.x]
            self.head.is_head = True
            self.current_player = next(self.players)

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

    def draw(self) -> None:
        for y in range(self.height):
            for x in range(self.width):
                self.nodes[y][x].draw()

        for connection in self.connections:
            connection.draw()

        for possible in self.possible_connections():
            self.nodes[possible.end.y][possible.end.x].draw(as_fututre_target=True)

    def random_simulation(self) -> None:
        while self.possible_connections():
            self.connect_head(random.choice(self.possible_connections()))

    def pick_next_by_mouse(self, mouse_pos: tuple) -> Connectivity | None:

        def _mouse_over_node(node: Node) -> bool:
            return (
                math.sqrt((node.v_coords.x - mouse_pos[0]) ** 2 + (node.v_coords.y - mouse_pos[1]) ** 2)
                < Node.NODE_RADIUS
            )

        for connectivity in self.possible_connections():
            node = self.nodes[connectivity.end.y][connectivity.end.x]

            if _mouse_over_node(node):
                return connectivity

        return None

    def flush(self) -> "Board":
        self = self.__class__(
            height=self.height,
            width=self.width,
            start_anchor=self.start_anchor,
            surface=self.surface,
            players=self.players,
        )
        return self
