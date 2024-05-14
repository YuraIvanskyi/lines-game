import math

import pygame
from src.const.colors import GameColors
from src.const.symbols import BoardSymbol
from src.logic.core.utils import Connectivity, NodeVisual, PlayerVisual, Point


class Connection:

    def __init__(
        self,
        start: "Node",
        end: "Node",
        player: PlayerVisual,
        surface: pygame.Surface,
        ctype: str = BoardSymbol.Connection.IMPOSSIBLE,
    ):
        self.start = start
        self.end = end
        self.ctype = ctype
        self.player = player
        self.surface = surface

    def __repr__(self) -> str:
        return f"{self.ctype}"

    def draw(self) -> None:
        pygame.draw.line(
            surface=self.surface,
            color=self.player.connection_color,
            start_pos=self.start.v_coords.tuple,
            end_pos=self.end.v_coords.tuple,
            width=max(int(self.start.node_style.NODE_RADIUS * 0.75), 5),
        )


class Node:
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

    def __repr__(self) -> str:
        filling = BoardSymbol.Node.FILLED if self.connected else BoardSymbol.Node.EMPTY
        return f"{filling}"

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

    def draw(self, as_fututre_target: bool = False):
        # pygame.draw.circle(
        #     surface=self.surface,
        #     color=GameColors.WHITE,
        #     center=self.v_coords.tuple,
        #     radius=self.node_style.NODE_RADIUS,
        #     width=0,
        # )
        if self.is_wall:
            pygame.draw.rect(
                surface=self.surface,
                color=GameColors.CORNFLOWER_BLUE,
                width=0,
                rect=pygame.Rect(
                    self.v_coords.x - self.node_style.NODE_RADIUS,
                    self.v_coords.y - self.node_style.NODE_RADIUS,
                    self.node_style.NODE_RADIUS * 2,
                    self.node_style.NODE_RADIUS * 2,
                ),
            )
            return

        pygame.draw.circle(
            surface=self.surface,
            color=GameColors.BLACK,
            center=self.v_coords.tuple,
            radius=self.node_style.NODE_RADIUS,
            width=2,
        )
        if self.connected:
            pygame.draw.circle(
                surface=self.surface,
                color=GameColors.BLUE if self.is_head or self.is_tail else GameColors.GREEN,
                center=self.v_coords.tuple,
                radius=self.node_style.NODE_RADIUS / 2,
                width=0,
            )
        elif as_fututre_target:
            pygame.draw.circle(
                surface=self.surface,
                color=GameColors.RED if not self.hovered else GameColors.CYAN,
                center=self.v_coords.tuple,
                radius=self.node_style.NODE_RADIUS / 2,
                width=2 if not self.hovered else 0,
            )
