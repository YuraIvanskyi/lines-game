import math
import random
import pygame
from src.const.colors import GameColors
from src.models.core.node import Connectivity, Node, Point
from src.models.core.board import Board


class VisualNode(Node):
    SCALE_FACTOR = 20
    NODE_RADIUS = 10
    COORD_MARGIN_X = 44
    COORD_MARGIN_Y = 95
    NODE_INTERVAL = 25

    def __init__(self, node: Node, surface: pygame.Surface):
        super().__init__(x=node.x, y=node.y, anchor=node.anchor, connected=node.connected, connections=node.connections)
        self.connected = node.connected
        self.is_head = node.is_head
        self.surface = surface

    @property
    def coords(self) -> Point:
        x = self.x * (self.SCALE_FACTOR + self.NODE_INTERVAL) + self.COORD_MARGIN_X
        y = self.y * (self.SCALE_FACTOR + self.NODE_INTERVAL) + self.COORD_MARGIN_Y
        return Point(x, y)

    def draw(self, as_fututre_target: bool = False):
        pygame.draw.circle(
            surface=self.surface,
            color=GameColors.WHITE,
            center=self.coords.tuple,
            radius=self.NODE_RADIUS,
            width=0,
        )
        pygame.draw.circle(
            surface=self.surface,
            color=GameColors.BLACK,
            center=self.coords.tuple,
            radius=self.NODE_RADIUS,
            width=2,
        )
        if self.connected:
            pygame.draw.circle(
                surface=self.surface,
                color=GameColors.BLUE if self.is_head else GameColors.GREEN,
                center=self.coords.tuple,
                radius=self.NODE_RADIUS / 2,
                width=0,
            )
        elif as_fututre_target:
            pygame.draw.circle(
                surface=self.surface,
                color=GameColors.RED,
                center=self.coords.tuple,
                radius=self.NODE_RADIUS / 2,
                width=2,
            )


class VisualBoard(Board):
    def __init__(self, height: int, width: int, surface: pygame.Surface):
        super().__init__(height, width, start_anchor=Point(0, 0))
        self.surface = surface

    def draw(self):
        for y in range(self.height):
            for x in range(self.width):
                VisualNode(self.nodes[y][x], self.surface).draw()

        for connection in self.connections:
            pygame.draw.line(
                surface=self.surface,
                color=(100, 0, 255),
                start_pos=VisualNode(connection.start, self.surface).coords.tuple,
                end_pos=VisualNode(connection.end, self.surface).coords.tuple,
                width=5,
            )

        for possible in self.possible_connections():
            VisualNode(self.nodes[possible.end.y][possible.end.x], self.surface).draw(as_fututre_target=True)

    def random_simulation(self):
        while self.possible_connections():
            self.connect_head(random.choice(self.possible_connections()))

    def pick_next(self, key: int) -> Connectivity | None:
        if key == pygame.K_0:
            self.random_simulation()
        key_map = {
            pygame.K_1: "NUMBER 1",
            pygame.K_2: "NUMBER 2",
            pygame.K_3: "NUMBER 3",
            pygame.K_4: "NUMBER 4",
            pygame.K_5: "NUMBER 5",
            pygame.K_6: "NUMBER 6",
            pygame.K_7: "NUMBER 7",
            pygame.K_8: "NUMBER 8",
            pygame.K_9: "NUMBER 9",
        }
        possible_keys = {key: connection for key, connection in zip(key_map.keys(), self.possible_connections())}
        if not key in possible_keys.keys():
            print(f"Impossible key [{key}], pick among these options")
            for key, conn in possible_keys.items():
                print(f"{key_map[key]}: {conn}")
            return None
        return possible_keys[key]

    def flush(self):
        self = VisualBoard(self.height, self.width, self.surface)
        # self.random_simulation()
        return self
