import math
import random
import itertools

import pygame
from src.const.colors import GameColors
from src.const.symbols import BoardSymbol
from src.logic.core.utils import Connectivity, NodeVisual, PlayerVisual, Point


class Connection(pygame.sprite.Sprite):

    def __init__(
        self,
        start: "Node",
        end: "Node",
        player: PlayerVisual,
        surface: pygame.Surface,
        ctype: str = BoardSymbol.Connection.IMPOSSIBLE,
    ):
        super().__init__()
        self.start = start
        self.end = end
        self.ctype = ctype
        self.player = player
        self.surface = surface
        self.hand_drawn_line = []

    def __repr__(self) -> str:
        return f"{self.ctype}"

    def hand_drawn_lines_points(self, segments: int = 10, jitter: int = 5) -> list[Point]:
        points = []
        for i in range(segments + 1):
            t = i / segments
            x = self.start.v_coords.x + (self.end.v_coords.x - self.start.v_coords.x) * t
            y = self.start.v_coords.y + (self.end.v_coords.y - self.start.v_coords.y) * t
            x += random.uniform(-jitter, jitter)
            y += random.uniform(-jitter, jitter)
            points.append((x, y))

        return points

    def get_hand_drawn_line(self) -> list[Point]:
        points = []
        for _ in range(5):
            points.append(self.hand_drawn_lines_points())
        self.hand_drawn_line = points if not self.hand_drawn_line else self.hand_drawn_line
        return self.hand_drawn_line

    def draw(self) -> None:
        for points in self.get_hand_drawn_line():
            pygame.draw.lines(self.surface, self.player.connection_color, False, points, 2)

    def __eq__(self, other: "Connection") -> bool:
        return (self.start == other.start and self.end == other.end) or (
            self.start == other.end and self.end == other.start
        )


class Node(pygame.sprite.Sprite):
    node_animation_frame = itertools.cycle(
        [1 for _ in range(15)]
        + [2 for _ in range(25)]
        + [3 for _ in range(40)]
        + [2 for _ in range(25)]
        + [1 for _ in range(15)]
    )

    def __init__(
        self,
        x: int,
        y: int,
        surface: pygame.Surface,
        anchor: bool = False,
        wall: bool = False,
        connections: list[Connection] = None,
        node_style: NodeVisual = None,
    ):
        super().__init__()
        self.x = x
        self.y = y
        self.anchor = anchor
        self.connected = True if self.anchor else False
        self.is_head = True if self.anchor else False
        self.is_tail = True if self.anchor else False
        self.is_wall = wall if not self.anchor else False
        self.connections = connections or []
        self.surface = surface
        self.node_style = node_style if node_style else NodeVisual()
        self.wall_image = pygame.transform.scale_by(
            pygame.image.load(f"assets/stains/s{random.randint(1,15)}.png").convert_alpha(),
            self.node_style.NODE_RADIUS / 100,
        )

        self.wall_cutout = self.get_wall_cutout_points()

    def __repr__(self) -> str:
        if self.is_head:
            return "H"
        elif self.is_tail:
            return "T"
        elif self.is_wall:
            return "W"
        else:
            filling = BoardSymbol.Node.FILLED if self.connected else BoardSymbol.Node.EMPTY
            return f"{filling}"

    def __eq__(self, other: "Node") -> bool:
        return self.x == other.x and self.y == other.y

    @property
    def coords(self) -> Point:
        return Point(self.x, self.y)

    def can_connect(self, other: "Node" = None) -> Connectivity:
        connectivity = Connectivity(
            value=BoardSymbol.Connection.IMPOSSIBLE,
            possible=False,
            start=self.coords,
            end=other.coords if other else Point(-1, -1),
            from_head=self.is_head,
            from_tail=self.is_tail,
        )
        if not other:
            return connectivity
        if other.is_wall:
            return connectivity
        if any([self.x < 0, self.y < 0, other.x < 0, other.y < 0]):
            return connectivity
        if not self.connected or other.connected:
            return connectivity
        elif abs(self.x - other.x) > 1 or abs(self.y - other.y) > 1:
            return connectivity
        else:
            if self.x == other.x and self.y == other.y:
                return connectivity
            elif self.x == other.x and self.y > other.y:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.TOP
            elif self.x == other.x and self.y < other.y:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.BOTTOM
            elif self.y == other.y and self.x > other.x:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.LEFT
            elif self.y == other.y and self.x < other.x:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.RIGHT
            elif self.y > other.y and self.x > other.x:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.TOP_LEFT
            elif self.y > other.y and self.x < other.x:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.TOP_RIGHT
            elif self.y < other.y and self.x > other.x:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.BOTTOM_LEFT
            elif self.y < other.y and self.x < other.x:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.BOTTOM_RIGHT
            else:
                return connectivity
        return connectivity

    def connect(self, other: "Node", player: PlayerVisual) -> Connection | None:
        connectivity = self.can_connect(other)
        if connectivity.possible:
            self.connected, other.connected = True, True
            connection = Connection(
                ctype=connectivity.value, start=self, end=other, surface=self.surface, player=player
            )
            self.connections.append(connection)
            other.connections.append(connection)
            return connection
        else:
            print(f"Can't connect {self} {self.coords} to {other} {other.coords} by {player.name}")

    @property
    def v_coords(self) -> Point:
        x = self.x * (self.node_style.SCALE_FACTOR + self.node_style.NODE_INTERVAL_X) + self.node_style.COORD_MARGIN_X
        y = self.y * (self.node_style.SCALE_FACTOR + self.node_style.NODE_INTERVAL_Y) + self.node_style.COORD_MARGIN_Y
        return Point(x, y)

    @property
    def hovered(self) -> bool:
        mouse_pos = Point.from_tuple(pygame.mouse.get_pos())
        return (
            math.sqrt((self.v_coords.x - mouse_pos.x) ** 2 + (self.v_coords.y - mouse_pos.y) ** 2)
            < self.node_style.NODE_RADIUS + self.node_style.HOVER_HIT_RADIUS
        )

    def get_wall_cutout_points(self) -> list[Point]:
        MIN_PAPER_MARGIN = int(self.node_style.NODE_RADIUS) - 5
        MAX_PAPER_MARGIN = int(self.node_style.NODE_RADIUS) + 10

        def _get_margin() -> int:
            return random.randint(MIN_PAPER_MARGIN, MAX_PAPER_MARGIN)

        return [
            Point(self.v_coords.x - _get_margin(), self.v_coords.y - _get_margin()).tuple,
            Point(self.v_coords.x - _get_margin(), self.v_coords.y).tuple,
            Point(self.v_coords.x - _get_margin(), self.v_coords.y + _get_margin()).tuple,
            Point(self.v_coords.x, self.v_coords.y + _get_margin()).tuple,
            Point(self.v_coords.x + _get_margin(), self.v_coords.y + _get_margin()).tuple,
            Point(self.v_coords.x + _get_margin(), self.v_coords.y).tuple,
            Point(self.v_coords.x + _get_margin(), self.v_coords.y - _get_margin()).tuple,
            Point(self.v_coords.x, self.v_coords.y - _get_margin()).tuple,
        ]

    def draw(self, player: PlayerVisual = None, as_future_target: bool = False) -> None:

        if self.is_wall:
            self.surface.blit(
                self.wall_image,
                (self.v_coords.x - self.wall_image.get_width() / 2, self.v_coords.y - self.wall_image.get_height() / 2),
            )
            # pygame.draw.polygon(surface=self.surface, color=GameColors.WHITE, width=0, points=self.wall_cutout)
            # pygame.draw.aalines(
            #     surface=self.surface, color=GameColors.PACIFIC_BLUE, closed=True, points=self.wall_cutout
            # )

            return

        if self.connected and self.connections:
            pygame.draw.circle(
                surface=self.surface,
                color=self.connections[-1].player.connection_color,
                center=self.v_coords.tuple,
                radius=self.node_style.NODE_RADIUS / 2,
                width=0,
            )
        elif as_future_target:
            pygame.draw.circle(
                surface=self.surface,
                color=GameColors.RED if not self.hovered else player.connection_color,
                center=self.v_coords.tuple,
                radius=self.node_style.NODE_RADIUS / 2 + next(self.node_animation_frame),
                width=2 if not self.hovered else 0,
            )

        if self.is_head:
            pygame.draw.circle(
                surface=self.surface,
                color=GameColors.WHITE_SMOKE if self.connections else GameColors.BLACK,
                center=self.v_coords.tuple,
                radius=self.node_style.NODE_RADIUS / 2 - 2,
                width=2,
            )
        elif self.is_tail:
            pygame.draw.circle(
                surface=self.surface,
                color=GameColors.WHITE_SMOKE,
                center=self.v_coords.tuple,
                radius=self.node_style.NODE_RADIUS / 2 - 2,
                width=2,
            )
