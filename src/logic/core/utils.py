from dataclasses import dataclass


def flatten(l):
    return [item for sublist in l for item in sublist]


@dataclass
class Point:
    x: int
    y: int

    def __repr__(self) -> str:
        return f"({self.x}, {self.y})"

    def __eq__(self, other: "Point") -> bool:
        return self.x == other.x and self.y == other.y

    @classmethod
    def from_tuple(cls, t: tuple) -> "Point":
        return cls(t[0], t[1])

    @property
    def tuple(self) -> tuple:
        return (self.x, self.y)


@dataclass
class PlayerVisual:
    name: str
    connection_color: tuple
    turn: bool = False
    lost: bool = False

    def __repr__(self) -> str:
        return f"{self.name}"


@dataclass
class Connectivity:
    value: str
    possible: bool
    start: Point
    end: Point
    from_head: bool = False
    from_tail: bool = False

    def __repr__(self) -> str:
        return f"{self.value} {self.end}"

    def __eq__(self, other: "Connectivity") -> bool:
        return self.start == other.start and self.end == other.end


@dataclass
class NodeVisual:
    SCALE_FACTOR: int = 40
    NODE_RADIUS: int = 20
    COORD_MARGIN_X: int = 100
    COORD_MARGIN_Y: int = 100
    NODE_INTERVAL_X: int = 25
    NODE_INTERVAL_Y: int = 25
    HOVER_HIT_RADIUS: int = 3
