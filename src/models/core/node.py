from dataclasses import dataclass, field
from src.const.context import DrawCtx
from src.const.symbols import BoardSymbol


@dataclass
class Point:
    x: int
    y: int

    def __repr__(self) -> str:
        return f"({self.x}, {self.y})"

    def __eq__(self, other: "Point") -> bool:
        return self.x == other.x and self.y == other.y

    @property
    def tuple(self) -> tuple:
        return (self.x, self.y)


@dataclass
class Connection:
    start: "Node"
    end: "Node"
    ctype: str = BoardSymbol.Connection.IMPOSSIBLE

    def __repr__(self) -> str:
        return f"{self.ctype}"


@dataclass
class Connectivity:
    value: str
    possible: bool
    start: Point
    end: Point

    def __repr__(self) -> str:
        return f"{self.start} {self.value} {self.end}"


@dataclass(init=True)
class Node:
    x: int
    y: int
    connected: bool = False
    anchor: bool = False
    is_head: bool = False
    connections: list[Connection] = field(default_factory=list[Connection])

    def __post_init__(self):
        self.connected = True if self.anchor else False

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
        )
        if not other:
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
                connectivity.value = BoardSymbol.Connection.TOP_RIGHT
            elif self.y > other.y and self.x < other.x:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.TOP_LEFT
            elif self.y < other.y and self.x > other.x:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.BOTTOM_RIGHT
            elif self.y < other.y and self.x < other.x:
                connectivity.possible = True
                connectivity.value = BoardSymbol.Connection.BOTTOM_LEFT
            else:
                return connectivity
        return connectivity

    def connect(self, other: "Node") -> Connection | None:
        connectivity = self.can_connect(other)
        if connectivity.possible:
            self.connected, other.connected = True, True
            connection = Connection(ctype=connectivity.value, start=self, end=other)
            self.connections.append(connection)
            other.connections.append(connection)
            print(f"Connected {self} {self.coords} to {other} {other.coords}")
            return connection
        else:
            print(f"Can't connect {self} {self.coords} to {other} {other.coords}")
