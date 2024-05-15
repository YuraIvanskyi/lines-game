from dataclasses import dataclass
from itertools import cycle
import math
import random

import pygame
from src.const.colors import GameColors
from src.logic.core.utils import Connectivity, NodeVisual, Point, flatten
from src.logic.core.objects import Connection, Node


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
        self,
        height: int,
        width: int,
        surface: pygame.Surface,
        start_anchor: Point = None,
        players: list[PlayerVisual] = None,
        wall_density: float = 0.05,
    ):
        self.height = height
        self.width = width
        self.start_anchor = (
            start_anchor
            if start_anchor
            else Point(random.randint(0, self.width - 1), random.randint(0, self.height - 1))
        )

        self.surface = surface
        node_interval_x = self.surface.get_width() / self.width
        node_interval_y = self.surface.get_height() / self.height
        node_radius = ((self.surface.get_width() + self.surface.get_height()) / 2) / ((self.width + self.height) * 2)
        node_interval = min(node_interval_x, node_interval_y)

        self.node_style = NodeVisual(
            COORD_MARGIN_X=node_interval_x,
            COORD_MARGIN_Y=node_interval_y,
            NODE_RADIUS=node_radius,
            NODE_INTERVAL_X=node_interval - node_interval / max(self.width, self.height),
            NODE_INTERVAL_Y=node_interval - node_interval / max(self.width, self.height),
            HOVER_HIT_RADIUS=int(node_radius * 0.2),
            SCALE_FACTOR=0,
        )
        self.nodes: list[Node] = [
            [
                Node(
                    x=x,
                    y=y,
                    anchor=self.start_anchor == Point(x, y),
                    surface=surface,
                    node_style=self.node_style,
                    wall=random.choices([True, False], [wall_density, 1 - wall_density])[-1],
                )
                for x in range(self.width)
            ]
            for y in range(self.height)
        ]
        self.head: Node = self.nodes[self.start_anchor.y][self.start_anchor.x]
        self.tail: Node = self.nodes[self.start_anchor.y][self.start_anchor.x]
        self.connections: list[Connection] = []

        self.players = cycle(
            players
            or [
                PlayerVisual(name="Player 1", connection_color=GameColors.CYAN),
                PlayerVisual(name="Player 2", connection_color=GameColors.YELLOW),
            ]
        )
        self.current_player = next(self.players)
        self.paper = self.paper_bg()

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

    def avaialable_moves(self) -> list[Connectivity]:
        # TODO remove duplicates
        return self.possible_connections(self.head) + self.possible_connections(self.tail)

    def connect_head(self, connectivity: Connectivity) -> None:
        connection = self.head.connect(self.nodes[connectivity.end.y][connectivity.end.x], self.current_player)
        if connection:
            self.connections.append(connection)
            self.head.is_head = False
            self.head = self.nodes[connectivity.end.y][connectivity.end.x]
            self.head.is_head = True
            self.current_player = next(self.players)

    def connect_tail(self, connectivity: Connectivity) -> None:
        connection = self.tail.connect(self.nodes[connectivity.end.y][connectivity.end.x], self.current_player)
        if connection:
            self.connections.append(connection)
            self.tail.is_tail = False
            self.tail = self.nodes[connectivity.end.y][connectivity.end.x]
            self.tail.is_tail = True
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

    def paper_bg(self) -> None:
        MIN_PAPER_MARGIN = 25
        MAX_PAPER_MARGIN = 55

        def _get_margin() -> int:
            return random.randint(MIN_PAPER_MARGIN, MAX_PAPER_MARGIN)

        horizontal_top_points = [
            (point.x, point.y - _get_margin()) for point in [self.nodes[0][col].v_coords for col in range(self.width)]
        ][::-1]
        horizontal_bottom_points = [
            (point.x, point.y + _get_margin()) for point in [self.nodes[-1][col].v_coords for col in range(self.width)]
        ]
        vertical_left_points = [
            (point.x - _get_margin(), point.y) for point in [self.nodes[row][0].v_coords for row in range(self.height)]
        ]
        vertical_right_points = [
            (point.x + _get_margin(), point.y) for point in [self.nodes[row][-1].v_coords for row in range(self.height)]
        ][::-1]
        return (
            vertical_left_points + horizontal_bottom_points + vertical_right_points + horizontal_top_points,
            list(zip(horizontal_top_points[::-1], horizontal_bottom_points)),
            list(zip(vertical_left_points, vertical_right_points[::-1])),
        )

    def draw_paper_bg(self) -> None:
        paper, vertical, horizontal = self.paper

        pygame.draw.polygon(surface=self.surface, color=GameColors.CHALK_WHITE, width=0, points=paper)
        pygame.draw.aalines(self.surface, color=GameColors.CORNFLOWER_BLUE, closed=True, points=paper)

        for hline in horizontal:
            pygame.draw.line(self.surface, color=GameColors.CORNFLOWER_BLUE, start_pos=hline[0], end_pos=hline[1])

        for vline in vertical:
            pygame.draw.aaline(self.surface, color=GameColors.CORNFLOWER_BLUE, start_pos=vline[0], end_pos=vline[1])

    def draw(self) -> None:
        self.draw_paper_bg()

        for connection in self.connections:
            connection.draw()
        for node in flatten(self.nodes):
            node.draw()
        for possible in self.avaialable_moves():
            self.nodes[possible.end.y][possible.end.x].draw(as_fututre_target=True)

    def random_simulation(self) -> None:
        while self.avaialable_moves():
            (
                self.connect_head(random.choice(self.possible_connections(self.head)))
                if self.possible_connections(self.head)
                else self.connect_tail(random.choice(self.possible_connections(self.tail)))
            )

    def pick_next_by_mouse(self, mouse_pos: tuple) -> Connectivity | None:

        def _mouse_over_node(node: Node) -> bool:
            return (
                math.sqrt((node.v_coords.x - mouse_pos[0]) ** 2 + (node.v_coords.y - mouse_pos[1]) ** 2)
                < self.node_style.NODE_RADIUS + self.node_style.HOVER_HIT_RADIUS
            )

        for connectivity in self.avaialable_moves():
            node = self.nodes[connectivity.end.y][connectivity.end.x]

            if _mouse_over_node(node):
                return connectivity

        return None

    def get_hovered_node(self, mouse_pos: tuple) -> Node | None:
        for node in flatten(self.nodes):
            if node.hovered(mouse_pos):
                return node

    def flush(self) -> "Board":
        self = self.__class__(
            height=self.height,
            width=self.width,
            start_anchor=Point(random.randint(0, self.width - 1), random.randint(0, self.height - 1)),
            surface=self.surface,
            players=self.players,
        )
        return self
