from dataclasses import dataclass, field
from src.const.context import DrawCtx
from src.const.symbols import BoardSymbol


@dataclass
class Connection:
    start: "Node"
    end: "Node"
    ctype: str = BoardSymbol.Connection.MISSING
    draw_context: dict = field(default_factory=dict)

    def __repr__(self) -> str:
        return f"{self.ctype}"


@dataclass(init=True)
class Node:
    x: int
    y: int
    connected: bool = False
    anchor: bool = False
    connections: list["Connection"] = field(default_factory=list["Connection"])
    draw_context: dict = field(default_factory=dict)

    def __post_init__(self):
        self.connected = True if self.anchor else False

    def __repr__(self) -> str:
        filling = BoardSymbol.Node.FILLED if self.connected else BoardSymbol.Node.EMPTY
        return f"{filling}"

    @property
    def coords(self) -> tuple[int, int]:
        return self.x, self.y

    @property
    def draw_center(self) -> tuple[float, float]:
        return (
            self.draw_context[DrawCtx.CIRCLE_C_X],
            self.draw_context[DrawCtx.CIRCLE_C_Y],
        )

    def distance(self, other: "Node") -> float:
        return (
            (self.draw_context[DrawCtx.CIRCLE_C_X] - other.draw_context[DrawCtx.CIRCLE_C_X]) ** 2
            + (self.draw_context[DrawCtx.CIRCLE_C_Y] - other.draw_context[DrawCtx.CIRCLE_C_Y]) ** 2
        ) ** 0.5

    def availiable_connection_for_node(self, other: "Node") -> str:
        if not self.connected or other.connected:
            return BoardSymbol.Connection.MISSING
        elif abs(self.x - other.x) > 1 or abs(self.y - other.y) > 1:
            return BoardSymbol.Connection.MISSING
        else:
            if self.x == other.x and self.y == other.y:
                return BoardSymbol.Connection.MISSING
            elif self.x == other.x and self.y > other.y:
                return BoardSymbol.Connection.TOP
            elif self.x == other.x and self.y < other.y:
                return BoardSymbol.Connection.BOTTOM
            elif self.y == other.y and self.x > other.x:
                return BoardSymbol.Connection.LEFT
            elif self.y == other.y and self.x < other.x:
                return BoardSymbol.Connection.RIGHT
            elif self.y > other.y and self.x > other.x:
                return BoardSymbol.Connection.TOP_RIGHT
            elif self.y > other.y and self.x < other.x:
                return BoardSymbol.Connection.TOP_LEFT
            elif self.y < other.y and self.x > other.x:
                return BoardSymbol.Connection.BOTTOM_RIGHT
            elif self.y < other.y and self.x < other.x:
                return BoardSymbol.Connection.BOTTOM_LEFT
            else:
                return BoardSymbol.Connection.MISSING

    def connect(self, other: "Node") -> Connection | None:
        conn_type = self.availiable_connection_for_node(other)
        if conn_type != BoardSymbol.Connection.MISSING:
            self.connected = True
            other.connected = True
            connection = Connection(ctype=conn_type, start=self, end=other)
            self.connections.append(connection)
            other.connections.append(connection)
        else:
            print(f"Can't connect {self} {self.coords} to {other} {other.coords}")
